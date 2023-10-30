import 'package:flutter/material.dart';
import './pages/RecipeLandingPage.dart';
import './pages/HistoryLandingPage.dart';
import './pages/ProfileLandingPage.dart';

class ConsciousCart extends StatefulWidget {
  @override
  State<ConsciousCart> createState() => _ConsciousCartState();
}

class _ConsciousCartState extends State<ConsciousCart> {

  var selectedIndex = 0;

  final List<Widget> pages = [
    RecipeLandingPage(),
    HistoryLandingPage(),
    ProfileLandingPage(),
  ];

  void onTabTapped(int index) {
    setState(() {
      selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context){
    return Scaffold(
      body: pages[selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        onTap: onTabTapped,
        currentIndex: selectedIndex,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.restaurant_menu_rounded),
            label: 'New Recipe',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.format_list_bulleted_rounded),
            label: 'History',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_rounded),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}