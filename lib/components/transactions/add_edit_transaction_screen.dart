import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../entity/product_item.dart';
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
  final TextEditingController dateController = TextEditingController();

  DateTime? selectedDate;
  String? selectedProduct;
  bool isCredit = false; // ✅ Default to Debit (செலவு)

  final CollectionReference productsCollection = FirebaseFirestore.instance
      .collection('products');

  List<String> productList = [];
  bool isLoadingProducts = true;

  // --- Firestore: add new product dialog ---
  Future<void> _addNewProductDialog(BuildContext context) async {
    final TextEditingController productController = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Add New Product"),
          content: TextField(
            controller: productController,
            decoration: const InputDecoration(
              labelText: "Product Name",
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () async {
                final newProduct = productController.text.trim();
                if (newProduct.isNotEmpty) {
                  await _saveNewProductToFirestore(newProduct);
                  setState(() {
                    selectedProduct = newProduct;
                    productList.add(newProduct);
                  });
                  Navigator.pop(context);
                }
              },
              child: const Text("Add"),
            ),
          ],
        );
      },
    );
  }

  // --- Save new product to Firestore ---
  Future<void> _saveNewProductToFirestore(String name) async {
    try {
      final matchedIcon = kProducts.firstWhere(
        (p) => p.name.toLowerCase() == name.toLowerCase(),
        orElse: () => const ProductItem(name: '', icon: Icons.shopping_cart),
      );

      await productsCollection.add({
        'name': name,
        'icon': matchedIcon.icon.codePoint,
        'iconFontFamily': matchedIcon.icon.fontFamily,
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("✅ '$name' added successfully")));
    } catch (e) {
      debugPrint("Error adding product: $e");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("❌ Failed to add product")));
    }
  }

  // --- Load products from Firestore once ---
  Future<void> _loadProducts() async {
    try {
      QuerySnapshot snapshot = await productsCollection.get();
      final products = snapshot.docs
          .map((doc) => doc['name'].toString())
          .toList();

      setState(() {
        productList = products;
        isLoadingProducts = false;

        // ✅ Default to first product if none selected
        if (selectedProduct == null && products.isNotEmpty) {
          selectedProduct = products.first;
        }
      });
    } catch (e) {
      debugPrint("Error fetching products: $e");
      setState(() => isLoadingProducts = false);
    }
  }

  // --- Pick date ---
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

  @override
  void initState() {
    super.initState();

    if (widget.transaction != null) {
      final t = widget.transaction!;
      amountController.text = t.amount.toString();
      noteController.text = t.notes;
      selectedDate = t.date;
      dateController.text = DateFormat('dd-MM-yyyy').format(t.date);
      selectedProduct = t.name;
      isCredit = t.category == 'Credit'; // reuse category
    } else {
      selectedDate = DateTime.now();
      dateController.text = DateFormat('dd-MM-yyyy').format(selectedDate!);
      isCredit = false; // Default to செலவு
    }

    _loadProducts();
  }

  // --- Save Transaction ---
  void _saveTransaction() {
    final name = selectedProduct?.trim() ?? '';
    final amount = amountController.text.trim();

    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("⚠️ Please select a product")),
      );
      return;
    }

    if (amount.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("⚠️ Please enter an amount")),
      );
      return;
    }

    if (selectedDate == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("⚠️ Please select a date")));
      return;
    }

    final transaction = Transactions(
      id: widget.transaction?.id ?? '',
      name: name,
      amount: int.tryParse(amount) ?? 0,
      notes: noteController.text.trim(),
      category: isCredit ? 'Credit' : 'Debit',
      credit: isCredit,
      // Store type
      date: selectedDate!,
    );

    Navigator.pop(context, transaction);
  }

  // --- Build ---
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
        child: isLoadingProducts
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: EdgeInsets.all(padding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 🔹 Product Dropdown
                    DropdownButtonFormField<String>(
                      value: selectedProduct,
                      decoration: const InputDecoration(
                        labelText: 'Select Product *',
                        border: OutlineInputBorder(),
                      ),
                      items: [
                        ...productList.map((name) {
                          final productIcon = kProducts
                              .firstWhere(
                                (p) =>
                                    p.name.toLowerCase() == name.toLowerCase(),
                                orElse: () => const ProductItem(
                                  name: '',
                                  icon: Icons.shopping_cart,
                                ),
                              )
                              .icon;

                          return DropdownMenuItem<String>(
                            value: name,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(productIcon, size: 22),
                                const SizedBox(width: 10),
                                Flexible(
                                  child: Text(
                                    name,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
                        if (productList.isNotEmpty)
                          const DropdownMenuItem<String>(
                            enabled: false,
                            child: Divider(thickness: 1),
                          ),
                        const DropdownMenuItem<String>(
                          value: "__add_new__",
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.add, color: Colors.green),
                              SizedBox(width: 10),
                              Text("➕ Add New Product"),
                            ],
                          ),
                        ),
                      ],
                      onChanged: (value) async {
                        if (value == "__add_new__") {
                          await _addNewProductDialog(context);
                        } else {
                          setState(() {
                            selectedProduct = value;
                          });
                        }
                      },
                    ),

                    SizedBox(height: verticalSpacing),

                    // 🔹 Amount
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

                    // 🔹 வரவு / செலவு Toggle
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      curve: Curves.easeInOut,
                      height: 48,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30),
                        color: Colors.grey.shade200,
                        border: Border.all(color: Colors.grey.shade400),
                      ),
                      child: Stack(
                        children: [
                          AnimatedAlign(
                            alignment: isCredit
                                ? Alignment.centerLeft
                                : Alignment.centerRight,
                            duration: const Duration(milliseconds: 250),
                            curve: Curves.easeInOut,
                            child: Container(
                              width: MediaQuery.of(context).size.width * 0.38,
                              margin: const EdgeInsets.symmetric(
                                horizontal: 4,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: isCredit ? Colors.green : Colors.red,
                                borderRadius: BorderRadius.circular(25),
                              ),
                            ),
                          ),
                          Row(
                            children: [
                              // வரவு (Credit)
                              Expanded(
                                child: GestureDetector(
                                  onTap: () => setState(() => isCredit = true),
                                  child: Container(
                                    height: 48,
                                    alignment: Alignment.center,
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.arrow_downward_rounded,
                                          size: 18,
                                          color: isCredit
                                              ? Colors.white
                                              : Colors.grey.shade700,
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          "வரவு",
                                          style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                            color: isCredit
                                                ? Colors.white
                                                : Colors.grey.shade700,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              // செலவு (Debit)
                              Expanded(
                                child: GestureDetector(
                                  onTap: () => setState(() => isCredit = false),
                                  child: Container(
                                    height: 48,
                                    alignment: Alignment.center,
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.arrow_upward_rounded,
                                          size: 18,
                                          color: !isCredit
                                              ? Colors.white
                                              : Colors.grey.shade700,
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          "செலவு",
                                          style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                            color: !isCredit
                                                ? Colors.white
                                                : Colors.grey.shade700,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: verticalSpacing),

                    // 🔹 Date Picker
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

                    // 🔹 Note
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

                    // 🔹 Buttons
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
