// lib/app_widgets/DoneDealsPage.dart

import 'package:flutter/material.dart';
import 'DealCard.dart';
import 'Header.dart';

class DoneDealsPage extends StatelessWidget {
  const DoneDealsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> doneDeals = [
      {
        "title": 'Car Repair',
        "price": '\$555.0',
        "dealWithUser": 'anas',
        "dealWithUserId": 'uid123',
        "userAvatarUrl":
        'https://via.placeholder.com/150',
        "completionDate": DateTime.now(),
        "rating": 4,
      },
      {
        "title": 'Carpentry Work',
        "price": '\$333.0',
        "dealWithUser": 'Unknown user',
        "dealWithUserId": 'uid456',
        "userAvatarUrl":
        'https://via.placeholder.com/150',
        "completionDate": DateTime.now(),
        "rating": 3,
      },
    ];

    return Scaffold(
      appBar: CustomAppBar(),
      body: doneDeals.isEmpty
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
          : ListView.builder(
        itemCount: doneDeals.length,
        itemBuilder: (context, index) {
          final deal = doneDeals[index];
          return DealCard(
            title: deal['title'],
            price: deal['price'],
            dealWithUser: deal['dealWithUser'],
            dealWithUserId: deal['dealWithUserId'],
            userAvatarUrl: deal['userAvatarUrl'],
            completionDate: deal['completionDate'],
            rating: deal['rating'],
          );
        },
      ),
    );
  }
}
