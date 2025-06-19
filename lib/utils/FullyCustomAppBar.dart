import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class FullyCustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: kToolbarHeight + 10,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(blurRadius: 4, color: Colors.black26)],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const BackButton(color: Colors.black),
          const Text("Welcome", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          Image.asset(
            'assets/icons/app_icon.png',
            height: 40,
          )
        ],
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 10);
}
