import 'package:calendar_date_picker2/calendar_date_picker2.dart'
    show
        CalendarDatePicker2WithActionButtonsConfig,
        showCalendarDatePicker2Dialog,
        CalendarDatePicker2Type;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../Global.dart';
import 'AnalysisUtils.dart';
import 'analysis_graph_view.dart';
import '../../entity/transactions.dart';

class AnalysisScreen extends StatefulWidget {
  const AnalysisScreen({super.key});

  @override
  State<AnalysisScreen> createState() => _AnalysisScreenState();
}

class _AnalysisScreenState extends State<AnalysisScreen>
    with SingleTickerProviderStateMixin {
  String? selectedCategory;
  String sortBy = 'amount';
  bool ascending = true;
  String nameQuery = '';
  DateTime? startDate, endDate;
  String transactionType = 'All';
  String paymentMode = 'All';
  RangeValues? amountRange;

  late TabController _tabController;
  final utils = AnalysisUtils();
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final global = Provider.of<Global>(context, listen: false);
      global.setAppTitle('List View');

      _tabController.addListener(() {
        if (_tabController.indexIsChanging) return;
        global.setAppTitle(
          _tabController.index == 0 ? 'List View' : 'Graph View',
        );
      });
    });
  }

  void _resetFilters(double min, double max) {
    setState(() {
      selectedCategory = null;
      transactionType = 'All';
      paymentMode = 'All';
      nameQuery = '';
      _searchController.clear();
      startDate = endDate = null;
      sortBy = 'amount';
      ascending = true;
      amountRange = RangeValues(min.toDouble(), max.toDouble());
    });
  }

  @override
  Widget build(BuildContext context) {
    final global = Provider.of<Global>(context);

    // Apply filters & sorting
    final filtered = utils.applyFilters(
      global,
      category: selectedCategory,
      startDate: startDate,
      endDate: endDate,
      nameQuery: nameQuery,
      sortBy: sortBy,
      ascending: ascending,
      transactionType: transactionType,
      paymentMode: paymentMode,
      amountRange: amountRange,
    );

    final allAmounts = global.transactionList
        .map((t) => t.amount.abs().toDouble())
        .toList();

    final double min = allAmounts.isEmpty
        ? 0.0
        : allAmounts.reduce((a, b) => a < b ? a : b);
    final double max = allAmounts.isEmpty
        ? 1000.0
        : allAmounts.reduce((a, b) => a > b ? a : b);

    amountRange ??= RangeValues(min, max);

    return Scaffold(
      body: Column(
        children: [
          // 🔹 Toolbar Row
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.ios_share),
                  tooltip: 'Export Data',
                  onPressed: () async {
                    final value = await showMenu<String>(
                      context: context,
                      position: const RelativeRect.fromLTRB(50, 80, 10, 100),
                      items: const [
                        PopupMenuItem(
                          value: 'csv',
                          child: Text('Export as CSV'),
                        ),
                        PopupMenuItem(
                          value: 'pdf',
                          child: Text('Export as PDF'),
                        ),
                      ],
                    );
                    if (value != null) {
                      await utils.exportData(context, filtered, value);
                    }
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.refresh),
                  tooltip: 'Reset Filters',
                  onPressed: () => _resetFilters(min, max),
                ),
                const Spacer(),
                Expanded(
                  flex: 2,
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    icon: const Icon(Icons.date_range, size: 20),
                    label: Text(
                      startDate == null && endDate == null
                          ? 'Select Date Range'
                          : '${startDate != null ? "${startDate!.day}/${startDate!.month}/${startDate!.year}" : ''}'
                                ' - '
                                '${endDate != null ? "${endDate!.day}/${endDate!.month}/${endDate!.year}" : ''}',
                      style: const TextStyle(fontSize: 13),
                      overflow: TextOverflow.ellipsis,
                    ),
                    onPressed: () async {
                      final config = CalendarDatePicker2WithActionButtonsConfig(
                        calendarType: CalendarDatePicker2Type.range,
                        selectedDayHighlightColor: Colors.blue,
                        firstDate: DateTime(2000),
                        lastDate: DateTime.now(),
                        currentDate: DateTime.now(),
                        weekdayLabelTextStyle: const TextStyle(
                          fontWeight: FontWeight.w600,
                        ),
                        controlsTextStyle: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        selectedRangeHighlightColor: Colors.blue.shade100,
                      );

                      final values = await showCalendarDatePicker2Dialog(
                        context: context,
                        config: config,
                        dialogSize: const Size(350, 400),
                        borderRadius: BorderRadius.circular(15),
                      );

                      if (values != null && values.length == 2) {
                        setState(() {
                          startDate = values[0];
                          endDate = values[1];
                        });
                      }
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Material(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(12),
                  child: IconButton(
                    icon: const Icon(Icons.filter_alt_rounded),
                    color: Colors.blue,
                    tooltip: 'More Filters',
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Filter panel coming soon'),
                          duration: Duration(seconds: 1),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          // 🔹 Tab bar
          Container(
            color: Colors.grey.shade100,
            child: TabBar(
              controller: _tabController,
              labelColor: Colors.blue,
              unselectedLabelColor: Colors.black54,
              indicatorColor: Colors.blue,
              indicatorWeight: 3,
              labelStyle: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
              tabs: const [
                Tab(icon: Icon(Icons.list), text: 'List View'),
                Tab(icon: Icon(Icons.pie_chart), text: 'Graph View'),
              ],
            ),
          ),

          // 🔹 Tab views
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildTableView(filtered),
                AnalysisGraphView(filtered: filtered),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ✅ Table-style List View with Credit/Debit Colors
  Widget _buildTableView(List<Transactions> transactions) {
    return Column(
      children: [
        // Search + Sort Bar
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          color: Colors.grey.shade100,
          child: Row(
            children: [
              Expanded(
                flex: 2,
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search by Name...',
                    prefixIcon: const Icon(Icons.search),
                    isDense: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onChanged: (value) {
                    setState(() {
                      nameQuery = value;
                    });
                  },
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: Icon(
                  ascending
                      ? Icons.arrow_upward_rounded
                      : Icons.arrow_downward_rounded,
                  size: 22,
                ),
                tooltip: ascending
                    ? 'Sort by Amount (Ascending)'
                    : 'Sort by Amount (Descending)',
                onPressed: () {
                  setState(() {
                    ascending = !ascending;
                  });
                },
              ),
            ],
          ),
        ),

        const Divider(height: 1),

        // Table header
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          color: Colors.grey.shade200,
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Category', style: TextStyle(fontWeight: FontWeight.bold)),
              Text('Amount', style: TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
        ),

        // 🔹 Transaction List with colored rows
        Expanded(
          child: ListView.builder(
            itemCount: transactions.length,
            itemBuilder: (context, index) {
              final t = transactions[index];
              final isCredit = t.credit == true;
              final amountColor = isCredit
                  ? Colors.green[700]
                  : Colors.red[700];
              final tileColor = isCredit ? Colors.green[50] : Colors.red[50];

              return Container(
                color: tileColor,
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  leading: Icon(
                    isCredit
                        ? Icons.arrow_downward_rounded
                        : Icons.arrow_upward_rounded,
                    color: amountColor,
                  ),
                  title: Text(
                    t.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (t.category != null)
                        Text(
                          t.category!,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                            color: Colors.grey,
                          ),
                        ),
                      Text(
                        '${t.date.day}-${t.date.month}-${t.date.year}',
                        style: const TextStyle(
                          fontSize: 11,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  trailing: Text(
                    '₹${t.amount.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: amountColor,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }
}
