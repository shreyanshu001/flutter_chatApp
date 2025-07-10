import 'package:chat_app/widget/new_messages.dart';
import 'package:chat_app/widget/chat_messages.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:chat_app/screens/chatbot_screen.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  void setupNotifications() async {
    final fcm = FirebaseMessaging.instance;
    await fcm.requestPermission();
    fcm.subscribeToTopic('chat');
    final token = await fcm.getToken();
    print(token);
  }

  @override
  void initState() {
    super.initState();
    setupNotifications();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        title: const Text('chat_here'),
        actions: [
          IconButton(
            onPressed: () {
              FirebaseAuth.instance.signOut();
            },
            icon: const Icon(
              Icons.exit_to_app,
              color: Colors.white54,
            ),
          ),
        ],
      ),
      body: const Column(
        children: [
          Expanded(
            child: ChatMessages(),
          ),
          NewMessages()
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const ChatbotScreen(),
            ),
          );
        },
      ),
    );
  }
}
