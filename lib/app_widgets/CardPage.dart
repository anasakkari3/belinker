import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'animated_pop_up.dart';

class Cardpage extends StatelessWidget {
  final String title;
  final String imageUrl;
  final String description;
  final String price;
  final DateTime postDate;
  final DateTime requestDate;
  final String location;
  final dynamic docId;
  final String userId; // 👈 مهم

  const Cardpage({
    super.key,
    required this.title,
    required this.imageUrl,
    required this.description,
    required this.price,
    required this.postDate,
    required this.requestDate,
    required this.location,
    required this.docId,
    required this.userId,
  });

  @override
  Widget build(BuildContext context) {
    final bool isNetworkImage = imageUrl.startsWith('http');

    return GestureDetector(
      onTap: () {
        showDialog(
          context: context,
          builder: (context) => AnimatedPopUp(docId: docId),
        );
      },
      child: Card(
        margin: EdgeInsets.zero,
        elevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        clipBehavior: Clip.antiAlias,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final double cardHeight = constraints.maxHeight;
            final double cardWidth = constraints.maxWidth;

            final double titleFontSize = cardWidth * 0.13;
            final double metaFontSize = cardWidth * 0.07;
            final String dateText =
                "${postDate.day}/${postDate.month}/${postDate.year}";

            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 🔹 شريط معلومات المستخدم (اسم + صورة)
                SizedBox(
                  height: cardHeight * 0.2,
                  child: FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                    future: FirebaseFirestore.instance
                        .collection('users')
                        .doc(userId)
                        .get(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: SizedBox(
                            height: 16,
                            width: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        );
                      }

                      if (!snapshot.hasData || !snapshot.data!.exists) {
                        // لو ما في بيانات للمستخدم
                        return Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            children: const [
                              CircleAvatar(child: Icon(Icons.person)),
                              SizedBox(width: 8),
                              Expanded(child: Text("Unknown user")),
                            ],
                          ),
                        );
                      }

                      final data = snapshot.data!.data()!;
                      final userName =
                      (data['fullName'] ?? 'User').toString(); // ✅ بدل name
                      final photoUrl =
                      (data['photoUrl'] ?? '').toString();     // ✅ بدل أي حقل غلط

                      return Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: cardWidth * 0.10,
                              backgroundImage: photoUrl.isNotEmpty
                                  ? NetworkImage(photoUrl)
                                  : const AssetImage('assets/user.png')
                              as ImageProvider,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                userName,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: cardWidth * 0.10,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),

                // 🔹 عنوان الخدمة في النص
                Padding(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  child: Text(
                    title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: titleFontSize/1.2,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Outfit',
                    ),
                  ),
                ),

                // 🔹 صورة الطلب
                SizedBox(
                  height: cardHeight * 0.33,
                  child: isNetworkImage
                      ? Image.network(imageUrl, fit: BoxFit.cover)
                      : Image.asset(imageUrl, fit: BoxFit.cover),
                ),

                // 🔹 السعر + التاريخ مثبتين تحت
                Expanded(
                  child: Padding(
                    padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "\$$price",
                            style: TextStyle(
                              fontSize: metaFontSize,
                              fontWeight: FontWeight.bold,
                              color: Colors.deepOrange,
                            ),
                          ),
                          Text(
                            dateText,
                            style: TextStyle(
                              fontSize: metaFontSize,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey[700],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
