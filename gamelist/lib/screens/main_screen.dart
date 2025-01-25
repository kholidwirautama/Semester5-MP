import 'package:flutter/material.dart';
import 'package:game_list/screens/liked_screen.dart';
import 'package:game_list/screens/home_screen.dart';
import 'package:game_list/screens/more_screen.dart';
import 'package:game_list/screens/search_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});
  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  static const List<Widget> screenOptions = <Widget>[
    HomeScreen(),
    SearchScreen(),
    LikedScreen(),
    MoreScreen(),
  ];
  void _onTapOptions(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: screenOptions.elementAt(_selectedIndex),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
          BottomNavigationBarItem(icon: Icon(Icons.favorite_border), label: 'Liked'),
          BottomNavigationBarItem(icon: Icon(Icons.more_vert), label: 'More'),
        ],
        currentIndex: _selectedIndex,
        onTap: _onTapOptions,
        showSelectedLabels: true,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.grey,
      ),
    );
  }
}
