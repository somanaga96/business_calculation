import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../bottom_navigation.dart';
import 'Global.dart';
import 'common_app_bar.dart';

class SideMenuPage extends StatelessWidget {
  const SideMenuPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<Global>(
      builder: (context, global, child) => Scaffold(
        appBar: CommonAppBar(
          title: global.getAppTitle(), // 👈 Dynamic title updates with tab
        ),
        drawer: Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: <Widget>[
              const DrawerHeader(
                decoration: BoxDecoration(color: Colors.blue),
                child: Text(
                  'Menu',
                  style: TextStyle(color: Colors.white, fontSize: 24),
                ),
              ),
              IconButton(
                onPressed: () {
                  global.toggleTheme();
                },
                icon: Icon(
                  global.isDarkMode ? Icons.dark_mode_rounded : Icons.wb_sunny,
                ),
              ),
            ],
          ),
        ),
        body: const BottomNavigation(),
      ),
    );
  }
}
