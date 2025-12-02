import 'package:flutter/material.dart';
import '/app_widgets/SearchBar.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return AppBar(
      automaticallyImplyLeading: false,
      title: Row(

        children: [
          Row(mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(
              'assets/logo.png',
              height: screenHeight * 0.05,
              fit: BoxFit.contain,
            ),
              SizedBox(width: screenWidth * 0.03),
            ]
          ),


        ],
      ),
      backgroundColor: Colors.transparent, // 👈 خليها زي ما هي
      elevation: 0,                        // 👈 يشيل الظل
      scrolledUnderElevation: 0,
    );


  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
