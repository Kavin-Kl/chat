import 'package:flutter/material.dart';
import 'package:chat/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
  final _messageController = TextEditingController();
  late User loggedInUser;
  String _chatId = '';
  String _recipientName = '';
  String _recipientEmail = '';

  @override
  void initState() {
    super.initState();
    getCurrentUser();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _setupChat();
  }

  void getCurrentUser() {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        loggedInUser = user;
        print('Current user: ${loggedInUser.email}');
      }
    } catch (e) {
      print('Error getting current user: $e');
    }
  }

  void _setupChat() async {
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    if (args != null) {
      setState(() {
        _recipientEmail = args['recipientEmail'];
        _recipientName = args['recipientName'];
        _chatId = _getChatId(loggedInUser.email!, _recipientEmail);
      });

      // Create or update chat document
      try {
        await _firestore.collection('chats').doc(_chatId).set({
          'participants': [loggedInUser.email, _recipientEmail],
          'lastUpdated': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
        print('Chat document created/updated successfully');
      } catch (e) {
        print('Error setting up chat: $e');
      }
    }
  }

  String _getChatId(String email1, String email2) {
    List<String> emails = [email1, email2];
    emails.sort(); // Sort to ensure consistent chat ID
    return emails.join('_');
  }

  void _sendMessage() async {
    if (_messageController.text.trim().isEmpty) return;

    try {
      final messageData = {
        'text': _messageController.text.trim(),
        'sender': loggedInUser.email,
        'timestamp': FieldValue.serverTimestamp(),
      };

      // First update the chat document
      await _firestore.collection('chats').doc(_chatId).set({
        'lastMessage': messageData['text'],
        'lastMessageTime': messageData['timestamp'],
      }, SetOptions(merge: true));

      // Then add the message
      await _firestore
          .collection('chats')
          .doc(_chatId)
          .collection('messages')
          .add(messageData);

      _messageController.clear();
    } catch (e) {
      print('Error sending message: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error sending message: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_recipientName),
        backgroundColor: Colors.lightBlueAccent,
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: _firestore
                    .collection('chats')
                    .doc(_chatId)
                    .collection('messages')
                    .orderBy('timestamp', descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return Center(child: Text('No messages yet'));
                  }

                  List<MessageBubble> messageBubbles = [];
                  final messages = snapshot.data!.docs;

                  for (var message in messages) {
                    final data = message.data() as Map<String, dynamic>;
                    final text = data['text'] as String;
                    final sender = data['sender'] as String;
                    final isMe = sender == loggedInUser.email;

                    messageBubbles.add(MessageBubble(
                      sender: sender,
                      text: text,
                      isMe: isMe,
                    ));
                  }

                  return ListView(
                    reverse: true,
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 20),
                    children: messageBubbles,
                  );
                },
              ),
            ),
            Container(
              decoration: kMessageContainerDecoration,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      decoration: kMessageTextFieldDecoration,
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  TextButton(
                    onPressed: _sendMessage,
                    child: Text('Send', style: kSendButtonTextStyle),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }
}

class MessageBubble extends StatelessWidget {
  final String sender;
  final String text;
  final bool isMe;

  MessageBubble({
    required this.sender,
    required this.text,
    required this.isMe,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(10.0),
      child: Column(
        crossAxisAlignment:
            isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            sender,
            style: TextStyle(fontSize: 12, color: Colors.white70),
          ),
          Material(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(isMe ? 30 : 0),
              topRight: Radius.circular(isMe ? 0 : 30),
              bottomLeft: Radius.circular(30),
              bottomRight: Radius.circular(30),
            ),
            elevation: 5,
            color: isMe ? Colors.lightBlueAccent : Colors.white,
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
              child: Text(
                text,
                style: TextStyle(
                  color: isMe ? Colors.white : Colors.black87,
                  fontSize: 15,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
