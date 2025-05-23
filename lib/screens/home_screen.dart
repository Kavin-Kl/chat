import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:chat/models/user_model.dart';

class HomeScreen extends StatelessWidget {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    final currentUser = _auth.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: Text('Contacts'),
        backgroundColor: Colors.lightBlueAccent,
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () async {
              await _auth.signOut();
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection('users').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          final users = snapshot.data?.docs ?? [];
          final filteredUsers = users.where((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return data['email'] != currentUser?.email;
          }).toList();

          return ListView.builder(
            itemCount: filteredUsers.length,
            itemBuilder: (context, index) {
              final userData =
                  filteredUsers[index].data() as Map<String, dynamic>;
              final user = UserModel.fromMap(userData);

              return Card(
                margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.lightBlueAccent,
                    child: Text(user.displayName[0].toUpperCase()),
                  ),
                  title: Text(user.displayName),
                  subtitle: Text(user.email),
                  onTap: () {
                    final currentUser = _auth.currentUser;
                    if (currentUser != null) {
                      Navigator.pushNamed(
                        context,
                        '/chat',
                        arguments: {
                          'recipientUid': userData['uid'],
                          'recipientEmail': userData['email'],
                          'recipientName': userData['displayName'] ??
                              userData['email'].split('@')[0],
                          'currentUserEmail': currentUser.email,
                        },
                      );
                    }
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
