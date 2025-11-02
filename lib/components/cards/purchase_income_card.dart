import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../Global.dart';

class PurchaseIncomeCard extends StatefulWidget {
  const PurchaseIncomeCard({super.key});

  @override
  State<PurchaseIncomeCard> createState() => _PurchaseIncomeCardState();
}

class _PurchaseIncomeCardState extends State<PurchaseIncomeCard> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final global = Provider.of<Global>(context, listen: false);
      global.getTransactionsDetails();
      global.getCreditMonthlyTransactionSum();
      global.getDebitMonthlyTransactionSum();
    });
  }

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;

    return Consumer<Global>(
      builder: (context, global, child) {
        return Row(
          children: [
            _buildCard(
              title: "வரவு",
              amount: global.monthlyCreditTransactionsSum.toStringAsFixed(2),
              color: Colors.green[100]!,
              screenSize: screenSize,
            ),
            _buildCard(
              title: "செலவு",
              amount: global.monthlyDebitTransactionsSum.toStringAsFixed(2),
              color: Colors.red[200]!,
              screenSize: screenSize,
            ),
          ],
        );
      },
    );
  }

  Widget _buildCard({
    required String title,
    required String amount,
    // required double total,
    required Color color,
    required Size screenSize,
  }) {
    // double parsedAmount = double.tryParse(amount) ?? 0.0;
    // double remaining = parsedAmount - total;

    return Expanded(
      child: Card(
        color: color,
        child: SizedBox(
          width: screenSize.width / 2.1,
          height: screenSize.height / 6,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: screenSize.width / 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  amount,
                  style: TextStyle(
                    fontSize: screenSize.width / 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                // Text(
                //   remaining.toStringAsFixed(2),
                //   style: TextStyle(
                //     fontSize: screenSize.width / 20,
                //     fontWeight: FontWeight.bold,
                //   ),
                // ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
