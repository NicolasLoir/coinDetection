import 'dart:ui';

import 'package:coco/pages/history/page_historique.dart';
import 'package:coco/pages/analyse/page_home.dart';
import 'package:coco/pages/camera/page_photo.dart';
import 'package:coco/pages/update_profil/page_profil.dart';
import 'package:coco/utils/sharedPref.dart';
import 'package:flutter/material.dart';

class NavigationPage extends StatefulWidget {
  // String idUtilisateur;
  const NavigationPage({Key? key}) : super(key: key);

  @override
  _NavigationPageState createState() => _NavigationPageState();
}

class _NavigationPageState extends State<NavigationPage> {
  int _currentIndex = 0;
  Color _currentColor = Colors.orange;
  final PageController _pageController = PageController(initialPage: 0);

  final tabs = [
    const Photo(),
    const Home(),
    const Historique(),
    const Profil(),
  ];

  @override
  void initState() {
    SharedPref.getUuid();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
            _currentColor = getSelectedItemColor(index);
          });
        },
        children: tabs,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.black,
        unselectedItemColor: Colors.white,
        selectedItemColor: _currentColor,
        showSelectedLabels: true,
        showUnselectedLabels: false,
        selectedLabelStyle:
            const TextStyle(fontWeight: FontWeight.bold, fontSize: 10),
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.photo_camera),
            label: "^",
            backgroundColor: Theme.of(context).primaryColorDark,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.analytics),
            label: "^",
            backgroundColor: Theme.of(context).primaryColorDark,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.history),
            label: "^",
            backgroundColor: Theme.of(context).primaryColorDark,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.person),
            label: "^",
            backgroundColor: Theme.of(context).primaryColorDark,
          ),
        ],
        onTap: (index) {
          setState(() {
            _pageController.animateToPage(index,
                duration: const Duration(milliseconds: 500),
                curve: Curves.ease);
          });
        },
      ),
    );
  }

  Color getSelectedItemColor(index) {
    switch (index) {
      case 0:
        return Colors.orange;
      case 1:
        return Colors.yellow;
      case 2:
        return Colors.green;
      case 3:
        return Colors.blue;
      default:
        return Colors.white;
    }
  }
}
