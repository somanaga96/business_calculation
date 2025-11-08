import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:csv/csv.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';
import 'package:fl_chart/fl_chart.dart';

import '../../../Global.dart';
import '../../entity/transactions.dart';

class AnalysisUtils {
  // Filtering logic
  List<Transactions> applyFilters(
      Global global, {
        String? category,
        DateTime? startDate,
        DateTime? endDate,
        String nameQuery = '',
        String sortBy = 'date',
        bool ascending = true,
        String transactionType = 'All',
        String paymentMode = 'All',
        RangeValues? amountRange,
      }) {
    final base = global.getFilteredTransactions(
      category: category,
      startDate: startDate,
      endDate: endDate,
      nameQuery: nameQuery,
      sortBy: sortBy,
      ascending: ascending,
      minAmount: amountRange?.start,
      maxAmount: amountRange?.end,
    );

    return base.where((t) {
      final matchType = transactionType == 'All' ||
          (t.notes ?? '').toLowerCase() == transactionType.toLowerCase();
      final matchMode = paymentMode == 'All' || (t.credit ?? '') == paymentMode;
      final matchRange = amountRange == null ||
          (t.amount >= amountRange.start && t.amount <= amountRange.end);
      return matchType && matchMode && matchRange;
    }).toList();
  }

  // Export as CSV or PDF
  Future<void> exportData(
      BuildContext ctx, List<Transactions> txns, String format) async {
    if (txns.isEmpty) {
      _snack(ctx, 'No data to export');
      return;
    }

    final dir = await getApplicationDocumentsDirectory();
    final file = File(
        '${dir.path}/transactions_${DateTime.now().millisecondsSinceEpoch}.$format');

    if (format == 'csv') {
      final rows = [
        ['Date', 'Name', 'Category', 'Amount', 'Type', 'PaymentMode'],
        ...txns.map((t) => [
          DateFormat('dd/MM/yyyy').format(t.date),
          t.name,
          t.category ?? '',
          t.amount,
          t.notes ?? '',
          t.credit ?? ''
        ]),
      ];
      await file.writeAsString(const ListToCsvConverter().convert(rows));
    } else {
      final pdf = pw.Document();
      pdf.addPage(
        pw.Page(
          build: (_) => pw.Table.fromTextArray(
            headers: ['Date', 'Name', 'Category', 'Amount', 'Type', 'PaymentMode'],
            data: txns
                .map((t) => [
              DateFormat('dd/MM/yyyy').format(t.date),
              t.name,
              t.category ?? '',
              t.amount,
              t.notes ?? '',
              t.credit ?? ''
            ])
                .toList(),
          ),
        ),
      );
      await file.writeAsBytes(await pdf.save());
    }

    await Share.shareXFiles([XFile(file.path)], text: 'Exported as $format');
    _snack(ctx, 'Exported $format successfully');
  }

  void _snack(BuildContext ctx, String msg) =>
      ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(content: Text(msg)));

  // Pie Chart section builder
  List<PieChartSectionData> pieSections(List<Transactions> txs) {
    final map = <String, double>{};
    for (var t in txs) {
      if ((t.notes ?? '').toLowerCase() == 'income') continue;
      map[t.category ?? 'Uncategorized'] =
          (map[t.category ?? 'Uncategorized'] ?? 0) + t.amount.abs();
    }

    final total = map.values.fold(0.0, (a, b) => a + b);
    if (total == 0) return [];

    const colors = [
      Colors.blue,
      Colors.red,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.yellow,
      Colors.teal,
      Colors.brown,
    ];

    return map.entries.toList().asMap().entries.map((e) {
      final index = e.key;
      final entry = e.value;
      return PieChartSectionData(
        value: entry.value,
        title: '${(entry.value / total * 100).toStringAsFixed(1)}%',
        color: colors[index % colors.length],
        titleStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }).toList();
  }
}
