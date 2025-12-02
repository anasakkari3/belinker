// lib/BottomBar.dart

import 'package:flutter/material.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'dart:math';
import 'package:mediator_mvp/start_page/auth.dart';
import 'package:mediator_mvp/start_page/log_in.dart';

// It no longer needs to be a StatefulWidget, a StatelessWidget is simpler and better.
class BottomBar extends StatelessWidget {
  final Function(int) onItemSelected;
  final int currentIndex; // <-- ADD THIS: It will RECEIVE the current index from MainScreen
  final Color color;
  final Color backgroundColor;

  const BottomBar({
    super.key,
    required this.onItemSelected,
    required this.currentIndex, // <-- ADD THIS to the constructor
    this.color = Colors.white,
    this.backgroundColor = Colors.transparent, // Use transparent for better look with pages
  });

  @override
  Widget build(BuildContext context) {
    // 🔥 مقاسات نسبية للشاشة
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    // 🔹 لستة الأيقونات
    final List<IconData> icons = [
      Icons.star,
      Icons.handshake,
      Icons.home,
      Icons.chat,
      Icons.account_circle,
    ];

    // 🔹 توليد عناصر القائمة مع الظلال
    List<Widget> navItems = List.generate(icons.length, (index) {
      // It now uses the currentIndex from the parent (MainScreen) to decide selection
      bool isSelected = currentIndex == index;
      return Container(
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 3,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        padding: EdgeInsets.all(screenWidth * 0.015),
        child: Icon(
          icons[index],
          size: index == 2 ? screenWidth * 0.07 : screenWidth * 0.06,
          color: isSelected ? const Color(0xFF0057D9) : const Color(0xFFFF6600),
        ),
      );
    });

    return CurvedNavigationBar(
      // The index is now controlled by the parent widget (MainScreen)
      index: currentIndex,
      animationCurve: Curves.easeInOut,
      height: min(screenHeight * 0.07, 75),
      color: color,
      backgroundColor: backgroundColor,
      buttonBackgroundColor: Colors.white,
      onTap: (index) async {
        onItemSelected(index);
      },
      items: navItems,
    );
  }
}