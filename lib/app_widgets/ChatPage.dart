import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'lib/models/ChatMessage.dart';

class ChatPage extends StatefulWidget {
  final String chatRoomId;
  final String chatRoomName;

  const ChatPage({
    Key? key,
    required this.chatRoomId,
    required this.chatRoomName,
  }) : super(key: key);

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _messageController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    final user = _auth.currentUser;
    if (user == null) return;

    await _firestore
        .collection('chatRooms')
        .doc(widget.chatRoomId)
        .collection('messages')
        .add(
      ChatMessage(
        id: '',
        senderId: user.uid,
        senderName: user.displayName ?? 'User',
        text: text,
        timestamp: DateTime.now(),
      ).toMap(),
    );

    _messageController.clear();

    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _initiateCall() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Calling ${widget.chatRoomName}...'),
        duration: const Duration(seconds: 2),
      ),
    );
    // Add your call integration here (e.g., Agora, Twilio, etc.)
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final width = screenSize.width;
    final height = screenSize.height;

    final horizontalPadding = width * 0.03;
    final verticalPadding = height * 0.006;
    final maxBubbleWidth = width * 0.7;
    final messageFontSize = width * 0.035;
    final nameFontSize = width * 0.030;
    final timeFontSize = width * 0.025;
    final inputFontSize = width * 0.035;
    final sendIconSize = width * 0.06;
    final appBarFontSize = width * 0.045;
    final borderRadius = width * 0.03;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.chatRoomName,
          style: TextStyle(
            fontSize: appBarFontSize,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Colors.blue.shade400,
        actions: [
          // Call button in top right
          IconButton(
            onPressed: _initiateCall,
            icon: const Icon(Icons.call, color: Colors.white),
            tooltip: 'Start call',
          ),
        ],
      ),
      body: Column(
        children: [
          // Messages list
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection('chatRooms')
                  .doc(widget.chatRoomId)
                  .collection('messages')
                  .orderBy('timestamp', descending: false)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      'Error: ${snapshot.error}',
                      style: TextStyle(fontSize: messageFontSize),
                    ),
                  );
                }

                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final messages = snapshot.data!.docs
                    .map((doc) => ChatMessage.fromFirestore(doc))
                    .toList();

                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (_scrollController.hasClients) {
                    _scrollController.jumpTo(
                      _scrollController.position.maxScrollExtent,
                    );
                  }
                });

                return ListView.builder(
                  controller: _scrollController,
                  padding: EdgeInsets.symmetric(
                    horizontal: horizontalPadding,
                    vertical: verticalPadding * 0.5,
                  ),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final msg = messages[index];
                    final isMe = msg.senderId == _auth.currentUser?.uid;

                    return Padding(
                      padding: EdgeInsets.symmetric(vertical: verticalPadding * 0.5),
                      child: Align(
                        alignment:
                        isMe ? Alignment.centerRight : Alignment.centerLeft,
                        child: ConstrainedBox(
                          constraints: BoxConstraints(maxWidth: maxBubbleWidth),
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: horizontalPadding,
                              vertical: verticalPadding,
                            ),
                            decoration: BoxDecoration(
                              color: isMe
                                  ? Colors.blue.shade300
                                  : Colors.grey.shade300,
                              borderRadius: BorderRadius.circular(borderRadius),
                            ),
                            child: Column(
                              crossAxisAlignment: isMe
                                  ? CrossAxisAlignment.end
                                  : CrossAxisAlignment.start,
                              children: [
                                Text(
                                  msg.senderName,
                                  style: TextStyle(
                                    fontSize: nameFontSize,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: verticalPadding * 0.005),
                                Text(
                                  msg.text,
                                  style: TextStyle(
                                    fontSize: messageFontSize,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  softWrap: true,
                                ),
                                SizedBox(height: verticalPadding * 0.1),
                                Text(
                                  '${msg.timestamp.hour}:${msg.timestamp.minute.toString().padLeft(2, '0')}',
                                  style: TextStyle(
                                    fontSize: timeFontSize,
                                    color: Colors.grey.shade700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Divider(height: 1, color: Colors.grey.shade300),
          // Input area
          Container(
            padding: EdgeInsets.all(horizontalPadding),
            color: Colors.grey.shade50,
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      decoration: InputDecoration(
                        hintText: 'Type a message...',
                        hintStyle: TextStyle(fontSize: inputFontSize),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(borderRadius * 2),
                          borderSide: BorderSide(color: Colors.grey.shade400),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(borderRadius * 2),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(borderRadius * 2),
                          borderSide:
                          BorderSide(color: Colors.blue.shade400, width: 2),
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: horizontalPadding,
                          vertical: verticalPadding,
                        ),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      style: TextStyle(fontSize: inputFontSize),
                      maxLines: null,
                      minLines: 1,
                    ),
                  ),
                  SizedBox(width: horizontalPadding * 0.5),
                  FloatingActionButton(
                    onPressed: _sendMessage,
                    mini: width < 600,
                    backgroundColor: Colors.blue.shade400,
                    child: Icon(Icons.send, size: sendIconSize),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
