import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

import './firebase_options.dart';
import './screens/auth_screen.dart';
import './screens/chat_screen.dart';
import './screens/loading_screen.dart';

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
    final ColorScheme colorScheme = ColorScheme.fromSeed(
      seedColor: const Color.fromARGB(255, 38, 164, 206),
      primary: const Color.fromARGB(255, 81, 187, 235),
      background: const Color.fromARGB(255, 236, 249, 255),
      error: const Color.fromARGB(255, 234, 126, 90),
    );

    return MaterialApp(
      title: 'FlutterChat',
      theme: ThemeData().copyWith(
        useMaterial3: true,
        colorScheme: colorScheme,
        scaffoldBackgroundColor: colorScheme.background,
        appBarTheme: AppBarTheme(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
        ),
      ),
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) => snapshot.connectionState == ConnectionState.waiting
            ? const LoadingScreen()
            : snapshot.hasData
                ? const ChatScreen()
                : const AuthScreen(),
      ),
    );
  }
}
