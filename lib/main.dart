import 'package:chat_app/screens/chat.dart';
import 'package:chat_app/screens/auth.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'FlutterChat',
        theme: ThemeData().copyWith(
          colorScheme: ColorScheme.fromSeed(
              seedColor: const Color.fromARGB(255, 63, 17, 177)),
        ),
        home: StreamBuilder(
          stream: FirebaseAuth.instance
              .authStateChanges(), //we set up a listener that's in the end managed by the Firebase SDK under the hood.And Firebase will emit a new value whenever anything auth related changes.
          //So for example,if a token becomes available or if a token is removed because the user was logged out, for example. So authStateChanges will give us such a stream and snapshot therefore then in the end will be a user data package, you could say,created and emitted by Firebase.
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return const ChatScreen();
            }
            return const AuthScreen();
          },
        ));
  }
}
