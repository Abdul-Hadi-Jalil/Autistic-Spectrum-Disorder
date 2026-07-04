// This Screen is used to decide which screen to show next login or dashboard screen
// based on user. If user is logged in then move to dashboard screen else show login screen.
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:frontend/app_flow_handle_screens/main_screen.dart';
import 'package:frontend/app_flow_handle_screens/preference_screen.dart';

class AuthStateScreen extends StatelessWidget {
  const AuthStateScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.hasData) {
          // Returning, signed-in user lands on the login dashboard tab.
          return const MainScreen(initialIndex: 1);
        }
        return const PreferenceScreen();
      },
    );
  }
}
