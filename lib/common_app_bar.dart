import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'Global.dart';

class CommonAppBar extends StatelessWidget implements PreferredSizeWidget {
  final bool showBack;
  final Color backgroundColor;
  final List<Widget>? actions;
  final String? title;

  const CommonAppBar({
    super.key,
    this.showBack = false,
    this.backgroundColor = Colors.blue,
    this.actions,
    this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<Global>(
      builder: (context, global, child) {
        return AppBar(
          automaticallyImplyLeading: !showBack,
          // ✅ Show menu if no back
          leading: showBack
              ? IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () => Navigator.of(context).maybePop(),
                )
              : Builder(
                  builder: (context) => IconButton(
                    icon: const Icon(Icons.menu),
                    onPressed: () => Scaffold.of(context).openDrawer(),
                  ),
                ),
          title: Center(
            child: Text(
              title ?? global.getAppTitle(),
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 20),
            ),
          ),
          backgroundColor: backgroundColor,
          elevation: 2,
          actions: actions,
        );
      },
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
