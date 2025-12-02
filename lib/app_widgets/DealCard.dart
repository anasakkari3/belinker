// lib/app_widgets/DealCard.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'ChatPage.dart';

const Color primaryBlue = Color(0xFF0D47A1);
const Color accentOrange = Color(0xFFF57C00);

class DealCard extends StatelessWidget {
  final String title;
  final String price;
  final String dealWithUser;
  final String dealWithUserId;
  final String userAvatarUrl;
  final DateTime completionDate;
  final int rating;

  const DealCard({
    super.key,
    required this.title,
    required this.price,
    required this.dealWithUser,
    required this.dealWithUserId,
    required this.userAvatarUrl,
    required this.completionDate,
    required this.rating,
  });

  Widget _buildRatingStars(int rating) {
    List<Widget> stars = [];
    for (int i = 0; i < 5; i++) {
      stars.add(Icon(
        i < rating ? Icons.star : Icons.star_border,
        color: accentOrange,
        size: 20,
      ));
    }
    return Row(children: stars);
  }

  void _openChat(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    final ids = [currentUser.uid, dealWithUserId];
    ids.sort();
    final chatRoomId = ids.join('_');

    FirebaseFirestore.instance
        .collection('chatRooms')
        .doc(chatRoomId)
        .set({
      'participants': [currentUser.uid, dealWithUserId],
      'createdAt': DateTime.now(),
      'participantNames': [
        currentUser.displayName ?? 'You',
        dealWithUser,
      ],
    }, SetOptions(merge: true));

    if (context.mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ChatPage(
            chatRoomId: chatRoomId,
            chatRoomName: dealWithUser,
          ),
        ),
      );
    }
  }




  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final width = screenSize.width;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 25,
                    backgroundImage: NetworkImage(userAvatarUrl),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: primaryBlue,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Deal with: $dealWithUser',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    price,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: accentOrange,
                    ),
                  )
                ],
              ),
              const Divider(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      'Completed: ${DateFormat('d MMMM, yyyy').format(completionDate)}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ),
                  _buildRatingStars(rating),
                ],
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    _openChat(context);
                  },
                  icon: const Icon(Icons.chat_bubble_outline, size: 18),
                  label: const Text('Chat'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: accentOrange,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: width * 0.025),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
