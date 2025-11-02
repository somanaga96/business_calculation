// analysis_screen.dart
import 'dart:ffi';
import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';
import 'package:fl_chart/fl_chart.dart';

import '../../Global.dart';
import '../../utils/date_picker/month_year_picker.dart';
import '../../utils/icons/category_item.dart';
import '../entity/transactions.dart';
import '../transactions/business_transactions.dart';

class AnalysisScreen extends StatefulWidget {
  const AnalysisScreen({super.key});

  @override
  State<AnalysisScreen> createState() => _AnalysisScreenState();
}

class _AnalysisScreenState extends State<AnalysisScreen>
    with SingleTickerProviderStateMixin {
  String? selectedCategory;
  String sortBy = 'date';
  bool ascending = true;
  String nameQuery = '';
  DateTime? startDate;
  DateTime? endDate;

  // New filters
  String transactionType = 'All'; // All, Income, Expense
  String paymentMode = 'All'; // All or specific modes
  RangeValues? amountRange; // active amount range slider

  late TabController _tabController;
  final MonthYearPicker monthPicker = MonthYearPicker();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  void _changeMonth(Global global, int delta) {
    setState(() {
      // Disable date range if month is being changed
      startDate = null;
      endDate = null;

      final newDate = DateTime(
        global.selectedDate.year,
        global.selectedDate.month + delta,
      );
      global.setMonthYear(newDate);
    });
  }

  Future<void> _exportData(
    List<Transactions> transactions,
    String format,
  ) async {
    if (transactions.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('No data to export')));
      return;
    }

    final directory = await getApplicationDocumentsDirectory();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    String filePath = '${directory.path}/transactions_$timestamp.$format';

    if (format == 'csv') {
      final rows = [
        ['Date', 'Name', 'Category', 'Amount', 'Type', 'PaymentMode'],
        ...transactions.map(
          (t) => [
            DateFormat('dd/MM/yyyy').format(t.date),
            t.name,
            t.category ?? '',
            t.amount.toString(),
            (t.notes ?? ''),
            (t.credit ?? ''),
          ],
        ),
      ];
      final csvData = const ListToCsvConverter().convert(rows);
      final file = File(filePath);
      await file.writeAsString(csvData);
      await Share.shareXFiles([XFile(file.path)], text: 'Exported CSV file');
    } else if (format == 'pdf') {
      final pdf = pw.Document();
      pdf.addPage(
        pw.Page(
          build: (pw.Context context) => pw.Table.fromTextArray(
            headers: [
              'Date',
              'Name',
              'Category',
              'Amount',
              'Type',
              'PaymentMode',
            ],
            data: transactions
                .map(
                  (t) => [
                    DateFormat('dd/MM/yyyy').format(t.date),
                    t.name,
                    t.category ?? '',
                    t.amount.toString(),
                    (t.notes ?? ''),
                    (t.credit ?? true),
                  ],
                )
                .toList(),
          ),
        ),
      );

      final file = File(filePath);
      await file.writeAsBytes(await pdf.save());
      await Share.shareXFiles([XFile(file.path)], text: 'Exported PDF file');
    }

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Exported as $format')));
  }

  // Local wrapper: apply additional filters not present in Global.getFilteredTransactions
  List<Transactions> _applyExtraFilters(List<Transactions> base) {
    var filtered = base;

    // Transaction type filter (if the Transaction model has `type`)
    if (transactionType != 'All') {
      filtered = filtered
          .where(
            (t) =>
                (t.notes ?? '').toLowerCase() ==
                (transactionType.toLowerCase()),
          )
          .toList();
    }

    // Payment mode filter (if model has paymentMode)
    if (paymentMode != 'All') {
      filtered = filtered
          .where((t) => (t.credit ?? '') == paymentMode)
          .toList();
    }

    // Amount range filter (if active)
    if (amountRange != null) {
      final min = amountRange!.start;
      final max = amountRange!.end;
      filtered = filtered
          .where((t) => t.amount >= min && t.amount <= max)
          .toList();
    }

    return filtered;
  }

  // Build pie chart sections from filtered transactions
  List<PieChartSectionData> _buildPieSections(List<Transactions> txList) {
    // Sum amounts by category (only expenses for clarity)
    final Map<String, double> map = {};
    for (var t in txList) {
      // If you want to show expenses only, check type == 'expense'
      if ((t.notes ?? '').toLowerCase() == 'income') continue;
      final key = (t.category ?? 'Uncategorized');
      map[key] = (map[key] ?? 0) + (t.amount.abs());
    }

    final total = map.values.fold<double>(0.0, (p, e) => p + e);
    if (total == 0) {
      return [];
    }

    final sections = <PieChartSectionData>[];
    int i = 0;
    // simple color list (fl_chart requires Color); using Theme colors would be nicer
    final colors = [
      Colors.blue,
      Colors.red,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.yellow.shade700,
      Colors.teal,
      Colors.brown,
    ];

    map.forEach((category, amount) {
      final percent = (amount / total) * 100;
      final color = colors[i % colors.length];
      sections.add(
        PieChartSectionData(
          value: amount,
          title: '${percent.toStringAsFixed(1)}%',
          radius: 60,
          showTitle: true,
          titleStyle: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          color: color,
        ),
      );
      i++;
    });

    return sections;
  }

  @override
  Widget build(BuildContext context) {
    final global = Provider.of<Global>(context);

    // Base filtered list from Global using built-in filters
    final baseFiltered = global.getFilteredTransactions(
      category: selectedCategory,
      startDate: startDate,
      endDate: endDate,
      nameQuery: nameQuery,
      sortBy: sortBy,
      ascending: ascending,
      // pass min/max if amountRange is active
      minAmount: amountRange?.start,
      maxAmount: amountRange?.end,
    );

    // Apply extra filters not handled by Global
    final filtered = _applyExtraFilters(baseFiltered);

    // Determine amount slider bounds from all transactions (global)
    final amounts = global.transactionList
        .map((t) => t.amount.abs().toDouble())
        .toList();
    final overallMin = amounts.isEmpty ? 0.0 : amounts.reduce(min);
    final overallMax = amounts.isEmpty ? 1000.0 : amounts.reduce(max);

    amountRange ??= RangeValues(overallMin, overallMax);

    final bool isDateRangeActive = startDate != null && endDate != null;

    // categories list for pie legend
    final pieSections = _buildPieSections(filtered);
    final pieCategories = <String>[];
    if (pieSections.isNotEmpty) {
      // rebuild category order consistent with pieSections by summing map again
      final Map<String, double> map = {};
      for (var t in filtered) {
        if (t.credit == true) continue;
        final key = (t.category ?? 'Uncategorized');
        map[key] = (map[key] ?? 0) + (t.amount.abs());
      }
      pieCategories.addAll(map.keys);
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Analysis'),
        backgroundColor: Colors.blue,
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.ios_share),
            onSelected: (value) async {
              final filteredForExport = _applyExtraFilters(
                global.getFilteredTransactions(
                  category: selectedCategory,
                  startDate: startDate,
                  endDate: endDate,
                  nameQuery: nameQuery,
                  sortBy: sortBy,
                  ascending: ascending,
                  minAmount: amountRange?.start,
                  maxAmount: amountRange?.end,
                ),
              );
              await _exportData(filteredForExport, value);
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'csv', child: Text('Export as CSV')),
              const PopupMenuItem(value: 'pdf', child: Text('Export as PDF')),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() {
                selectedCategory = null;
                nameQuery = '';
                startDate = null;
                endDate = null;
                sortBy = 'date';
                ascending = true;
                transactionType = 'All';
                paymentMode = 'All';
                amountRange = RangeValues(overallMin, overallMax);
              });
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.list), text: 'List View'),
            Tab(icon: Icon(Icons.pie_chart), text: 'Graph View'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // ---------- LIST VIEW ----------
          Column(
            children: [
              // Month selector
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.chevron_left),
                    onPressed: isDateRangeActive
                        ? null
                        : () => _changeMonth(global, -1),
                  ),
                  ElevatedButton(
                    onPressed: isDateRangeActive
                        ? null
                        : () async {
                            startDate = null;
                            endDate = null;
                            await monthPicker.pickMonthYear(context, global);
                            setState(() {});
                          },
                    child: Text(
                      DateFormat('MMM/yyyy').format(global.selectedDate),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.chevron_right),
                    onPressed: isDateRangeActive
                        ? null
                        : () => _changeMonth(global, 1),
                  ),
                ],
              ),

              // Filters row - horizontally scrollable
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      // Category dropdown with icons
                      DropdownButton<String>(
                        hint: const Text('Category'),
                        value: selectedCategory,
                        items: kCategories.map((c) {
                          return DropdownMenuItem(
                            value: c.name,
                            child: Row(
                              children: [
                                Icon(c.icon, color: Colors.blueGrey, size: 20),
                                const SizedBox(width: 8),
                                Text(c.name),
                              ],
                            ),
                          );
                        }).toList(),
                        onChanged: (v) => setState(() => selectedCategory = v),
                        selectedItemBuilder: (BuildContext context) {
                          return kCategories.map((c) {
                            return Row(
                              children: [
                                Icon(c.icon, color: Colors.blueGrey, size: 20),
                                const SizedBox(width: 8),
                                Text(c.name),
                              ],
                            );
                          }).toList();
                        },
                      ),

                      const SizedBox(width: 8),

                      // Transaction Type dropdown
                      DropdownButton<String>(
                        value: transactionType,
                        items: const [
                          DropdownMenuItem(value: 'All', child: Text('All')),
                          DropdownMenuItem(
                            value: 'Income',
                            child: Text('Income'),
                          ),
                          DropdownMenuItem(
                            value: 'Expense',
                            child: Text('Expense'),
                          ),
                        ],
                        onChanged: (v) =>
                            setState(() => transactionType = v ?? 'All'),
                      ),

                      const SizedBox(width: 8),

                      // Payment Mode (if available)
                      DropdownButton<String>(
                        value: paymentMode,
                        items: const [
                          DropdownMenuItem(
                            value: 'All',
                            child: Text('All Modes'),
                          ),
                          DropdownMenuItem(value: 'Cash', child: Text('Cash')),
                          DropdownMenuItem(value: 'Card', child: Text('Card')),
                          DropdownMenuItem(value: 'UPI', child: Text('UPI')),
                          DropdownMenuItem(
                            value: 'NetBanking',
                            child: Text('NetBanking'),
                          ),
                        ],
                        onChanged: (v) =>
                            setState(() => paymentMode = v ?? 'All'),
                      ),

                      const SizedBox(width: 8),

                      // Name search
                      SizedBox(
                        width: 150,
                        child: TextField(
                          decoration: const InputDecoration(
                            labelText: 'Search Name',
                          ),
                          onChanged: (v) => setState(() => nameQuery = v),
                        ),
                      ),
                      const SizedBox(width: 8),

                      // Date range picker
                      ElevatedButton(
                        onPressed: () async {
                          final picked = await showDateRangePicker(
                            context: context,
                            firstDate: DateTime(2000),
                            lastDate: DateTime(2100),
                          );
                          if (picked != null) {
                            setState(() {
                              startDate = picked.start;
                              endDate = picked.end;
                              global.setMonthYear(picked.start);
                            });
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isDateRangeActive
                              ? Colors.blue
                              : Colors.grey[100],
                        ),
                        child: Text(
                          startDate != null && endDate != null
                              ? '${DateFormat('dd/MM/yyyy').format(startDate!)} - ${DateFormat('dd/MM/yyyy').format(endDate!)}'
                              : 'Select Date Range',
                        ),
                      ),
                      if (isDateRangeActive)
                        IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            setState(() {
                              startDate = null;
                              endDate = null;
                            });
                          },
                        ),
                    ],
                  ),
                ),
              ),

              // Amount range slider
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Amount Range'),
                    RangeSlider(
                      values:
                          amountRange ?? RangeValues(overallMin, overallMax),
                      min: overallMin,
                      max: overallMax <= overallMin
                          ? overallMin + 1
                          : overallMax,
                      divisions: 100,
                      labels: RangeLabels(
                        (amountRange?.start ?? overallMin).toStringAsFixed(0),
                        (amountRange?.end ?? overallMax).toStringAsFixed(0),
                      ),
                      onChanged: (rv) => setState(() => amountRange = rv),
                    ),
                  ],
                ),
              ),

              // Sort controls
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    DropdownButton<String>(
                      value: sortBy,
                      items: const [
                        DropdownMenuItem(value: 'date', child: Text('Date')),
                        DropdownMenuItem(
                          value: 'amount',
                          child: Text('Amount'),
                        ),
                        DropdownMenuItem(value: 'name', child: Text('Name')),
                        DropdownMenuItem(
                          value: 'category',
                          child: Text('Category'),
                        ),
                      ],
                      onChanged: (v) => setState(() => sortBy = v!),
                    ),
                    IconButton(
                      icon: Icon(
                        ascending ? Icons.arrow_upward : Icons.arrow_downward,
                      ),
                      onPressed: () => setState(() => ascending = !ascending),
                    ),
                  ],
                ),
              ),

              // Results
              Expanded(
                child: filtered.isEmpty
                    ? const Center(child: Text('No transactions found'))
                    : ListView.builder(
                        itemCount: filtered.length,
                        itemBuilder: (_, i) => TransactionCard(
                          transaction: filtered[i],
                          horizontalPadding: 16,
                          titleFontSize: 16,
                          subtitleFontSize: 14,
                          amountFontSize: 16,
                        ),
                      ),
              ),
            ],
          ),

          // ---------- GRAPH VIEW ----------
          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Summary top row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Transactions: ${filtered.length}'),
                        Text(
                          'Total: ${filtered.fold<double>(0, (p, t) => p + t.amount).toStringAsFixed(2)}',
                        ),
                      ],
                    ),
                    // Export quick option for graph data
                    IconButton(
                      icon: const Icon(Icons.download),
                      onPressed: () async {
                        final filteredForExport = _applyExtraFilters(
                          global.getFilteredTransactions(
                            category: selectedCategory,
                            startDate: startDate,
                            endDate: endDate,
                            nameQuery: nameQuery,
                            sortBy: sortBy,
                            ascending: ascending,
                            minAmount: amountRange?.start,
                            maxAmount: amountRange?.end,
                          ),
                        );
                        await _exportData(filteredForExport, 'csv');
                      },
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Pie chart card
                Card(
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      children: [
                        const Text(
                          'Spending by Category (expenses only)',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          height: 260,
                          child: pieSections.isEmpty
                              ? const Center(
                                  child: Text('No expense data to show'),
                                )
                              : PieChart(
                                  PieChartData(
                                    sections: pieSections,
                                    centerSpaceRadius: 40,
                                    sectionsSpace: 2,
                                    pieTouchData: PieTouchData(enabled: true),
                                  ),
                                ),
                        ),
                        const SizedBox(height: 12),
                        // Legend
                        Wrap(
                          spacing: 8,
                          runSpacing: 6,
                          children: [
                            for (int i = 0; i < pieCategories.length; i++)
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: 12,
                                    height: 12,
                                    color: _legendColorForIndex(i),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(pieCategories[i]),
                                  const SizedBox(width: 12),
                                ],
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Optional: Top categories list
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Top Categories',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        ..._topCategoryWidgets(filtered),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _legendColorForIndex(int i) {
    final colors = [
      Colors.blue,
      Colors.red,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.yellow.shade700,
      Colors.teal,
      Colors.brown,
    ];
    return colors[i % colors.length];
  }

  List<Widget> _topCategoryWidgets(List<Transactions> filtered) {
    final Map<String, double> map = {};
    for (var t in filtered) {
      if (t.credit == true) continue; // only expenses
      final key = (t.category ?? 'Uncategorized');
      map[key] = (map[key] ?? 0) + t.amount.abs();
    }
    final sorted = map.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    if (sorted.isEmpty) {
      return [const Text('No expense categories')];
    }
    return sorted.take(6).map((e) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 6.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [Text(e.key), Text(e.value.toStringAsFixed(2))],
        ),
      );
    }).toList();
  }
}
