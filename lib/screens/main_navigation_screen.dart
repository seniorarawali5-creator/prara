import 'package:flutter/material.dart';
import 'package:prashant/screens/home/home_screen.dart';
import 'package:prashant/screens/chat/chat_screen.dart';
import 'package:prashant/screens/friends/friends_screen.dart';
import 'package:prashant/screens/notes/notes_screen.dart';
import 'package:prashant/screens/settings/settings_screen.dart';
import 'package:prashant/screens/stories/stories_screen.dart';
import 'package:prashant/screens/analytics/analytics_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({Key? key}) : super(key: key);

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    const ChatScreen(),
    const FriendsScreen(),
    const NotesScreen(),
    const StoriesScreen(),
    const AnalyticsScreen(),
    const SettingsScreen(),
  ];

  final List<BottomNavigationBarItem> _navItems = [
    const BottomNavigationBarItem(
      icon: Icon(Icons.home_outlined),
      activeIcon: Icon(Icons.home),
      label: 'Home',
    ),
    const BottomNavigationBarItem(
      icon: Icon(Icons.chat_outlined),
      activeIcon: Icon(Icons.chat),
      label: 'Chat',
    ),
    const BottomNavigationBarItem(
      icon: Icon(Icons.people_outline),
      activeIcon: Icon(Icons.people),
      label: 'Friends',
    ),
    const BottomNavigationBarItem(
      icon: Icon(Icons.note_outlined),
      activeIcon: Icon(Icons.note),
      label: 'Notes',
    ),
    const BottomNavigationBarItem(
      icon: Icon(Icons.image_outlined),
      activeIcon: Icon(Icons.image),
      label: 'Stories',
    ),
    const BottomNavigationBarItem(
      icon: Icon(Icons.trending_up_outlined),
      activeIcon: Icon(Icons.trending_up),
      label: 'Analytics',
    ),
    const BottomNavigationBarItem(
      icon: Icon(Icons.settings_outlined),
      activeIcon: Icon(Icons.settings),
      label: 'Settings',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: (index) => setState(() => _selectedIndex = index),
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: const Color(0xFF6366F1),
          unselectedItemColor: Colors.grey,
          selectedFontSize: 12,
          unselectedFontSize: 12,
          items: _navItems,
        ),
      ),
    );
  }
}
