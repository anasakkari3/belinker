// lib/animated_pop_up.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'ChatPage.dart';

const Color primaryBlue = Color(0xFF0D47A1);
const Color accentOrange = Color(0xFFF57C00);
const Color cardBg = Color(0xFFFFFFFF);
const Color cardText = Color(0xFF1E293B);

class AnimatedPopUp extends StatefulWidget {
  final dynamic docId;
  final String collectionName;

  const AnimatedPopUp({
    super.key,
    required this.docId,
    required this.collectionName,
  });

  @override
  State<AnimatedPopUp> createState() => _AnimatedPopUpState();
}

class _AnimatedPopUpState extends State<AnimatedPopUp> {
  Widget _buildInfoRow(IconData icon, String text,
      {Color? color, FontWeight? fontWeight, double fontSize = 12}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color ?? Colors.grey.shade600, size: fontSize + 2),
        const SizedBox(width: 4),
        Flexible(
          child: Text(
            text,
            style: TextStyle(
              fontSize: fontSize,
              color: color ?? Colors.grey.shade700,
              fontWeight: fontWeight ?? FontWeight.normal,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  // ----------------------------
  // 📌 FIXED CHAT FUNCTION HERE
  // ----------------------------
  Future<void> _openChatFromPopup(BuildContext context, String otherUserId) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    // 1. Fetch other user's real name from users/{ownerId}
    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(otherUserId)
        .get();

    final otherUserData = userDoc.data() ?? {};

    final otherUserName = (otherUserData['fullName'] ??
        otherUserData['displayName'] ??
        otherUserData['name'] ??
        otherUserData['username'] ??
        "Unknown User")
        .toString();

    // 2. Sort participants to form unique chatRoomId
    final ids = [currentUser.uid, otherUserId]..sort();
    final chatRoomId = ids.join('_');

    // 3. Create or update chat room
    await FirebaseFirestore.instance
        .collection('chatRooms')
        .doc(chatRoomId)
        .set({
      'participants': [currentUser.uid, otherUserId],
      'createdAt': DateTime.now(),
      'participantNames': [
        currentUser.displayName ?? "You",
        otherUserName,
      ],
    }, SetOptions(merge: true));

    // 4. Close popup and open chat page
    if (!context.mounted) return;

    Navigator.of(context).pop(); // close popup
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatPage(
          chatRoomId: chatRoomId,
          chatRoomName: otherUserName,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context).size;
    final isLarge = media.width > 600;

    return Dialog(
      insetPadding: EdgeInsets.symmetric(
        horizontal: isLarge ? media.width * 0.2 : 12,
        vertical: isLarge ? media.height * 0.1 : 12,
      ),
      backgroundColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: isLarge ? 600 : media.width * 0.95,
              maxHeight: media.height * 0.9,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Container(
                color: cardBg,
                child: FutureBuilder<DocumentSnapshot>(
                  future: FirebaseFirestore.instance
                      .collection(widget.collectionName)
                      .doc(widget.docId.toString())
                      .get(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(color: accentOrange),
                      );
                    }

                    if (!snapshot.hasData || !snapshot.data!.exists) {
                      return const Center(child: Text('No data found 😕'));
                    }

                    final data = snapshot.data!.data() as Map<String, dynamic>;

                    final rawUrl = (data['imageUrl'] ?? '').toString().trim();
                    final imageUrl = (rawUrl.isNotEmpty &&
                        (rawUrl.startsWith('http') || rawUrl.startsWith('https')))
                        ? rawUrl
                        : 'assets/logo.png';

                    final serviceType = data['serviceType'] ?? 'Unknown Service';
                    final description = data['description'] ?? 'No description';
                    final address = data['location']?['address'];

                    String location = 'Unknown';
                    double? lat;
                    double? lng;

                    if (address is Map) {
                      final city = address['city']?.toString().trim() ?? '';
                      final country = address['country']?.toString().trim() ?? '';
                      location = [city, country]
                          .where((e) => e.isNotEmpty)
                          .join(', ')
                          .trim();

                      final geo = address['geo'];
                      if (geo is List && geo.length >= 2) {
                        try {
                          lat = double.tryParse(geo[0].toString().split('°').first.trim());
                          lng = double.tryParse(geo[1].toString().split('°').first.trim());
                        } catch (e) {
                          lat = null;
                          lng = null;
                        }
                      }
                    }

                    final price = data['price']?.toString() ?? '0';

                    // ----------------------------
                    // 📌 The FIX: ownerId only!
                    // ----------------------------
                    final ownerId = data['userId'] ?? '';

                    final postDate = (data['createdAt'] is Timestamp)
                        ? (data['createdAt'] as Timestamp).toDate()
                        : DateTime.now();

                    final requestDate = DateTime.tryParse(data['date'] ?? '') ??
                        DateTime.now();

                    final double titleSize =
                    isLarge ? 24 : media.width * 0.05;
                    final double textSize =
                    isLarge ? 16 : media.width * 0.035;

                    return SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AspectRatio(
                            aspectRatio: 16 / 9,
                            child: Image(
                              image: imageUrl.startsWith('http')
                                  ? NetworkImage(imageUrl)
                                  : AssetImage(imageUrl) as ImageProvider,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  Image.asset('assets/logo.png',
                                      fit: BoxFit.cover),
                            ),
                          ),

                          Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: media.width * 0.04, vertical: 8),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                _buildInfoRow(
                                  Icons.calendar_today_outlined,
                                  "Posted: ${DateFormat('MMM d, yyyy').format(postDate)}",
                                  fontSize: textSize - 5,
                                ),
                                Flexible(
                                  child: TextButton.icon(
                                    icon: Icon(
                                      Icons.location_on_outlined,
                                      size: textSize,
                                      color: primaryBlue,
                                    ),
                                    label: Text(
                                      location,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        color: primaryBlue,
                                        fontSize: textSize - 2,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    onPressed: () async {
                                      String mapsUrl;

                                      if (lat != null && lng != null) {
                                        mapsUrl =
                                        "https://www.google.com/maps/search/?api=1&query=$lat,$lng";
                                      } else {
                                        mapsUrl =
                                        "https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(location)}";
                                      }

                                      try {
                                        final uri = Uri.parse(mapsUrl);
                                        if (await canLaunchUrl(uri)) {
                                          await launchUrl(uri,
                                              mode: LaunchMode.externalApplication);
                                        } else {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            const SnackBar(
                                              content:
                                              Text("Could not open Google Maps ❌"),
                                            ),
                                          );
                                        }
                                      } catch (e) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                            content: Text("Error opening Maps: $e"),
                                          ),
                                        );
                                      }
                                    },
                                    style: TextButton.styleFrom(
                                      backgroundColor:
                                      Colors.blue.withOpacity(0.1),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 4,
                                      ),
                                      tapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: media.width * 0.04),
                            child: Text(
                              serviceType,
                              style: TextStyle(
                                color: primaryBlue,
                                fontSize: titleSize,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),

                          Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: media.width * 0.04, vertical: 8),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "\$$price",
                                  style: TextStyle(
                                    color: accentOrange,
                                    fontSize: textSize + 1,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                _buildInfoRow(
                                  Icons.event_available_outlined,
                                  "Needed by: ${DateFormat('MMM d, yyyy').format(requestDate)}",
                                  color: accentOrange,
                                  fontWeight: FontWeight.bold,
                                  fontSize: textSize - 5,
                                ),
                              ],
                            ),
                          ),

