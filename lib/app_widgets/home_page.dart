// lib/app_widgets/home_page.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'Header.dart';
import 'custom_tabbar.dart';
import 'CardPage.dart';
import 'custom_dialog.dart';

const Color accentOrange = Color(0xFFF57C00);

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedFilter = 'all'; // all / request / service

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
  Stream<QuerySnapshot> _getStream() {
    // لو اختار "Services" → نجيب من كولكشن الخدمات
    if (_selectedFilter == 'service') {
      return FirebaseFirestore.instance
          .collection('services')
          .orderBy('createdAt', descending: true)
          .snapshots();
    }

    // باقي الحالات (all + request) → نجيب من requests
    return FirebaseFirestore.instance
        .collection('requests')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(),
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            CustomSliverTabBar(
              searchController: _searchController,
              onSearchChanged: (value) {
                setState(() => _searchQuery = value);
              },
              selectedFilter: _selectedFilter,
              onFilterChanged: (value) {
                setState(() => _selectedFilter = value);
              },
            ),
          ];
        },
        body: StreamBuilder<QuerySnapshot>(
          stream: _getStream(),

          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return const Center(child: Text('No requests yet 😴'));
            }

            final allDocs = snapshot.data!.docs;

            // 🔍 فلترة حسب السيرش + نوع الفلتر
            final filteredDocs = allDocs.where((doc) {
              final data = doc.data() as Map<String, dynamic>;

              final title =
              (data['serviceType'] ?? '').toString().toLowerCase();
              final desc =
              (data['description'] ?? '').toString().toLowerCase();

              final matchesSearch = _searchQuery.isEmpty ||
                  title.contains(_searchQuery) ||
                  desc.contains(_searchQuery);

              return matchesSearch;
            }).toList();


            return LayoutBuilder(
              builder: (context, constraints) {
                final double width = constraints.maxWidth;

                int crossAxisCount = 2;
                if (width > 900) {
                  crossAxisCount = 4;
                } else if (width > 600) {
                  crossAxisCount = 3;
                }

                return GridView.builder(
                  padding: const EdgeInsets.all(8),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    crossAxisSpacing: 15,
                    mainAxisSpacing: 15,
                    childAspectRatio: 0.9,
                  ),
                  itemCount: filteredDocs.length,
                  itemBuilder: (context, index) {
                    final req = filteredDocs[index];
                    final data = req.data() as Map<String, dynamic>;

                    final locationMap =
                        data['location'] as Map<String, dynamic>? ?? {};
                    final addressMap =
                        locationMap['address'] as Map<String, dynamic>? ?? {};

                    final String userId = (data['userId'] ?? '').toString();

                    late String imageUrl;
                    final rawUrl = (data['imageUrl'] ?? '').toString().trim();
                    if (rawUrl.isNotEmpty &&
                        (rawUrl.startsWith('http') ||
                            rawUrl.startsWith('https'))) {
                      imageUrl = rawUrl;
                    } else {
                      imageUrl = 'assets/logo.png';
                    }
                    final String collectionName =
                    _selectedFilter == 'service' ? 'services' : 'requests';

                    return Cardpage(
                      docId: req.id,
                      title: data['serviceType'] ?? 'Untitled Request',
                      imageUrl: imageUrl,
                      description: data['description'] ?? '',
                      price: data['price']?.toString() ?? '0',
                      postDate: (data['createdAt'] is Timestamp)
                          ? (data['createdAt'] as Timestamp).toDate()
                          : DateTime.now(),
                      requestDate:
                      DateTime.tryParse(data['date'] ?? '') ??
                          DateTime.now(),
                      location: addressMap['city'] ?? 'Unknown',
                      userId: userId,
                      collectionName: collectionName,
                    );
                  },
                );
              },
            );
          },
        ),
      ),
      floatingActionButton: Padding(
          padding: const EdgeInsets.only(bottom: 12.0),
        child: FloatingActionButton.extended(
        onPressed: () {
          CustomDialogWidget.show(context);
        },
        label: const Text('New Post'),
        icon: const Icon(Icons.add),
        backgroundColor: accentOrange,
      ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endContained,
    );
  }
}
