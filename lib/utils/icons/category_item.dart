import 'package:flutter/material.dart';

class CategoryItem {
  final String name;
  final IconData icon;

  const CategoryItem(this.name, this.icon);
}

final List<CategoryItem> kCategories = [
  // 🥘 Food & Drinks
  CategoryItem('Food', Icons.restaurant),
  CategoryItem('Groceries', Icons.local_grocery_store),
  CategoryItem('Cafes', Icons.local_cafe),
  CategoryItem('Snacks', Icons.fastfood),
  CategoryItem('Dining Out', Icons.restaurant_menu),
  CategoryItem('Drinks', Icons.local_bar),

  // 🚗 Transport & Travel
  CategoryItem('Transport', Icons.directions_car),
  CategoryItem('Fuel', Icons.local_gas_station),
  CategoryItem('Taxi', Icons.local_taxi),
  CategoryItem('Public Transport', Icons.train),
  CategoryItem('Flight', Icons.flight),
  CategoryItem('Travel', Icons.card_travel),
  CategoryItem('Parking', Icons.local_parking),
  CategoryItem('Vehicle Maintenance', Icons.build_circle),

  // 🏠 Housing & Utilities
  CategoryItem('Rent', Icons.home),
  CategoryItem('Mortgage', Icons.house),
  CategoryItem('Electricity', Icons.flash_on),
  CategoryItem('Water', Icons.water_drop),
  CategoryItem('Gas', Icons.local_fire_department),
  CategoryItem('Internet', Icons.wifi),
  CategoryItem('Phone Bill', Icons.phone_android),
  CategoryItem('Repairs & Maintenance', Icons.home_repair_service),
  CategoryItem('Property Tax', Icons.account_balance),

  // 💳 Bills & Payments
  CategoryItem('Bills', Icons.receipt_long),
  CategoryItem('Subscriptions', Icons.subscriptions),
  CategoryItem('Insurance', Icons.health_and_safety),
  CategoryItem('Loan Payment', Icons.request_quote),
  CategoryItem('Credit Card', Icons.credit_card),

  // 🛍️ Shopping & Personal
  CategoryItem('Shopping', Icons.shopping_bag),
  CategoryItem('Clothing', Icons.checkroom),
  CategoryItem('Electronics', Icons.devices),
  CategoryItem('Cosmetics', Icons.brush),
  CategoryItem('Accessories', Icons.watch),
  CategoryItem('Personal Care', Icons.spa),

  // 🩺 Health & Fitness
  CategoryItem('Health', Icons.local_hospital),
  CategoryItem('Medicine', Icons.medical_services),
  CategoryItem('Doctor', Icons.health_and_safety),
  CategoryItem('Gym', Icons.fitness_center),
  CategoryItem('Sports', Icons.sports_soccer),
  CategoryItem('Yoga', Icons.self_improvement),

  // 🎬 Entertainment & Leisure
  CategoryItem('Entertainment', Icons.movie),
  CategoryItem('Movies', Icons.local_movies),
  CategoryItem('Music', Icons.music_note),
  CategoryItem('Games', Icons.sports_esports),
  CategoryItem('Streaming', Icons.tv),
  CategoryItem('Books', Icons.menu_book),
  CategoryItem('Hobbies', Icons.palette),
  CategoryItem('Events', Icons.event),

  // 🎓 Education
  CategoryItem('Education', Icons.school),
  CategoryItem('Tuition', Icons.menu_book),
  CategoryItem('Courses', Icons.computer),
  CategoryItem('Books & Stationery', Icons.book),
  CategoryItem('Online Learning', Icons.cast_for_education),

  // 💰 Income Sources
  CategoryItem('Salary', Icons.attach_money),
  CategoryItem('Bonus', Icons.card_giftcard),
  CategoryItem('Freelance', Icons.work),
  CategoryItem('Investments', Icons.trending_up),
  CategoryItem('Rental Income', Icons.real_estate_agent),
  CategoryItem('Dividends', Icons.pie_chart),
  CategoryItem('Refunds', Icons.money_off),
  CategoryItem('Interest', Icons.savings),

  // 🎁 Gifts & Donations
  CategoryItem('Gift', Icons.card_giftcard),
  CategoryItem('Charity', Icons.volunteer_activism),
  CategoryItem('Donations', Icons.favorite),
  CategoryItem('Family Support', Icons.family_restroom),

  // 🐾 Pets
  CategoryItem('Pets', Icons.pets),
  CategoryItem('Pet Food', Icons.set_meal),
  CategoryItem('Vet', Icons.local_hospital),
  CategoryItem('Pet Accessories', Icons.shopping_basket),

  // 🧳 Vacation & Fun
  CategoryItem('Vacation', Icons.beach_access),
  CategoryItem('Hotel', Icons.hotel),
  CategoryItem('Tourism', Icons.camera_alt),
  CategoryItem('Tickets', Icons.confirmation_number),

  // 💼 Business & Work
  CategoryItem('Office Supplies', Icons.print),
  CategoryItem('Business', Icons.business_center),
  CategoryItem('Client Lunch', Icons.lunch_dining),
  CategoryItem('Software', Icons.computer),
  CategoryItem('Marketing', Icons.campaign),
  CategoryItem('Equipment', Icons.build),
  CategoryItem('Professional Services', Icons.handshake),

  // 👶 Family & Kids
  CategoryItem('Childcare', Icons.child_care),
  CategoryItem('Toys', Icons.toys),
  CategoryItem('School Fees', Icons.school),
  CategoryItem('Baby Products', Icons.baby_changing_station),

  // 🌿 Miscellaneous
  CategoryItem('Other', Icons.category),
  CategoryItem('Unknown', Icons.help_outline),
  CategoryItem('Emergency', Icons.warning),
  CategoryItem('Savings', Icons.account_balance_wallet),
  CategoryItem('Investments', Icons.show_chart),
  CategoryItem('Charity', Icons.favorite_outline),
];

