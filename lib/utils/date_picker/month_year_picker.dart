import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../Global.dart';

class MonthYearPicker {

  Future<void> pickMonthYear(BuildContext context, Global global) async {
    int selectedMonth = global.selectedDate.month;
    int selectedYear = global.selectedDate.year;

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text("Select Month and Year"),
          content: Row(
            children: [
              DropdownButton<int>(
                value: selectedMonth,
                items: List.generate(12, (i) => i + 1)
                    .map((month) => DropdownMenuItem(
                  value: month,
                  child: Text(DateFormat.MMMM().format(DateTime(0, month))),
                ))
                    .toList(),
                onChanged: (val) {
                  setState(() {
                    selectedMonth = val!;
                  });
                },
              ),
              const SizedBox(width: 10),
              DropdownButton<int>(
                value: selectedYear,
                items: List.generate(
                    DateTime.now().year - 2009, (i) => 2010 + i)
                    .map((year) => DropdownMenuItem(
                  value: year,
                  child: Text(year.toString()),
                ))
                    .toList(),
                onChanged: (val) {
                  setState(() {
                    selectedYear = val!;
                  });
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                global.setMonthYear(DateTime(selectedYear, selectedMonth));
                Navigator.pop(context);
              },
              child: const Text("OK"),
            ),
          ],
        ),
      ),
    );
  }
}