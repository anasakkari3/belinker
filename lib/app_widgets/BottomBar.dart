import 'package:flutter/material.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'dart:math';
import 'package:mediator_mvp/start_page/auth.dart';

import 'package:mediator_mvp/start_page/log_in.dart';

class BottomBar extends StatefulWidget {
  final Function(int) onItemSelected;
  final Color color;
  final Color backgroundColor;

  const BottomBar({
    super.key,
    required this.onItemSelected,
    this.color = Colors.white,
    this.backgroundColor = Colors.white,
  });

  @override
  State<BottomBar> createState() => _BottomBarState();
}

class _BottomBarState extends State<BottomBar> {
  int currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    // 🔥 مقاسات نسبية للشاشة
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    // 🔹 لستة الأيقونات والألوان
    final List<IconData> icons = [
      Icons.star,
      Icons.handshake,
      Icons.home,
      Icons.chat,
      Icons.account_circle,
    ];

    final List<Color> colors = [
      const Color(0xFFFF6600),
      const Color(0xFFFF6600),
      const Color(0xFF0057D9),
      const Color(0xFFFF6600),
      const Color(0xFFFF6600),
    ];

    // 🔹 توليد عناصر القائمة مع الظلال
    List<Widget> navItems = List.generate(icons.length, (index) {
      bool isSelected = currentIndex == index;
      return Container(
        decoration: BoxDecoration(
          color: Colors.white, // خلفية دائرية للأيقونة
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2), // لون الظل
              blurRadius: 3, // نعومة الظل
              offset: const Offset(0, 3), // مكان الظل
            ),
          ],
        ),
        padding: EdgeInsets.all(screenWidth * 0.015),
        child: Icon(
          icons[index],
          size: index == 2 ? screenWidth * 0.12 : screenWidth * 0.08, // 👈 زر Home أكبر
          color: isSelected ? const Color(0xFF0057D9) : const Color(0xFFFF6600),

        ),
      );
    });

    return CurvedNavigationBar(
      index: currentIndex,
      animationCurve: Curves.easeInOut,
      height: min(screenHeight * 0.07, 75),
      color: widget.color,
      backgroundColor: widget.backgroundColor,
      buttonBackgroundColor: Colors.white,
      onTap: (index) async {   // 👈 خلي onTap async
        if (index == 4) {      // 👈 إذا كبس الخامس
          await auth().signOut();
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const LoginScreen()),
          );
        } else {
          setState(() {
            currentIndex = index;
          });
          widget.onItemSelected(index);
        }
      },
      items: navItems,
    );

  }
}
