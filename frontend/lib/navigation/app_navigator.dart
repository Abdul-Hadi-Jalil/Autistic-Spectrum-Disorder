import 'package:flutter/material.dart';
import 'package:frontend/app_flow_handle_screens/main_screen.dart';

/// Root navigator key — use for navigation that must clear the full stack
/// (e.g. after signup when auth state changes underneath pushed routes).
final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();

void navigateToMain({int initialIndex = 1}) {
  rootNavigatorKey.currentState?.pushAndRemoveUntil(
    MaterialPageRoute(builder: (_) => MainScreen(initialIndex: initialIndex)),
    (route) => false,
  );
}
