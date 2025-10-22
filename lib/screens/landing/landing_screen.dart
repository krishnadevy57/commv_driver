import 'package:commv_driver/screens/landing/earnings_screen.dart';
import 'package:commv_driver/screens/landing/home_screen.dart';
import 'package:commv_driver/screens/landing/wallet_screen.dart';
import 'package:commv_driver/screens/landing/trip_history_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/home_controller.dart';
import 'account_screen.dart';

class LandingScreen extends StatefulWidget {
   LandingScreen({super.key});
  final controller = Get.put(HomeController());

  @override
  State<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    HomeScreen(),
    TripHistoryScreen(),
    WalletScreen(),
    AccountScreen(),
  ];

  final List<String> _titles = [
    'Dashboard',
    'My Trips',
    'Wallet',
    'Account',
  ];

  void _onTabTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final appBarTheme = theme.appBarTheme;
    final textTheme = theme.textTheme;

    return WillPopScope(
      onWillPop: () async {
        if (_selectedIndex != 0) {
          setState(() {
            _selectedIndex = 0;
          });
          return false;
        }
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            _titles[_selectedIndex],
            style: appBarTheme.titleTextStyle ?? textTheme.titleLarge,
          ),
          centerTitle: true,
          backgroundColor: appBarTheme.backgroundColor ?? colorScheme.surface,
          elevation: appBarTheme.elevation,
          iconTheme: appBarTheme.iconTheme,
          foregroundColor: appBarTheme.iconTheme?.color,
            actions: [
            Obx(() => Padding(padding: EdgeInsets.all(10),child: (widget.controller.isUpdating.value)?const CircularProgressIndicator():Switch(
              value: widget.controller.isOnline.value,
              onChanged: (val) => widget.controller.toggleStatus(val),
              activeColor: Colors.green,
            ),)),
          ],
        ),
        body: _screens[_selectedIndex],
        bottomNavigationBar: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          backgroundColor: theme.bottomNavigationBarTheme.backgroundColor ?? colorScheme.surface,
          selectedItemColor: theme.bottomNavigationBarTheme.selectedItemColor ?? colorScheme.primary,
          unselectedItemColor: theme.bottomNavigationBarTheme.unselectedItemColor ?? colorScheme.onSurface.withOpacity(0.6),
          currentIndex: _selectedIndex,
          onTap: _onTabTapped,
          items: [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: _titles[0],
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.inventory),
              label: _titles[1],
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.payment),
              label: _titles[2],
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: _titles[3],
            ),
          ],
        ),
      ),
    );
  }
}