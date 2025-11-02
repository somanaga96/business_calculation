// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
//
// class BottomNavigation extends StatefulWidget {
//   const BottomNavigation({super.key});
//
//   @override
//   State<BottomNavigation> createState() => _BottomNavigationState();
// }
//
// class _BottomNavigationState extends State<BottomNavigation> {
//   int _selectedIndex = 0;
//
//   late List<Widget> screen;
//
//   @override
//   void initState() {
//     super.initState();
//     screen = [const Home(), const AnalysisScreen(), const MorePage()];
//   }
//
//   Future<void> _onFabPressed() async {
//     // Navigate to Add/Edit screen
//     final newTransaction = await Navigator.push(
//       context,
//       MaterialPageRoute(builder: (_) => const AddEditTransactionScreen()),
//     );
//
//     if (newTransaction != null) {
//       // Add the new transaction to provider
//       Provider.of<Global>(
//         context,
//         listen: false,
//       ).addTransaction(newTransaction);
//       debugPrint("New transaction added: $newTransaction");
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: screen[_selectedIndex],
//
//       floatingActionButton: FloatingActionButton(
//         onPressed: _onFabPressed,
//         backgroundColor: Colors.blue[800],
//         child: const Icon(Icons.add),
//       ),
//       floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
//
//       bottomNavigationBar: BottomNavigationBar(
//         currentIndex: _selectedIndex,
//         selectedItemColor: Colors.blue[800],
//         unselectedItemColor: Colors.grey,
//         onTap: (index) => setState(() => _selectedIndex = index),
//         selectedFontSize: 16,
//         iconSize: 25,
//         unselectedFontSize: 12,
//         items: const [
//           BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
//           BottomNavigationBarItem(
//             icon: Icon(Icons.analytics),
//             label: 'Analysis',
//           ),
//           BottomNavigationBarItem(icon: Icon(Icons.more_horiz), label: 'more'),
//         ],
//       ),
//     );
//   }
// }
