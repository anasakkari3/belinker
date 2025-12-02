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

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(),
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            CustomSliverTabBar(controller: _tabController),
          ];
        },
        body: TabBarView(
          controller: _tabController,
          children: [
            // ✅ التبويب الأول: عرض الطلبات من Firestore
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('requests')
                  .orderBy('createdAt', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text('No requests yet 😴'));
                }

                final requests = snapshot.data!.docs;

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
                        crossAxisSpacing: 15,   // 🔹 مسافة منطقية بين الكروت
                        mainAxisSpacing: 15,
                        childAspectRatio: 0.9, // 🔹 تحكم بحجم الكرت (جرّب 0.8 / 1.0 لو حاب)
                      ),
                      itemCount: requests.length,
                      itemBuilder: (context, index) {
                        final req = requests[index];
                        final data = req.data() as Map<String, dynamic>;

                        final locationMap =
                            data['location'] as Map<String, dynamic>? ?? {};
                        final addressMap =
                            locationMap['address'] as Map<String, dynamic>? ?? {};

                        // 🔹 userId عشان نجيب اسم وصورة المستخدم جوّا الكرت
                        final String userId = (data['userId'] ?? '').toString();

                        // 🔹 تحديد الصورة النهائية
                        late String imageUrl;
                        final rawUrl = (data['imageUrl'] ?? '').toString().trim();
                        if (rawUrl.isNotEmpty &&
                            (rawUrl.startsWith('http') || rawUrl.startsWith('https'))) {
                          imageUrl = rawUrl;
                        } else {
                          imageUrl = 'assets/logo.png';
                        }



                        return Cardpage(
                          docId: req.id,
                          title: data['serviceType'] ?? 'Untitled Request',
                          imageUrl: imageUrl,
                          description: data['description'] ?? '',
                          price: data['price']?.toString() ?? '0',
                          postDate: (data['createdAt'] is Timestamp)
                              ? (data['createdAt'] as Timestamp).toDate()
                              : DateTime.now(),
                          requestDate: DateTime.tryParse(data['date'] ?? '') ?? DateTime.now(),
                          location: addressMap['city'] ?? 'Unknown',
                          userId: userId, // ✅ لا تنساه
                        );

                      },
                    );
                  },
                );
              },
            ),

            // ✅ تبويبات أخرى
            const Center(child: Text("Service Page Content")),
            const Center(child: Text("Suggestions Page Content")),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          CustomDialogWidget.show(context);
        },
        label: const Text('New Post'),
        icon: const Icon(Icons.add),
        backgroundColor: accentOrange,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
