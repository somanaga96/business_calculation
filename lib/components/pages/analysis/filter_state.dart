import 'package:flutter/material.dart';

class FilterState {
  final String? selectedCategory;
  final String sortBy;
  final bool ascending;
  final String nameQuery;
  final DateTime? startDate;
  final DateTime? endDate;
  final String transactionType;
  final String paymentMode;
  final RangeValues? amountRange;

  FilterState({
    this.selectedCategory,
    this.sortBy = 'date',
    this.ascending = true,
    this.nameQuery = '',
    this.startDate,
    this.endDate,
    this.transactionType = 'All',
    this.paymentMode = 'All',
    this.amountRange,
  });
}
