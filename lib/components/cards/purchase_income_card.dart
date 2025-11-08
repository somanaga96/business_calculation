import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../Global.dart';
import '../pages/analysis/graph/top_names_screen.dart';

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
            // 🔹 வரவு (Income)
            _buildCard(
              title: "வரவு",
              amount: global.monthlyCreditTransactionsSum.toStringAsFixed(2),
              color: Colors.green[100]!,
              screenSize: screenSize,
            ),

            // 🔹 செலவு (Expense) → On tap navigate to TopNamesScreen
            Expanded(
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const TopNamesScreen()),
                  );
                },
                child: _buildCard(
                  title: "செலவு",
                  amount: global.monthlyDebitTransactionsSum.toStringAsFixed(2),
                  color: Colors.red[200]!,
                  screenSize: screenSize,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildCard({
    required String title,
    required String amount,
    required Color color,
    required Size screenSize,
  }) {
    return Card(
      color: color,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: SizedBox(
        width: screenSize.width / 2.1,
        height: screenSize.height / 6,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: screenSize.width / 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '₹$amount',
                style: TextStyle(
                  fontSize: screenSize.width / 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
