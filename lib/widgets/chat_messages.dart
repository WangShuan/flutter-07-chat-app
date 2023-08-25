import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import './message_item.dart';

class ChatMessages extends StatelessWidget {
  const ChatMessages({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final Stream<QuerySnapshot<Map<String, dynamic>>> messagesStream = FirebaseFirestore.instance.collection('messages').orderBy("create_at", descending: true).snapshots();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: StreamBuilder(
        stream: messagesStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            return const Center(
              child: Text('Something wrong here.'),
            );
          } else if (snapshot.data!.docs.isEmpty || !snapshot.hasData) {
            return const Center(
              child: Text('No messages here.'),
            );
          } else {
            return ListView.builder(
              padding: const EdgeInsets.all(0),
              reverse: true,
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (context, index) => MessageItem(user, snapshot.data!.docs[index].data()),
            );
          }
        },
      ),
    );
  }
}
