// This screen has the implementation of bottom navigation bar.
// which helps user to change between screens using bottom nav.
import 'package:flutter/material.dart';
import 'package:frontend/screens/account_screen.dart';
import 'package:frontend/screens/clinical_dashboard_screen.dart';
import 'package:frontend/screens/parent_dashboard_screen.dart';
import 'package:frontend/screens/reports_screen.dart';
import 'package:frontend/screens/welcome_screen.dart';
import 'package:frontend/services/user_service.dart';
import 'package:frontend/widgets/app_bottom_nav.dart';

/// Host scaffold that owns the shared bottom navigation bar.
///
/// Tabs:
///   0 - Dashboard  -> Welcome (parent) or Clinical Dashboard (clinical)
///   1 - Screenings -> Parent Dashboard ("login dashboard")
///   2 - Reports    -> Reports
///   3 - Account    -> Account
class MainScreen extends StatefulWidget {
  final int initialIndex;
  const MainScreen({super.key, this.initialIndex = 1});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  late int _index = widget.initialIndex;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: UserService.instance.watchProfile(),
      builder: (context, snapshot) {
        final isClinical = snapshot.data?.isClinical ?? false;
        final dashboardTab = isClinical
            ? const ClinicalDashboardScreen()
            : const WelcomeScreen();

        final tabs = [
          dashboardTab,
          const ParentDashboardScreen(),
          const ReportsScreen(),
          const AccountScreen(),
        ];

        return Scaffold(
          body: IndexedStack(index: _index, children: tabs),
          bottomNavigationBar: AppBottomNav(
            currentIndex: _index,
            onTap: (i) => setState(() => _index = i),
          ),
        );
      },
    );
  }
}
