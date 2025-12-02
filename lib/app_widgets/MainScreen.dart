import 'package:flutter/material.dart';
import 'package:mediator_mvp/app_widgets/ProfilePage.dart';
// THE FIX: Import the other files from the same 'app_widgets' directory.
// I also corrected the filename to be lowercase 'h' as shown in your screenshot.
import 'home_page.dart';
import 'DoneDealsPage.dart';
import 'BottomBar.dart';
import 'ChatRoomsPage.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 2; // Start on the Home icon

  // The list of pages. Notice I am now using 'HomePage' which is the class name.
  static const List<Widget> _pages = <Widget>[
    Center(child: Text('Favorites Page')), // Index 0: star
    DoneDealsPage(),                    // Index 1: handshake
    HomePage(),                         // Index 2: home
    ChatRoomsPage(), // Index 3: chat
    ProfilePage(),  // Index 4: account_circle
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: IndexedStack(
          index: _selectedIndex,
          children: _pages,
        ),
        bottomNavigationBar: BottomBar(
          currentIndex: _selectedIndex,
          onItemSelected: _onItemTapped,
        ),
      ),
    );
  }
}