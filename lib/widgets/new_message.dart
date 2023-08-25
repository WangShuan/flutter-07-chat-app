import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class NewMessage extends StatefulWidget {
  const NewMessage({super.key});
  @override
  State<NewMessage> createState() => _NewMessageState();
}

class _NewMessageState extends State<NewMessage> {
  final _messageConntroller = TextEditingController();

  @override
  void dispose() {
    _messageConntroller.dispose();
    super.dispose();
  }

  Future<void> _sendMessage() async {
    final msg = _messageConntroller.text;

    if (msg.isEmpty || msg.trim().isEmpty) return;

    FocusScope.of(context).unfocus();
    _messageConntroller.clear();

    final User? user = FirebaseAuth.instance.currentUser;

    final db = FirebaseFirestore.instance;

    await db.collection('messages').add({
      'user_id': user!.uid,
      'user_image': user.photoURL,
      'username': user.displayName,
      'text': msg,
      'create_at': Timestamp.now(),
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.background,
      padding: EdgeInsets.fromLTRB(16, 8, 16, MediaQuery.viewPaddingOf(context).bottom + 8),
      child: Stack(
        children: [
          TextField(
            controller: _messageConntroller,
            textCapitalization: TextCapitalization.sentences,
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.only(left: 16, right: 40),
              border: const OutlineInputBorder().copyWith(
                borderRadius: const BorderRadius.all(Radius.circular(8)),
              ),
              hintText: '請輸入訊息⋯⋯',
            ),
            textInputAction: TextInputAction.done,
            onEditingComplete: _sendMessage,
          ),
          Positioned(
            right: 0,
            child: IconButton(
              onPressed: _sendMessage,
              icon: Icon(
                Icons.send,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          )
        ],
      ),
    );
  }
}
