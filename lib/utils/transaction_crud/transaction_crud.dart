import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../components/entity/transactions.dart';

class TransactionCrud extends ChangeNotifier {
  final CollectionReference<Map<String, dynamic>> collection = FirebaseFirestore
      .instance
      .collection('transanction');

  /// Fetch transactions for a given month
  Future<List<Transactions>> fetchTransactions(DateTime date) async {
    List<Transactions> objectList = [];
    try {
      DateTime firstDayOfMonth = DateTime(date.year, date.month, 1);
      DateTime lastDayOfMonth = DateTime(
        date.year,
        date.month + 1,
        1,
      ).subtract(const Duration(seconds: 1));

      QuerySnapshot<Map<String, dynamic>> querySnapshot = await collection
          .where(
            'date',
            isGreaterThanOrEqualTo: Timestamp.fromDate(firstDayOfMonth),
          )
          .where(
            'date',
            isLessThanOrEqualTo: Timestamp.fromDate(lastDayOfMonth),
          )
          .orderBy('date', descending: true)
          .get();

      for (var doc in querySnapshot.docs) {
        objectList.add(Transactions.fromMap(doc.id, doc.data()));
      }
    } catch (e) {
      debugPrint("Error fetching transactions: $e");
    }
    return objectList;
  }

  /// Add a new transaction
  Future<void> addTransaction(Transactions transaction) async {
    try {
      await collection.add(transaction.toMap());
      debugPrint("✅ Transaction added successfully");
    } catch (e) {
      debugPrint("❌ Error adding transaction: $e");
    }
  }

  /// Update an existing transaction
  Future<void> updateTransaction(Transactions transaction) async {
    try {
      await collection.doc(transaction.id).update(transaction.toMap());
      debugPrint("✅ Transaction updated successfully");
    } catch (e) {
      debugPrint("❌ Error updating transaction: $e");
    }
  }

  /// Delete a transaction
  Future<void> deleteTransaction(String id) async {
    try {
      await collection.doc(id).delete();
      debugPrint("✅ Transaction deleted successfully");
    } catch (e) {
      debugPrint("❌ Error deleting transaction: $e");
    }
  }

  /// Fetch transactions credit sum for a given month
  Future<double> getCreditMonthlyTransactionSum(DateTime date) async {
    double totalAmount = 0.0;

    try {
      DateTime firstDayOfMonth = DateTime(date.year, date.month, 1);
      DateTime lastDayOfMonth = DateTime(
        date.year,
        date.month + 1,
        1,
      ).subtract(const Duration(microseconds: 1)); // safer

      QuerySnapshot<Map<String, dynamic>> querySnapshot = await collection
          .where(
            'date',
            isGreaterThanOrEqualTo: Timestamp.fromDate(firstDayOfMonth),
          )
          .where(
            'date',
            isLessThanOrEqualTo: Timestamp.fromDate(lastDayOfMonth),
          )
          .where('credit', isEqualTo: true)
          .get();

      for (var doc in querySnapshot.docs) {
        // Assuming `amount` is stored as num (int/double)
        final amount = doc.data()['price'];
        if (amount != null) {
          totalAmount += (amount as num).toDouble();
        }
      }
    } catch (e) {
      debugPrint("Error calculating transaction sum: $e");
    }
    return totalAmount;
  }

  /// Fetch transactions debit sum for a given month
  Future<double> getDebitMonthlyTransactionSum(DateTime date) async {
    double totalAmount = 0.0;

    try {
      DateTime firstDayOfMonth = DateTime(date.year, date.month, 1);
      DateTime lastDayOfMonth = DateTime(
        date.year,
        date.month + 1,
        1,
      ).subtract(const Duration(microseconds: 1)); // safer

      QuerySnapshot<Map<String, dynamic>> querySnapshot = await collection
          .where(
            'date',
            isGreaterThanOrEqualTo: Timestamp.fromDate(firstDayOfMonth),
          )
          .where(
            'date',
            isLessThanOrEqualTo: Timestamp.fromDate(lastDayOfMonth),
          )
          .where('credit', isEqualTo: false)
          .get();

      for (var doc in querySnapshot.docs) {
        // Assuming `amount` is stored as num (int/double)
        final amount = doc.data()['price'];
        if (amount != null) {
          totalAmount += (amount as num).toDouble();
        }
      }
    } catch (e) {
      debugPrint("Error calculating transaction sum: $e");
    }
    return totalAmount;
  }
}
