import 'package:business_calculation/utils/transaction_crud/transaction_crud.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show ThemeData, Colors;

import 'components/entity/transactions.dart';

class Global extends ChangeNotifier {
  String _title = 'Home';

  String getAppTitle() => _title;

  void setAppTitle(String title) {
    _title = title;
    notifyListeners(); // 👈 important: updates UI when title changes
  }

  bool _isDarkMode = false;

  bool get isDarkMode => _isDarkMode;
  final ThemeData _lightTheme = ThemeData(
    primarySwatch: Colors.blue,
    brightness: Brightness.light,
  );

  final ThemeData _darkTheme = ThemeData(
    primarySwatch: Colors.blue,
    brightness: Brightness.dark,
  );

  ThemeData getTheme() {
    return _isDarkMode ? _darkTheme : _lightTheme;
  }

  // Method to toggle theme mode
  void toggleTheme() {
    _isDarkMode = !_isDarkMode; // Toggle the theme mode
    notifyListeners();
  }

  final TransactionCrud _crud = TransactionCrud();
  bool isLoading = false;
  List<Transactions> transactionList = [];

  //System date
  DateTime _selectedDate = DateTime.now();
  double _monthlyCreditTransactionsSum = 0.0;
  double _monthlyDebitTransactionsSum = 0.0;

  DateTime get selectedDate => _selectedDate;

  void setMonthYear(DateTime newDate) {
    _selectedDate = newDate;
    getTransactionsDetails();
    getCreditMonthlyTransactionSum();
    getDebitMonthlyTransactionSum();
  }

  double get monthlyCreditTransactionsSum => _monthlyCreditTransactionsSum;

  double get monthlyDebitTransactionsSum => _monthlyDebitTransactionsSum;

  Future<void> getTransactionsDetails() async {
    isLoading = true;
    notifyListeners();

    transactionList = await _crud.fetchTransactions(_selectedDate);

    isLoading = false;
    notifyListeners();
  }

  Future<void> addTransaction(Transactions transaction) async {
    await _crud.addTransaction(transaction);
    await getTransactionsDetails();
    await getCreditMonthlyTransactionSum();
    await getDebitMonthlyTransactionSum();
  }

  Future<void> updateTransaction(Transactions transaction) async {
    await _crud.updateTransaction(transaction);
    await getTransactionsDetails();
    await getCreditMonthlyTransactionSum();
    await getDebitMonthlyTransactionSum();
  }

  Future<void> deleteTransaction(String id) async {
    await _crud.deleteTransaction(id);
    await getTransactionsDetails();
    await getCreditMonthlyTransactionSum();
    await getDebitMonthlyTransactionSum();
  }

  Future<void> getCreditMonthlyTransactionSum() async {
    try {
      _monthlyCreditTransactionsSum = await _crud
          .getCreditMonthlyTransactionSum(_selectedDate);
    } catch (e) {
      debugPrint("Error getting transaction sum: $e");
      _monthlyCreditTransactionsSum = 0.0;
    }
    notifyListeners();
  }

  Future<void> getDebitMonthlyTransactionSum() async {
    try {
      _monthlyDebitTransactionsSum = await _crud.getDebitMonthlyTransactionSum(
        _selectedDate,
      );
    } catch (e) {
      debugPrint("Error getting transaction sum: $e");
      _monthlyDebitTransactionsSum = 0.0;
    }
    notifyListeners();
  }

  List<Transactions> getFilteredTransactions({
    String? category,
    DateTime? startDate,
    DateTime? endDate,
    double? minAmount,
    double? maxAmount,
    String? nameQuery,
    String sortBy = 'date', // 'amount', 'name', 'category'
    bool ascending = true,
  }) {
    List<Transactions> filtered = transactionList;

    if (category != null && category.isNotEmpty) {
      filtered = filtered
          .where((t) => t.category?.toLowerCase() == category.toLowerCase())
          .toList();
    }

    if (startDate != null) {
      filtered = filtered.where((t) => !t.date.isBefore(startDate)).toList();
    }

    if (endDate != null) {
      filtered = filtered.where((t) => !t.date.isAfter(endDate)).toList();
    }

    if (minAmount != null) {
      filtered = filtered.where((t) => t.amount >= minAmount).toList();
    }

    if (maxAmount != null) {
      filtered = filtered.where((t) => t.amount <= maxAmount).toList();
    }

    if (nameQuery != null && nameQuery.isNotEmpty) {
      filtered = filtered
          .where((t) => t.name.toLowerCase().contains(nameQuery.toLowerCase()))
          .toList();
    }

    filtered.sort((a, b) {
      int cmp;
      switch (sortBy) {
        case 'amount':
          cmp = a.amount.compareTo(b.amount);
          break;
        case 'name':
          cmp = a.name.compareTo(b.name);
          break;
        case 'category':
          cmp = (a.category ?? '').compareTo(b.category ?? '');
          break;
        default: // date
          cmp = a.date.compareTo(b.date);
      }
      return ascending ? cmp : -cmp;
    });

    return filtered;
  }
}
