import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mediator_mvp/app_widgets/Header.dart';
import 'ChatPage.dart';

class ChatRoomsPage extends StatefulWidget {
  const ChatRoomsPage({Key? key}) : super(key: key);

  @override
  State<ChatRoomsPage> createState() => _ChatRoomsPageState();
}

class _ChatRoomsPageState extends State<ChatRoomsPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final width = screenSize.width;
    final height = screenSize.height;

    // Responsive values
    final padding = width * 0.03;
    final searchBarHeight = height * 0.06;
    final searchFontSize = width * 0.035;
    final chatsTitleFontSize = width * 0.045;
    final titleFontSize = width * 0.040;
    final subtitleFontSize = width * 0.030;
    final avatarRadius = width * 0.08;
    final cardBorderRadius = width * 0.03;

    return Scaffold(
      appBar: CustomAppBar(),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: padding * 1.5,
              vertical: padding * 0.5,
            ),
            child: Container(
              height: searchBarHeight,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(cardBorderRadius * 3),
              ),
              child: TextField(
                controller: _searchController,
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value.toLowerCase();
                  });
                },
                decoration: InputDecoration(
                  hintText: 'Search chats...',
                  hintStyle: TextStyle(
                    fontSize: searchFontSize,
                    color: Colors.grey.shade500,
                  ),
                  prefixIcon: Icon(
                    Icons.search,
                    color: Colors.grey.shade500,
                    size: width * 0.05,
                  ),
                  border: InputBorder.none,
                  isDense: true,  // ← ADD THIS
                  contentPadding: EdgeInsets.symmetric(
                    vertical: height * 0.018,
                    horizontal: padding * 0.5,
                  ),
                ),
                style: TextStyle(fontSize: searchFontSize),
              ),
            ),
          ),


          // Chat list
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection('chatRooms')
                  .orderBy('createdAt', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(
                    child: Text('Error: ${snapshot.error}'),
                  );
                }

                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                var chatRooms = snapshot.data!.docs;

                // Filter by search query
                if (_searchQuery.isNotEmpty) {
                  chatRooms = chatRooms.where((doc) {
                    final participants =
                    List<String>.from(doc['participantNames'] ?? []);
                    final chatRoomName = participants.join(', ');
                    return chatRoomName.toLowerCase().contains(_searchQuery);
                  }).toList();
                }

                if (chatRooms.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.chat_bubble_outline,
                          size: width * 0.2,
                          color: Colors.grey.shade300,
                        ),
                        SizedBox(height: height * 0.02),
                        Text(
                          _searchQuery.isEmpty
                              ? 'No chats yet'
                              : 'No chats found',
                          style: TextStyle(
                            fontSize: chatsTitleFontSize,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: EdgeInsets.all(padding),
                  itemCount: chatRooms.length,
                  itemBuilder: (context, index) {
                    final chatRoom = chatRooms[index];
                    final participants =
                    List<String>.from(chatRoom['participantNames'] ?? []);
                    final chatRoomName = participants.join(', ');

                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ChatPage(
                              chatRoomId: chatRoom.id,
                              chatRoomName: chatRoomName,
                            ),
                          ),
                        );
                      },
                      child: Card(
                        margin: EdgeInsets.only(bottom: padding),
                        elevation: 1,
                        shape: RoundedRectangleBorder(
                          borderRadius:
                          BorderRadius.circular(cardBorderRadius),
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(padding),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: avatarRadius,
                                backgroundColor: Colors.blue.shade300,
                                child: Text(
                                  chatRoomName[0].toUpperCase(),
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: width * 0.04,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              SizedBox(width: padding * 2),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      chatRoomName,
                                      style: TextStyle(
                                        fontSize: titleFontSize,
                                        fontWeight: FontWeight.w600,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    SizedBox(height: height * 0.005),
                                    Text(
                                      'Tap to view messages',
                                      style: TextStyle(
                                        fontSize: subtitleFontSize,
                                        color: Colors.grey.shade600,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
