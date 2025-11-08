import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

import '../../Global.dart';
import '../../utils/icons/category_item.dart';
import '../entity/transactions.dart';
import 'add_edit_transaction_screen.dart';

class BusinessTransactions extends StatefulWidget {
  const BusinessTransactions({super.key});

  @override
  State<BusinessTransactions> createState() => _BusinessTransactionsState();
}

class _BusinessTransactionsState extends State<BusinessTransactions> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) =>
          Provider.of<Global>(context, listen: false).getTransactionsDetails(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    double horizontalPadding = screenWidth * 0.04;
    double titleFontSize = screenWidth * 0.045;
    double subtitleFontSize = screenWidth * 0.035;
    double amountFontSize = screenWidth * 0.045;
    double cardSpacing = screenHeight * 0.001;

    return Consumer<Global>(
      builder: (context, global, _) {
        if (global.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        return RefreshIndicator(
          onRefresh: () async {
            await global.getTransactionsDetails();
          },
          child: global.transactionList.isEmpty
              ? ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  children: [
                    SizedBox(height: screenHeight * 0.1),
                    Center(
                      child: Text(
                        'No live transactions are available.',
                        style: TextStyle(
                          fontSize: subtitleFontSize,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  ],
                )
              : ListView.separated(
                  physics: const AlwaysScrollableScrollPhysics(),
                  itemCount: global.transactionList.length,
                  separatorBuilder: (_, __) => SizedBox(height: cardSpacing),
                  itemBuilder: (context, index) {
                    final transaction = global.transactionList[index];
                    return TransactionCard(
                      transaction: transaction,
                      horizontalPadding: horizontalPadding,
                      titleFontSize: titleFontSize,
                      subtitleFontSize: subtitleFontSize,
                      amountFontSize: amountFontSize,
                      onEdit: () async {
                        final updatedTransaction = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => AddEditTransactionScreen(
                              transaction: transaction,
                            ),
                          ),
                        );

                        if (updatedTransaction != null) {
                          global.updateTransaction(updatedTransaction);
                        }
                      },
                      onDelete: () {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Delete Transaction'),
                            content: const Text(
                              'Are you sure you want to delete this transaction?',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () {
                                  global.deleteTransaction(transaction.id);
                                  Navigator.pop(context);
                                },
                                child: const Text(
                                  'Delete',
                                  style: TextStyle(color: Colors.red),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                ),
        );
      },
    );
  }
}

class TransactionCard extends StatelessWidget {
  final Transactions transaction;
  final double horizontalPadding;
  final double titleFontSize;
  final double subtitleFontSize;
  final double amountFontSize;
  final Function()? onEdit;
  final Function()? onDelete;

  const TransactionCard({
    super.key,
    required this.transaction,
    required this.horizontalPadding,
    required this.titleFontSize,
    required this.subtitleFontSize,
    required this.amountFontSize,
    this.onEdit,
    this.onDelete,
  });

  IconData getCategoryIcon(String? category) {
    final matched = kCategories.firstWhere(
      (c) => c.name.toLowerCase() == category?.toLowerCase(),
      orElse: () => const CategoryItem('Other', Icons.category),
    );
    return matched.icon;
  }

  @override
  Widget build(BuildContext context) {
    final dateFormatted = DateFormat('d-MMM-yy').format(transaction.date);
    final categoryIcon = getCategoryIcon(transaction.category);

    // ✅ Determine colors based on credit flag
    final isCredit = transaction.credit == true;
    final amountColor = isCredit ? Colors.green[700] : Colors.red[700];
    final cardColor = isCredit ? Colors.green[50] : Colors.red[50];

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
      child: Slidable(
        key: ValueKey(transaction.id),
        endActionPane: ActionPane(
          motion: const ScrollMotion(),
          extentRatio: 0.4,
          children: [
            SlidableAction(
              onPressed: (_) => onEdit?.call(),
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              icon: Icons.edit,
              label: 'Edit',
            ),
            SlidableAction(
              onPressed: (_) => onDelete?.call(),
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              icon: Icons.delete,
              label: 'Delete',
            ),
          ],
        ),
        child: Card(
          elevation: 2,
          color: cardColor, // ✅ Light tint based on credit/debit
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 8.0,
              vertical: 10.0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 🔹 Transaction Name
                Text(
                  transaction.name,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: titleFontSize * 0.9,
                    color: Colors.black87,
                  ),
                ),
                if (transaction.notes.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 2.0),
                    child: Text(
                      transaction.notes,
                      style: TextStyle(
                        fontWeight: FontWeight.w400,
                        fontSize: subtitleFontSize * 0.8,
                        color: Colors.grey[700],
                      ),
                    ),
                  ),

                const SizedBox(height: 6),

                // 🔹 Category and Amount Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          categoryIcon,
                          color: Colors.grey[700],
                          size: subtitleFontSize * 0.95,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          transaction.category?.isNotEmpty == true
                              ? transaction.category!
                              : 'Other',
                          style: TextStyle(
                            fontSize: subtitleFontSize * 0.8,
                            color: Colors.grey[700],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      "₹${transaction.amount.toStringAsFixed(2)}",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: amountFontSize * 0.9,
                        color: amountColor, // ✅ Red or Green
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 6),

                // 🔹 Date
                Align(
                  alignment: Alignment.bottomRight,
                  child: Text(
                    dateFormatted,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: subtitleFontSize * 0.75,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
