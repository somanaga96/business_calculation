import 'package:flutter/material.dart';

class ProductItem {
  final String name;
  final IconData icon;

  const ProductItem({required this.name, required this.icon});
}

// Hardcoded list of products and icons
const List<ProductItem> kProducts = [
  ProductItem(name: 'வியாபாரம்', icon: Icons.storefront),
  ProductItem(name: 'பை', icon: Icons.shopping_bag),
  ProductItem(name: 'அப்பளம் மூடை', icon: Icons.local_mall),
  ProductItem(name: 'டீசல்', icon: Icons.local_gas_station_outlined),
  ProductItem(name: 'மாதுரி', icon: Icons.shopping_basket_outlined),
  ProductItem(name: 'வீட்டு செலவு', icon: Icons.money),
  ProductItem(name: 'Driver சம்பளம்', icon: Icons.drive_eta_rounded),
  ProductItem(name: 'cool drinks', icon: Icons.local_drink),
  ProductItem(name: 'Koregaon kurkure', icon: Icons.shopping_basket_outlined),
  ProductItem(name: 'மின்சாரம்', icon: Icons.lightbulb),
  ProductItem(name: 'வண்டி repair', icon: Icons.build),
  ProductItem(name: 'முனீஸ்வரத் bank', icon: Icons.account_balance),
  ProductItem(name: 'எண்ணெய்', icon: Icons.oil_barrel),
  ProductItem(name: 'ரேகா பாய்', icon: Icons.person),
  ProductItem(name: 'அப்பளம் போட்டது', icon: Icons.person),
  ProductItem(name: 'முட்டை', icon: Icons.egg),
  ProductItem(name: 'சுப்பையா', icon: Icons.person),
  ProductItem(name: 'சர்க்கரை', icon: Icons.shopping_basket_outlined),
  ProductItem(name: 'கொடுத்தது செலவு', icon: Icons.money_off),
  ProductItem(name: 'மைதா', icon: Icons.no_food),
  ProductItem(name: 'ஞானதீப் bank”', icon: Icons.comment_bank),
  ProductItem(name: 'பேக்கரி கனேஷ்', icon: Icons.bakery_dining_outlined),
  ProductItem(name: 'விறகு', icon: Icons.fire_truck_sharp),
];
