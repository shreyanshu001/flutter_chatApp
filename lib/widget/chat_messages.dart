import 'package:chat_app/widget/message_bubble.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ChatMessages extends StatelessWidget {
  const ChatMessages({super.key});
  @override
  Widget build(BuildContext context) {
    final authenticatedUser = FirebaseAuth.instance.currentUser!;
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('chat')
          .orderBy('createdAt', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(
            child: Text('No Messages found'),
          );
        }
        if (snapshot.hasError) {
          return const Center(
            child: Text('Something Went Wrong...'),
          );
        }
        final loadedMessages = snapshot.data!.docs;
        return ListView.builder(
          padding: const EdgeInsets.only(bottom: 40, left: 13, right: 13),
          reverse: true,
          itemBuilder: (context, index) {
            final chatMessage = loadedMessages[index].data();
            final nextChatMessage = index + 1 < loadedMessages.length
                ? loadedMessages[index + 1].data()
                : null;
            final currentChatMessageUserID = chatMessage['userId'];
            final nextChatMessageUserID =
                nextChatMessage != null ? nextChatMessage['userId'] : null;
            final nextUserIsSame =
                currentChatMessageUserID == nextChatMessageUserID;
            if (nextUserIsSame) {
              return MessageBubble.next(
                  message: chatMessage['text'],
                  isMe: authenticatedUser.uid == currentChatMessageUserID);
            } else {
              return MessageBubble.first(
                  userImage: chatMessage['userImage'],
                  username: chatMessage['username'],
                  message: chatMessage['text'],
                  isMe: authenticatedUser.uid == currentChatMessageUserID);
            }
          },
          itemCount: loadedMessages.length,
        );
      },
    );
  }
}
