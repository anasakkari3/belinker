import 'package:flutter/material.dart';
import '/app_widgets/custom_dialog.dart'; // 👈 الكلاس اللي فيه RequestDialog و ServiceDialog

class MySearchBar extends StatelessWidget {
  const MySearchBar({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return GestureDetector(
      onTap: () {
        // 👈 أول ما تكبس على أي مكان بالسكشن
        CustomDialogWidget.show(context);
      },
      child: Container(
        margin: EdgeInsets.symmetric(
          horizontal: screenWidth * 0.04,
          vertical: screenHeight * 0.01,
        ),
        padding: EdgeInsets.symmetric(
          horizontal: screenWidth * 0.04,
          vertical: screenHeight * 0.012,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(screenWidth * 0.03),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: screenWidth * 0.02,
              offset: Offset(0, screenHeight * 0.002),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(Icons.add_circle,
                color: const Color(0xFF0057D9), size: screenWidth * 0.08),
            SizedBox(width: screenWidth * 0.03),
            Expanded(
              child: Text(
                "Create a new post...",
                style: TextStyle(
                  fontSize: screenWidth * 0.022,
                  color: Colors.black54,
                  fontWeight: FontWeight.w500,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
