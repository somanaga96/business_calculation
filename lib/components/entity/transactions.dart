import 'dart:ffi';

import 'package:cloud_firestore/cloud_firestore.dart';

class Transactions {
  String id;
  int amount;
  DateTime date;
  String notes;
  String name;
  String? category; 
  bool? credit;

  Transactions({
    required this.id,
    required this.amount,
    required this.date,
    required this.notes,
    required this.name,
    this.category, 
    this.credit,
  });

  factory Transactions.fromMap(String id, Map<String, dynamic> map) {
    DateTime dateTime = map['date'] is Timestamp
        ? (map['date'] as Timestamp).toDate()
        : map['date'];

    return Transactions(
      id: id,
      amount: map['price'],
      date: dateTime,
      notes: map['comment'] ?? '',
      name: map['name'] ?? '',
      category: map['category'] ?? 'other', // Default to empty string if null
      credit: map['credit']
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'price': amount,
      'date': Timestamp.fromDate(date),
      'comment': notes,
      'name': name,
      'category': category ?? 'other', // Ensure non-null when saving
      'credit':credit
    };
  }
}
