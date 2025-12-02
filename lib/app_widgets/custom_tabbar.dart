import 'package:flutter/material.dart';


class CustomSliverTabBar extends StatelessWidget {
  final TabController controller;

  const CustomSliverTabBar({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    return SliverPersistentHeader(
      floating: true,
      pinned: false,
      delegate: _TabBarDelegate(
        TabBar(
          controller: controller,
          isScrollable: true,
          labelPadding: EdgeInsets.symmetric(
            horizontal: MediaQuery.of(context).size.width * 0.07,
          ),
          indicator: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(25),
          ),
          indicatorSize: TabBarIndicatorSize.tab,
          indicatorPadding: EdgeInsets.symmetric(
            horizontal: screenWidth * -0.02,
            vertical: screenHeight * 0.005,
          ),

          labelColor: Color(0xFF0057D9),
          unselectedLabelColor: Color(0xFFFF6600),
          tabAlignment: TabAlignment.center,
          dividerColor:Colors.transparent,
          tabs: const [
            Tab(icon: Icon(Icons.request_page), text: "request"),
            Tab(icon: Icon(Icons.home_repair_service), text: "service"),
            Tab(icon: Icon(Icons.lightbulb), text: "suggestions"),
          ],
        ),
      ),
    );
  }
}

class _TabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;
  _TabBarDelegate(this.tabBar);

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: screenWidth * 0.03,
        vertical: screenHeight * 0.01,
      ),
      padding: EdgeInsets.all(screenWidth * 0.01),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(screenWidth * 0.04),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: screenWidth * 0.015,
            offset: Offset(0, screenHeight * 0.003),
          ),
        ],
      ),
      child: tabBar,
    );
  }

  @override
  double get maxExtent => tabBar.preferredSize.height + 20;
  @override
  double get minExtent => tabBar.preferredSize.height + 20;

  @override
  bool shouldRebuild(covariant _TabBarDelegate oldDelegate) => false;
}
