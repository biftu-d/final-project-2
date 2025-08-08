import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../models/user_model.dart';
import '../utils/app_theme.dart';
import 'home/home_screen.dart';
import 'search/search_screen.dart';
import 'bookings/bookings_screen.dart';
import 'dashboard/dashboard_screen.dart';
import 'profile/profile_screen.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final isProvider = authProvider.user?.role == UserRole.provider;

    final List<Widget> screens = isProvider
        ? [
            const HomeScreen(),
            const DashboardScreen(),
            const BookingsScreen(),
            const ProfileScreen(),
          ]
        : [
            const HomeScreen(),
            const SearchScreen(),
            const BookingsScreen(),
            const ProfileScreen(),
          ];

    final List<BottomNavigationBarItem> navItems = isProvider
        ? [
            const BottomNavigationBarItem(
              icon: Icon(Icons.home_rounded),
              label: 'Home',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.dashboard_rounded),
              label: 'Dashboard',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.calendar_today_rounded),
              label: 'Bookings',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.person_rounded),
              label: 'Profile',
            ),
          ]
        : [
            const BottomNavigationBarItem(
              icon: Icon(Icons.home_rounded),
              label: 'Home',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.search_rounded),
              label: 'Search',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.calendar_today_rounded),
              label: 'Bookings',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.person_rounded),
              label: 'Profile',
            ),
          ];

    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: screens),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        backgroundColor: AppTheme.primaryBlack,
        selectedItemColor: AppTheme.accentGold,
        unselectedItemColor: AppTheme.textGray,
        selectedLabelStyle: AppTheme.bodySmall.copyWith(
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: AppTheme.bodySmall,
        items: navItems,
      ),
    );
  }
}
