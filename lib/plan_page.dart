import 'package:flutter/material.dart';
import 'package:flutter_test_diplom/zeichenflaeche.dart';

class PlanPage extends StatefulWidget {
  const PlanPage({super.key});

  @override
  State<PlanPage> createState() => PlanPageContent();
}

class PlanPageContent extends State<PlanPage> {
  int _selectedNavBarItem = 0;

  void switchBottomNavbarItem(int targetIndex) {
    setState(() {
      _selectedNavBarItem = targetIndex;
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Fliesenleger"),
        foregroundColor: Colors.white,
        backgroundColor: Colors.purple,
      ),
      body: const Zeichenflaeche(),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: "Settings",
          ),
        ],
        currentIndex: _selectedNavBarItem,
        selectedItemColor: Colors.black,
        onTap: switchBottomNavbarItem,
        unselectedItemColor: Colors.white,
        backgroundColor: Colors.purple,
      ),
    );
  }
}
