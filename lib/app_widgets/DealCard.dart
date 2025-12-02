// lib/DealCard.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

const Color primaryBlue = Color(0xFF0D47A1);
const Color accentOrange = Color(0xFFF57C00);

class DealCard extends StatelessWidget {
  final String title;
  final String price;
  final String dealWithUser;
  final String userAvatarUrl;
  final DateTime completionDate;
  final int rating;

  const DealCard({
    super.key,
    required this.title,
    required this.price,
    required this.dealWithUser,
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

  @override
  Widget build(BuildContext context) {
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
                          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: primaryBlue),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text('Deal with: $dealWithUser', style: TextStyle(fontSize: 14, color: Colors.grey.shade700)),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    price,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: accentOrange),
                  )
                ],
              ),
              const Divider(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Completed: ${DateFormat('d MMMM, yyyy').format(completionDate)}', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                  _buildRatingStars(rating),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}