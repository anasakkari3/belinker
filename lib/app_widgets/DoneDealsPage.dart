import 'package:flutter/material.dart';
import 'DealCard.dart';
import 'Header.dart'; // <-- 1. ADD THIS IMPORT

class DoneDealsPage extends StatelessWidget {
  const DoneDealsPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Sample data for completed deals.
    // To see the "empty" message, use this line:
    //final List<Map<String, dynamic>> doneDeals = [];

    // To see the list of deals, comment out the line above and use this list:

    final List<Map<String, dynamic>> doneDeals = [
      {
        "title": "Corporate Event Videography",
        "price": "₪4500",
        "dealWithUser": "Lior Cohen",
        "userAvatarUrl": "https://randomuser.me/api/portraits/men/32.jpg",
        "completionDate": DateTime(2025, 9, 28),
        "rating": 5,
      },
      {
        "title": "Wedding Photography",
        "price": "₪7000",
        "dealWithUser": "Sara Levi",
        "userAvatarUrl": "https://randomuser.me/api/portraits/women/44.jpg",
        "completionDate": DateTime(2025, 8, 15),
        "rating": 4,
      },
    ];


    return Scaffold(
      // --- 2. REPLACE THE STANDARD APPBAR WITH YOUR CUSTOM HEADER ---
      appBar: const CustomAppBar(),

      body: doneDeals.isEmpty
      // If TRUE (list is empty), show the default message.
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.handshake_outlined,
              size: 100,
              color: Colors.grey.shade300,
            ),
            const SizedBox(height: 20),
            Text(
              "You don't have any deals done yet",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey.shade500,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      )
      // If FALSE (list has deals), show the list.
          : ListView.builder(
        itemCount: doneDeals.length,
        itemBuilder: (context, index) {
          final deal = doneDeals[index];
          return DealCard(
            title: deal['title'],
            price: deal['price'],
            dealWithUser: deal['dealWithUser'],
            userAvatarUrl: deal['userAvatarUrl'],
            completionDate: deal['completionDate'],
            rating: deal['rating'],
          );
        },
      ),
    );
  }
}