import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../Global.dart';
import '../../../utils/date_picker/month_year_picker.dart';
import '../../entity/transactions.dart';
import 'AnalysisUtils.dart';
import 'graph/top_names_screen.dart';

class AnalysisGraphView extends StatefulWidget {
  final List<Transactions> filtered;

  const AnalysisGraphView({super.key, required this.filtered});

  @override
  State<AnalysisGraphView> createState() => _AnalysisGraphViewState();
}

class _AnalysisGraphViewState extends State<AnalysisGraphView> {
  final MonthYearPicker b = MonthYearPicker();

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
    final utils = AnalysisUtils();
    final global = Provider.of<Global>(context);
    final currentMonth = global.selectedDate;

    // 🔹 Filter transactions by selected month
    final filtered = widget.filtered
        .where(
          (t) =>
              t.date.month == currentMonth.month &&
              t.date.year == currentMonth.year,
        )
        .toList();

    final pieSections = utils.pieSections(filtered);

    // 🔹 Group by category and name
    final categoryMap = <String, double>{};
    final nameMap = <String, double>{};

    for (var t in filtered) {
      if (t.credit == true) continue;
      final cat = t.category ?? 'Uncategorized';
      final name = (t.name ?? t.name ?? 'Untitled').trim();

      categoryMap[cat] = (categoryMap[cat] ?? 0) + t.amount.abs();
      nameMap[name] = (nameMap[name] ?? 0) + t.amount.abs();
    }

    final sortedCategories = categoryMap.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final sortedNames = nameMap.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final total = filtered.fold<double>(0, (a, t) => a + t.amount.abs());

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 🔹 Header Summary
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Transactions: ${filtered.length}',
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
              Text(
                'Total: ₹${total.toStringAsFixed(2)}',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // 🔹 Month Selector
          Center(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
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
            ),
          ),
          const SizedBox(height: 12),

          // 🔹 Pie Chart
          _pieChart(pieSections),
          const SizedBox(height: 16),

          // 🔹 Top Categories by Category
          _buildTopGroupCard(
            title: 'Top Categories (by Category)',
            entries: sortedCategories.take(5).toList(),
          ),
          const SizedBox(height: 12),

          // 🔹 Top Categories by Name
          _buildTopGroupCard(
            title: 'Top Categories (by Name)',
            entries: sortedNames.take(5).toList(),
            showViewAll: true,
            onViewAllTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const TopNamesScreen()),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _pieChart(List<PieChartSectionData> sections) => Card(
    elevation: 2,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    child: Padding(
      padding: const EdgeInsets.all(12),
      child: sections.isEmpty
          ? const Center(child: Text('No expense data available'))
          : SizedBox(
              height: 250,
              child: PieChart(
                PieChartData(
                  sections: sections,
                  centerSpaceRadius: 40,
                  sectionsSpace: 2,
                ),
              ),
            ),
    ),
  );

  Widget _buildTopGroupCard({
    required String title,
    required List<MapEntry<String, double>> entries,
    bool showViewAll = false,
    VoidCallback? onViewAllTap,
  }) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                if (showViewAll && onViewAllTap != null)
                  TextButton(
                    onPressed: onViewAllTap,
                    child: const Text(
                      'View All',
                      style: TextStyle(
                        color: Colors.blue,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            if (entries.isEmpty)
              const Text(
                'No data available',
                style: TextStyle(color: Colors.grey),
              )
            else
              ...entries.map(
                (e) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 3),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          e.key,
                          style: const TextStyle(fontSize: 13),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        '₹${e.value.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
