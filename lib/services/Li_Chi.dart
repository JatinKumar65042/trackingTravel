import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:tracker/services/shared_pref.dart';
import 'package:tracker/services/notification_service.dart';

class LiChiChat extends StatefulWidget {
  const LiChiChat({super.key});

  @override
  State<LiChiChat> createState() => _LiChiChatState();
}

class _LiChiChatState extends State<LiChiChat> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _messageController = TextEditingController();
  String? userId;
  bool _isLoading = false;
  static const int _messagesPerPage = 20;
  DocumentSnapshot? _lastDocument;
  List<DocumentSnapshot> _messages = [];

  @override
  void initState() {
    super.initState();
    _loadUserId();
  }

  void _loadUserId() async {
    try {
      // Try to get existing anonymous ID from SharedPreferences
      userId = await SharedPreferenceHelper().getUserId();

      // If no ID exists, generate a new anonymous ID using UUID
      if (userId == null) {
        // Generate a new anonymous ID
        var uuid = Uuid();
        userId = uuid.v4().substring(
          0,
          8,
        ); // Use first 8 characters of UUID for readability

        // Save the anonymous ID to SharedPreferences for future sessions
        await SharedPreferenceHelper().saveUserId(userId!);
        print('Generated new anonymous ID: $userId');
      } else {
        print('Using existing anonymous ID: $userId');
      }

      _loadInitialMessages();
      setState(() {});
    } catch (e) {
      print('Error loading/generating user ID: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error setting up anonymous messaging'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _loadInitialMessages() async {
    if (_isLoading) return;
    setState(() => _isLoading = true);

    try {
      var query = _firestore
          .collection("li_chi_chats")
          .orderBy("timestamp", descending: true)
          .limit(_messagesPerPage);

      var snapshot = await query.get();
      if (snapshot.docs.isNotEmpty) {
        _messages = snapshot.docs;
        _lastDocument = snapshot.docs.last;
      }
    } catch (e) {
      print('Error loading messages: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error loading messages'),
          backgroundColor: Colors.red,
        ),
      );
    }

    setState(() => _isLoading = false);
  }

  Future<void> _loadMoreMessages() async {
    if (_isLoading || _lastDocument == null) return;
    setState(() => _isLoading = true);

    try {
      var query = _firestore
          .collection("li_chi_chats")
          .orderBy("timestamp", descending: true)
          .startAfterDocument(_lastDocument!)
          .limit(_messagesPerPage);

      var snapshot = await query.get();
      if (snapshot.docs.isNotEmpty) {
        _messages.addAll(snapshot.docs);
        _lastDocument = snapshot.docs.last;
      }
    } catch (e) {
      print('Error loading more messages: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error loading more messages'),
          backgroundColor: Colors.red,
        ),
      );
    }

    setState(() => _isLoading = false);
  }

  void _sendMessage() async {
    if (_messageController.text.trim().isEmpty) return;
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: User not logged in'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final messageText = _messageController.text.trim();
    _messageController.clear(); // Clear immediately for better UX
    setState(() => _isLoading = true); // Show loading state

    try {
      // Create the message document with a unique ID
      DocumentReference messageRef =
          _firestore.collection("li_chi_chats").doc();

      // Prepare the message data
      Map<String, dynamic> messageData = {
        "userId": userId,
        "message": messageText,
        "timestamp": FieldValue.serverTimestamp(),
      };

      // Use a transaction to ensure atomic write
      await _firestore.runTransaction((transaction) async {
        transaction.set(messageRef, messageData);
      });

      // Reset loading state
      setState(() => _isLoading = false);

      print('Message sent successfully: ${messageRef.id}');
    } catch (e) {
      print('Error sending message: $e');
      setState(() => _isLoading = false); // Reset loading state on error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to send message: ${e.toString()}'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
      // Rethrow the error to ensure proper error handling in the UI
      throw e;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Li-Chi Chat",
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.purple,
        elevation: 5,
        shadowColor: Colors.black54,
      ),
      body: Column(
        children: [
          Expanded(
            child: NotificationListener<ScrollNotification>(
              onNotification: (ScrollNotification scrollInfo) {
                if (scrollInfo.metrics.pixels ==
                    scrollInfo.metrics.maxScrollExtent) {
                  _loadMoreMessages();
                }
                return true;
              },
              child: StreamBuilder<QuerySnapshot>(
                stream:
                    _firestore
                        .collection("li_chi_chats")
                        .orderBy("timestamp", descending: true)
                        .limit(50)
                        .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    print('StreamBuilder error: ${snapshot.error}');
                    return Center(child: Text('Error loading messages'));
                  }

                  if (!snapshot.hasData) {
                    return Center(
                      child: SpinKitThreeBounce(
                        color: Colors.purple,
                        size: 30.0,
                      ),
                    );
                  }

                  var messages = snapshot.data!.docs;

                  if (messages.isEmpty) {
                    return Center(
                      child: Text('No messages yet. Start a conversation!'),
                    );
                  }

                  return ListView.builder(
                    reverse: true,
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      var message =
                          messages[index].data() as Map<String, dynamic>;
                      bool isMe = message["userId"] == userId;

                      return ChatBubble(
                        text: message["message"],
                        userId: message["userId"],
                        isMe: isMe,
                      );
                    },
                  );
                },
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  offset: Offset(0, -2),
                  blurRadius: 4.0,
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Type a message...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20.0),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.grey[100],
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 8.0,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 8.0),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.purple,
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: Icon(Icons.send, color: Colors.white),
                    onPressed: _sendMessage,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Chat Bubble Widget
class ChatBubble extends StatelessWidget {
  final String text;
  final String userId;
  final bool isMe;

  ChatBubble({required this.text, required this.userId, required this.isMe});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isMe ? Colors.purple.shade200 : Colors.grey.shade300,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(color: Colors.black12, blurRadius: 5, spreadRadius: 2),
          ],
        ),
        child: Column(
          crossAxisAlignment:
              isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Text(
              "User-$userId",
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.black54,
              ),
            ),
            SizedBox(height: 3),
            Text(
              text,
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
