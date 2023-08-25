import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import './time_text.dart';
import './user_image.dart';

class MessageItem extends StatelessWidget {
  const MessageItem(this.user, this.item, {super.key});
  final User? user;
  final Map<String, dynamic> item;
  @override
  Widget build(BuildContext context) {
    final isCurrentUser = user!.uid == item['user_id'];
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isCurrentUser) UserImage(item['user_image']),
          Expanded(
            child: Container(
              margin: isCurrentUser ? const EdgeInsets.only(right: 8, left: 32) : const EdgeInsets.only(left: 8, right: 32),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                  topRight: const Radius.circular(8),
                  topLeft: const Radius.circular(8),
                  bottomRight: !isCurrentUser ? const Radius.circular(8) : const Radius.circular(0),
                  bottomLeft: isCurrentUser ? const Radius.circular(8) : const Radius.circular(0),
                ),
                color: isCurrentUser ? Theme.of(context).colorScheme.primaryContainer : Theme.of(context).colorScheme.secondaryContainer,
              ),
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item['username'],
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item['text'],
                    style: const TextStyle(fontWeight: FontWeight.normal),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Spacer(),
                      TimeText(DateTime.fromMillisecondsSinceEpoch(item['create_at'].seconds * 1000)),
                    ],
                  ),
                ],
              ),
            ),
          ),
          if (isCurrentUser) UserImage(item['user_image']),
        ],
      ),
    );
  }
}
