import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../Global.dart';

class ProfitCard extends StatelessWidget {
  const ProfitCard({super.key});

  @override
  Widget build(BuildContext context) {
    final global = Provider.of<Global>(context);
    final profit =
        global.monthlyCreditTransactionsSum - global.monthlyDebitTransactionsSum;

    // Determine color based on profit/loss
    final isProfit = profit >= 0;
    final cardColor = isProfit ? Colors.green[100]! : Colors.red[100]!;

    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      color: cardColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // 🧾 Label and description
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "மொத்த வருமானம்",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isProfit ? Colors.green[900] : Colors.red[900],
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  isProfit ? "நீங்கள் லாபத்தில் உள்ளீர்கள் :" : "நீங்கள் இழப்பில் உள்ளீர்கள்",
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[800],
                  ),
                ),
              ],
            ),

            // 💰 Amount
            Text(
              '₹${profit.toStringAsFixed(2)}',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: isProfit ? Colors.green[900] : Colors.red[900],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
