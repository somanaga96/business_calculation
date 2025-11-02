import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../utils/icons/category_item.dart';
import '../entity/transactions.dart';


class AddEditTransactionScreen extends StatefulWidget {
  final Transactions? transaction; // null = add, non-null = edit

  const AddEditTransactionScreen({super.key, this.transaction});

  @override
  State<AddEditTransactionScreen> createState() =>
      _AddEditTransactionScreenState();
}

class _AddEditTransactionScreenState extends State<AddEditTransactionScreen> {
  final TextEditingController amountController = TextEditingController();
  final TextEditingController noteController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController dateController = TextEditingController();

  String? selectedCategory;
  DateTime? selectedDate;

  final List<String> categories = ['Bills', 'Fuel', 'Electricity', 'Other'];

  @override
  void initState() {
    super.initState();

    if (widget.transaction != null) {
      // Pre-fill for edit
      final t = widget.transaction!;
      nameController.text = t.name;
      amountController.text = t.amount.toString();
      noteController.text = t.notes;
      selectedDate = t.date;
      dateController.text = DateFormat('dd-MM-yyyy').format(t.date);

      selectedCategory =
      (t.category != null && t.category!.isNotEmpty)
          ? categories.firstWhere(
            (c) => c.toLowerCase() == t.category!.toLowerCase(),
        orElse: () => 'Other',
      )
          : 'Other';
    } else {
      // Default values for new transaction
      selectedCategory = 'Other';
      selectedDate = DateTime.now(); // default to today
      dateController.text = DateFormat(
        'dd-MM-yyyy',
      ).format(selectedDate!); // show today
    }
  }

  Future<void> _pickDate(BuildContext context) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? now,
      firstDate: DateTime(now.year - 2),
      lastDate: DateTime(now.year + 2),
    );

    if (picked != null) {
      setState(() {
        selectedDate = picked;
        dateController.text = DateFormat('dd-MM-yyyy').format(picked);
      });
    }
  }

  void _saveTransaction() {
    final name = nameController.text.trim();
    final amount = amountController.text.trim();

    if (name.isEmpty ||
        amount.isEmpty ||
        selectedCategory == null ||
        selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "⚠️ Please fill all required fields (Name, Amount, Category, Date)",
          ),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    final transaction = Transactions(
      id: widget.transaction?.id ?? '',
      name: name,
      amount: int.tryParse(amount) ?? 0,
      notes: noteController.text.trim(),
      category: selectedCategory ?? 'Other',
      date: selectedDate!,
    );

    Navigator.pop(context, transaction);
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final padding = screenWidth * 0.04;
    final textFieldFontSize = screenWidth * 0.04;
    final buttonFontSize = screenWidth * 0.045;
    final verticalSpacing = screenWidth * 0.04;

    final isEdit = widget.transaction != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? "Edit Transaction" : "Add Transaction"),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(padding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Name
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: "Name *",
                  prefixIcon: Icon(Icons.label),
                  border: OutlineInputBorder(),
                ),
                style: TextStyle(fontSize: textFieldFontSize),
              ),
              SizedBox(height: verticalSpacing),

              // Amount
              TextField(
                controller: amountController,
                decoration: const InputDecoration(
                  labelText: "Amount *",
                  prefixIcon: Icon(Icons.currency_rupee),
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                style: TextStyle(fontSize: textFieldFontSize),
              ),
              SizedBox(height: verticalSpacing),
              // // Category Dropdown
              DropdownButtonFormField<CategoryItem>(
                decoration: const InputDecoration(
                  labelText: "Category *",
                  border: OutlineInputBorder(),
                ),
                initialValue: kCategories.firstWhere(
                      (c) => c.name == selectedCategory,
                  orElse: () => kCategories.last, // 'Other'
                ),
                items:
                kCategories.map((cat) {
                  return DropdownMenuItem<CategoryItem>(
                    value: cat,
                    child: Row(
                      children: [
                        Icon(cat.icon, size: 20),
                        const SizedBox(width: 10),
                        Text(cat.name),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedCategory = value?.name;
                  });
                },
              ),
              // DropdownSearchLegacyExample(),
              SizedBox(height: verticalSpacing),
              // Date Picker
              GestureDetector(
                onTap: () => _pickDate(context),
                child: AbsorbPointer(
                  child: TextField(
                    controller: dateController,
                    decoration: const InputDecoration(
                      labelText: "Date *",
                      prefixIcon: Icon(Icons.calendar_today),
                      border: OutlineInputBorder(),
                      hintText: "Select a date",
                    ),
                    style: TextStyle(fontSize: textFieldFontSize),
                  ),
                ),
              ),
              SizedBox(height: verticalSpacing),

              // Note
              TextField(
                controller: noteController,
                decoration: const InputDecoration(
                  labelText: "Note (optional)",
                  prefixIcon: Icon(Icons.note),
                  border: OutlineInputBorder(),
                ),
                style: TextStyle(fontSize: textFieldFontSize),
              ),
              SizedBox(height: verticalSpacing * 2),

              // Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.cancel_outlined),
                      label: Text(
                        "Cancel",
                        style: TextStyle(fontSize: buttonFontSize),
                      ),
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(
                          vertical: screenWidth < 400 ? 10 : 14,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: screenWidth * 0.04),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _saveTransaction,
                      icon: const Icon(Icons.save),
                      label: Text(
                        isEdit ? "Update" : "Add",
                        style: TextStyle(fontSize: buttonFontSize),
                      ),
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(
                          vertical: screenWidth < 400 ? 10 : 14,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
