import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../Global.dart';
import '../../utils/date_picker/month_year_picker.dart';
import '../cards/purchase_income_card.dart';
import '../transactions/business_transactions.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final MonthYearPicker b = MonthYearPicker();

  @override
  void initState() {
    super.initState();
    // ✅ Set global title once the widget is created
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final global = Provider.of<Global>(context, listen: false);
      global.setAppTitle('Home');
    });
  }

  void _changeMonth(Global global, int delta) {
    setState(() {
      final newDate = DateTime(
        global.selectedDate.year,
        global.selectedDate.month + delta,
      );
      global.setMonthYear(newDate);
    });
  }

  @override
  Widget build(BuildContext context) {
    final global = Provider.of<Global>(context);

    return Scaffold(
      body: Column(
        children: [
          const PurchaseIncomeCard(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Left arrow
                IconButton(
                  icon: const Icon(Icons.chevron_left),
                  onPressed: () => _changeMonth(global, -1),
                ),
                // Month display button
                ElevatedButton(
                  onPressed: () => b.pickMonthYear(context, global),
                  child: Text(
                    DateFormat('MMM/yyyy').format(global.selectedDate),
                  ),
                ),
                // Right arrow
                IconButton(
                  icon: const Icon(Icons.chevron_right),
                  onPressed: () => _changeMonth(global, 1),
                ),
              ],
            ),
          ),
          Expanded(child: const BusinessTransactions()),
        ],
      ),
    );
  }
}
