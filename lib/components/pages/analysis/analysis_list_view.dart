import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../Global.dart';
import '../../../utils/icons/category_item.dart';
import '../../transactions/business_transactions.dart';
import 'filter_state.dart';

class AnalysisListView extends StatelessWidget {
  final Global global;
  final String? selectedCategory;
  final DateTime? startDate;
  final DateTime? endDate;
  final String nameQuery;
  final String sortBy;
  final bool ascending;
  final String transactionType;
  final String paymentMode;
  final RangeValues? amountRange;
  final Function(FilterState) onFiltersUpdated;

  const AnalysisListView({
    super.key,
    required this.global,
    required this.selectedCategory,
    required this.startDate,
    required this.endDate,
    required this.nameQuery,
    required this.sortBy,
    required this.ascending,
    required this.transactionType,
    required this.paymentMode,
    required this.amountRange,
    required this.onFiltersUpdated,
  });

  @override
  Widget build(BuildContext context) {
    final filtered = global.getFilteredTransactions(
      category: selectedCategory,
      startDate: startDate,
      endDate: endDate,
      nameQuery: nameQuery,
      sortBy: sortBy,
      ascending: ascending,
      minAmount: amountRange?.start,
      maxAmount: amountRange?.end,
    );

    return Column(
      children: [
        _buildFilterRow(context),
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
    );
  }

  Widget _buildFilterRow(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Row(
        children: [
          DropdownButton<String>(
            hint: const Text('Category'),
            value: selectedCategory,
            items: kCategories
                .map((c) => DropdownMenuItem(
              value: c.name,
              child: Row(
                children: [
                  Icon(c.icon, size: 20),
                  const SizedBox(width: 6),
                  Text(c.name),
                ],
              ),
            ))
                .toList(),
            onChanged: (v) =>
                onFiltersUpdated(FilterState(selectedCategory: v)),
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: 150,
            child: TextField(
              decoration: const InputDecoration(labelText: 'Search'),
              onChanged: (v) =>
                  onFiltersUpdated(FilterState(nameQuery: v)),
            ),
          ),
        ],
      ),
    );
  }
}
