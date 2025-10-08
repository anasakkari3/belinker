import 'package:flutter/material.dart';
import 'BottomBar.dart';   // ✅ Custom Bottom Navigation
import 'Header.dart';
import 'custom_tabbar.dart';
// استدعاء الكلاسات الجداد
import 'CardPage.dart';


class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _bottomIndex = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this); // 3 Tabs
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // بيانات تجريبية للكروت
    final List<Map<String, String>> items = [
      {
        "title": "First Card",
        "imageUrl": "https://picsum.photos/400/200?random=1",
        "description": "This is the description of the first card."
      },
      {
        "title": "Second Card",
        "imageUrl": "https://picsum.photos/400/200?random=2",
        "description": "This is the description of the second card."
      },
      {
        "title": "Third Card",
        "imageUrl": "https://picsum.photos/400/200?random=3",
        "description": "This is the description of the third card."
      },
      {
        "title": "Third Card",
        "imageUrl": "https://picsum.photos/400/200?random=3",
        "description": "This is the description of the third card."
      },
      {
        "title": "Third Card",
        "imageUrl": "https://picsum.photos/400/200?random=3",
        "description": "This is the description of the third card."
      },
      {
        "title": "Third Card",
        "imageUrl": "https://picsum.photos/400/200?random=3",
        "description": "This is the description of the third card."

      },
      {
        "title": "Third Card",
        "imageUrl": "https://picsum.photos/400/200?3",
        "description": "This is the description of the third card."
      },
      {
        "title": "Third Card",
        "imageUrl": "https://picsum.photos/400/200?4",
        "description": "This is the description of the third card."
      },
      {
        "title": "Third Card",
        "imageUrl": "https://picsum.photos/400/200?random=3",
        "description": "This is the description of the third card."
      },
      {
        "title": "Third Card",
        "imageUrl": "https://picsum.photos/400/200?random=3",
        "description": "This is the description of the third card."
      },
    ];

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: const CustomAppBar(), // ✅ الهيدر مع اللوجو

        body: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return [
              CustomSliverTabBar(controller: _tabController),
            ];
          },
          body: TabBarView(
            controller: _tabController,
            children: [
              // ✅ الصفحة الأولى (Request Page) مع الكروت
              ListView.builder(
                itemCount: items.length,
                itemBuilder: (context, index) {
                  return Cardpage(
                    title: items[index]["title"]!,
                    imageUrl: items[index]["imageUrl"]!,
                    description: items[index]["description"]!,
                  );
                },
              ),

              // ✅ الصفحة الثانية (Service Page)
              const Center(child: Text("service page")),

              // ✅ الصفحة الثالثة (Suggestions Page)
              const Center(child: Text("suggestions page")),
            ],
          ),

        ),

        // ✅ البار السفلي
        bottomNavigationBar: BottomBar(
          onItemSelected: (index) {
            setState(() {
              _bottomIndex = index;
            });
          },
        ),

      ),
    );
  }
}