// class CategoryDropdown extends StatefulWidget {
//   const CategoryDropdown({super.key});
//
//   @override
//   State<CategoryDropdown> createState() => _CategoryDropdownState();
// }
//
// class _CategoryDropdownState extends State<CategoryDropdown> {
//   CategoryItem? selectedCategory;
//
//   @override
//   Widget build(BuildContext context) {
//     return DropdownSearch<CategoryItem>(
//       items: kCategories,
//       selectedItem: selectedCategory,
//
//       // ✅ **THIS IS THE CRITICAL FIX**
//       // Tell the widget how to convert a CategoryItem object to a String.
//       // This is used for filtering and internal representation.
//       itemAsString: (CategoryItem item) => item.name,
//
//       // Configure the popup menu properties
//       popupProps: PopupProps.menu(
//         showSearchBox: true,
//         // This builder is for each item inside the popup list
//         itemBuilder: (context, item, isSelected) {
//           return ListTile(
//             leading: Icon(item.icon),
//             title: Text(item.name),
//             // Optionally, change the style for the selected item in the list
//             tileColor: isSelected ? Colors.blue.withOpacity(0.1) : null,
//           );
//         },
//         // You can also customize the search field inside the popup
//         searchFieldProps: const TextFieldProps(
//           decoration: InputDecoration(
//             border: OutlineInputBorder(),
//             contentPadding: EdgeInsets.fromLTRB(12, 12, 8, 0),
//             labelText: "Search category",
//           ),
//         ),
//       ),
//
//       // Configure the appearance of the main dropdown button
//       dropdownDecoratorProps: const DropDownDecoratorProps(
//         dropdownSearchDecoration: InputDecoration(
//           labelText: "Category *",
//           hintText: "Select a category", // Hint text when nothing is selected
//           border: OutlineInputBorder(),
//         ),
//       ),
//
//       // This builder is for the selected item shown in the main dropdown button
//       dropdownBuilder: (context, selectedItem) {
//         // If nothing is selected, the hintText from dropdownDecoratorProps will be shown.
//         // This builder only runs when an item IS selected.
//         if (selectedItem == null) {
//           return const Text('Select category'); // Fallback, usually not seen
//         }
//         return Row(
//           children: [
//             Icon(selectedItem.icon, size: 20), // Consistent icon size
//             const SizedBox(width: 10),
//             Text(selectedItem.name),
//           ],
//         );
//       },
//
//       // The filter function now works correctly because of `itemAsString`
//       filterFn: (item, filter) {
//         // You can keep your original filter function, it's correct.
//         return item.name.toLowerCase().contains(filter.toLowerCase());
//       },
//
//       // Update the state when a new item is selected
//       onChanged: (value) {
//         setState(() {
//           selectedCategory = value;
//         });
//       },
//     );
//   }
// }