                          Padding(
                            padding: EdgeInsets.all(media.width * 0.04),
                            child: Container(
                              padding: const EdgeInsets.all(12.0),
                              decoration: BoxDecoration(
                                color: Colors.blue.withOpacity(0.05),
                                borderRadius: BorderRadius.circular(8.0),
                                border: Border.all(
                                  color: Colors.blue.withOpacity(0.2),
                                ),
                              ),
                              child: Text(
                                description,
                                style: TextStyle(
                                  color: cardText.withOpacity(0.9),
                                  fontSize: textSize,
                                  height: 1.5,
                                ),
                              ),
                            ),
                          ),

                          // ----------------------------
                          // ✔ FIXED CHAT BUTTON
                          // ----------------------------
                          Align(
                            alignment: Alignment.bottomRight,
                            child: Padding(
                              padding: EdgeInsets.all(media.width * 0.02),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  TextButton.icon(
                                    onPressed: () {
                                      _openChatFromPopup(context, ownerId);
                                    },
                                    icon: const Icon(
                                      Icons.chat_bubble_outline,
                                      color: accentOrange,
                                    ),
                                    label: Text(
                                      'Chat',
                                      style: TextStyle(
                                        color: accentOrange,
                                        fontSize: textSize + 1,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.of(context).pop(),
                                    child: Text(
                                      'Close',
                                      style: TextStyle(
                                        color: primaryBlue,
                                        fontSize: textSize + 2,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
