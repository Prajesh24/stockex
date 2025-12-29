import 'package:flutter/material.dart';
import 'package:stockex/screen/bottom_screen/home.dart';
import 'package:stockex/screen/bottom_screen/portfolio.dart';
import 'package:stockex/screen/bottom_screen/profile.dart';
import 'package:stockex/screen/bottom_screen/watchlist.dart';

class ButtonNavigatorScreen extends StatefulWidget {
  const ButtonNavigatorScreen({super.key});

  @override
  State<ButtonNavigatorScreen> createState() => _ButtonNavigatorScreenState();
}

class _ButtonNavigatorScreenState extends State<ButtonNavigatorScreen> {
  int _selectedIndex = 0;

  List<Widget> lstBottomScreen = [
    HomeScreen(),
    PortfolioScreen(),
    ProfileScreen(),
    WatchlistScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Stockex',
          style: TextStyle(
            color: Colors.white,
            fontFamily: 'OpenScans Bold',
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 28, 29, 28),
      ),
      body: lstBottomScreen[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(Icons.card_travel),
            label: 'Portfolio',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.remove_red_eye),
            label: 'Watchlist',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
        backgroundColor: const Color.fromARGB(255, 28, 29, 28),
        selectedItemColor: Colors.green,
        unselectedItemColor: Colors.white,
        iconSize: 27,
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
    );
  }
}
