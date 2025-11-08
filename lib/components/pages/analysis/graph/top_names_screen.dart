import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../../Global.dart';
import '../../../../utils/date_picker/month_year_picker.dart';

class TopNamesScreen extends StatefulWidget {
  const TopNamesScreen({super.key});

  @override
  State<TopNamesScreen> createState() => _TopNamesScreenState();
}

class _TopNamesScreenState extends State<TopNamesScreen> {
  final MonthYearPicker b = MonthYearPicker();
  String searchQuery = '';

  void _changeMonth(Global global, int delta) {
    final newDate = DateTime(
      global.selectedDate.year,
      global.selectedDate.month + delta,
    );
    global.setMonthYear(newDate);
  }

  List<MapEntry<String, double>> _getTopNames(Global global) {
    // Filter based on month & year
    final filtered = global.transactionList.where(
      (t) =>
          t.date.year == global.selectedDate.year &&
          t.date.month == global.selectedDate.month &&
          (t.credit != true),
    );

    final nameMap = <String, double>{};
    for (var t in filtered) {
      final name = (t.name ?? t.name ?? 'Untitled').trim();
      nameMap[name] = (nameMap[name] ?? 0) + t.amount.abs();
    }

    final sorted = nameMap.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    if (searchQuery.isNotEmpty) {
      return sorted
          .where((e) => e.key.toLowerCase().contains(searchQuery))
          .toList();
    }
    return sorted;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<Global>(
      builder: (context, global, child) {
        final topNames = _getTopNames(global);
        final totalAmount = topNames.fold<double>(0, (sum, e) => sum + e.value);

        return Scaffold(
          backgroundColor: Colors.grey.shade50,
          appBar: AppBar(
            title: const Text('Top Categories by Name'),
            backgroundColor: Colors.blue,
          ),
          body: Column(
            children: [
              // 🔹 Month Navigation
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.chevron_left),
                      onPressed: () => _changeMonth(global, -1),
                    ),
                    ElevatedButton(
                      onPressed: () => b.pickMonthYear(context, global),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        DateFormat('MMM/yyyy').format(global.selectedDate),
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.chevron_right),
                      onPressed: () => _changeMonth(global, 1),
                    ),
                  ],
                ),
              ),

              // 🔹 Search Bar
              Padding(
                padding: const EdgeInsets.all(12),
                child: TextField(
                  onChanged: (q) =>
                      setState(() => searchQuery = q.toLowerCase()),
                  decoration: InputDecoration(
                    hintText: 'Search by name...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
              ),

              // 🔹 Summary
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 4,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Total Names: ${topNames.length}'),
                    Text(
                      'Total: ₹${totalAmount.toStringAsFixed(2)}',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),

              // 🔹 List of Names
              Expanded(
                child: topNames.isEmpty
                    ? const Center(
                        child: Text(
                          'No data available',
                          style: TextStyle(color: Colors.grey, fontSize: 16),
                        ),
                      )
                    : ListView.separated(
                        itemCount: topNames.length,
                        separatorBuilder: (_, __) => const Divider(height: 1),
                        itemBuilder: (context, index) {
                          final entry = topNames[index];
                          final percent = totalAmount == 0
                              ? 0
                              : (entry.value / totalAmount * 100);

                          return ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Colors.blue.shade50,
                              child: Text(
                                entry.key.isNotEmpty
                                    ? entry.key[0].toUpperCase()
                                    : '?',
                                style: const TextStyle(color: Colors.blue),
                              ),
                            ),
                            title: Text(
                              entry.key,
                              style: const TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 14,
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                LinearProgressIndicator(
                                  value: percent / 100,
                                  backgroundColor: Colors.grey.shade300,
                                  color: Colors.blue,
                                  minHeight: 4,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${percent.toStringAsFixed(1)}% of total',
                                  style: const TextStyle(fontSize: 12),
                                ),
                              ],
                            ),
                            trailing: Text(
                              '₹${entry.value.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}
