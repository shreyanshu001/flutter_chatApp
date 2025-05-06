import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class NewMessages extends StatefulWidget {
  const NewMessages({super.key});
  @override
  State<StatefulWidget> createState() {
    return _NewMessageState();
  }
}

class _NewMessageState extends State<NewMessages> {
  final messageController = TextEditingController();
  @override
  void dispose() {
    messageController.dispose();
    super.dispose();
  }

  void _submitMessage() async {
    final enteredMessage = messageController.text;

    if (enteredMessage.trim().isEmpty) {
      return;
    }
    FocusScope.of(context).unfocus();
    messageController.clear();
    final user = FirebaseAuth.instance.currentUser!;
    final userData = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();
    if (userData.exists && userData.data() != null) {
      // final userDataMap = userData.data()!;

      FirebaseFirestore.instance.collection('chat').add({
        'text': enteredMessage,
        'createdAt': Timestamp.now(),
        'userID': user.uid,
        'username': userData.data()!['username'],
        'userImage': userData.data()!['image_url'],
      });
    } else {
      print('user data not found');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14, left: 15, right: 1),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              textCapitalization: TextCapitalization.sentences,
              autocorrect: true,
              enableSuggestions: true,
              decoration: const InputDecoration(labelText: 'send a message...'),
              controller: messageController,
            ),
          ),
          IconButton(
            color: Theme.of(context).colorScheme.primary,
            onPressed: _submitMessage,
            icon: const Icon(Icons.send),
          ),
        ],
      ),
    );
  }
}
