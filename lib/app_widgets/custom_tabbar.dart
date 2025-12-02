// lib/app_widgets/custom_tabbar.dart

import 'package:flutter/material.dart';

class CustomSliverTabBar extends StatelessWidget {
  final TextEditingController searchController;
  final ValueChanged<String> onSearchChanged;

  /// "all" or "request" or "service"
  final String selectedFilter;
  final ValueChanged<String> onFilterChanged;

  const CustomSliverTabBar({
    super.key,
    required this.searchController,
    required this.onSearchChanged,
    required this.selectedFilter,
    required this.onFilterChanged,
  });

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    final double screenHeight = size.height;

    // 👇 ارتفاع الهيدر يعتمد على حجم الشاشة (ريسبونسف)
    // بين 14% - 18% من ارتفاع الشاشة بيكون ممتاز لمعظم الأجهزة
    final double headerHeight = screenHeight * 0.16;

    return SliverPersistentHeader(
      floating: true,
      pinned: false,
      delegate: _SearchFilterHeaderDelegate(
        minHeight: headerHeight,
        maxHeight: headerHeight,
        searchController: searchController,
        onSearchChanged: onSearchChanged,
        selectedFilter: selectedFilter,
        onFilterChanged: onFilterChanged,
      ),
    );
  }
}

class _SearchFilterHeaderDelegate extends SliverPersistentHeaderDelegate {
  final double minHeight;
  final double maxHeight;

  final TextEditingController searchController;
  final ValueChanged<String> onSearchChanged;
  final String selectedFilter;
  final ValueChanged<String> onFilterChanged;

  _SearchFilterHeaderDelegate({
    required this.minHeight,
    required this.maxHeight,
    required this.searchController,
    required this.onSearchChanged,
    required this.selectedFilter,
    required this.onFilterChanged,
  });

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    final Size size = MediaQuery.of(context).size;
    final double width = size.width;
    final double height = size.height;

    final double padding = width * 0.04;
    final double searchBarHeight = height * 0.06;
    final double cardBorderRadius = 16;
    final double searchFontSize = width * 0.042;

    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      padding: EdgeInsets.only(
        left: padding,
        right: padding,
        top: height * 0.01,
        bottom: height * 0.01,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 🔍 Search bar
          Container(
            height: searchBarHeight,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(cardBorderRadius * 3),
            ),
            child: TextField(
              controller: searchController,
              onChanged: (value) => onSearchChanged(value.toLowerCase()),
              decoration: InputDecoration(
                hintText: 'Search',
                hintStyle: TextStyle(
                  fontSize: searchFontSize,
                  color: Colors.grey.shade500,
                ),
                prefixIcon: Icon(
                  Icons.search,
                  color: Colors.grey.shade500,
                  size: width * 0.06,
                ),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.symmetric(
                  vertical: height * 0.018,
                  horizontal: padding * 0.5,
                ),
              ),
              style: TextStyle(
                fontSize: searchFontSize,
                // 👇 خلي النص غامق عشان ما يختفي على الخلفية البيضا
                color: Colors.black87,
              ),
            ),
          ),

          SizedBox(height: height * 0.015),

          // ⚙️ Filter chips: All / Requests / Services
          Align(
            alignment: Alignment.centerLeft, // 👈 يلزق كل الصف بأقصى اليسار
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisSize: MainAxisSize.min, // 👈 ما يتمدّد، بس قد الأزرار
                children: [
                  _buildFilterChip(
                    context: context,
                    label: 'All',
                    value: 'all',
                  ),
                  const SizedBox(width: 8),
                  _buildFilterChip(
                    context: context,
                    label: 'Requests',
                    value: 'request',
                  ),
                  const SizedBox(width: 8),
                  _buildFilterChip(
                    context: context,
                    label: 'Services',
                    value: 'service',
                  ),
                ],
              ),
            ),
          ),

        ],
      ),
    );
  }

  Widget _buildFilterChip({
    required BuildContext context,
    required String label,
    required String value,
  }) {
    final bool isSelected = selectedFilter == value;
    final double fontSize = MediaQuery.of(context).size.width * 0.035;

    return GestureDetector(
      onTap: () => onFilterChanged(value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds:400),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xE3CDBBFF)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(0xFF0057D9),
          border: Border.all(
            color: isSelected ? const Color(0xFF0057D9) : const Color(0xFFFF6600),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: fontSize,
            color: isSelected ? Colors.black : Colors.grey,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  @override
  double get maxExtent => maxHeight;

  @override
  double get minExtent => minHeight;

  @override
  bool shouldRebuild(covariant _SearchFilterHeaderDelegate oldDelegate) {
    return oldDelegate.selectedFilter != selectedFilter ||
        oldDelegate.searchController != searchController ||
        oldDelegate.minHeight != minHeight ||
        oldDelegate.maxHeight != maxHeight;
  }
}
