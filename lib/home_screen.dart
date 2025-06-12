import 'package:flutter/material.dart';
import 'home_tab/schedule_tab.dart';
import 'home_tab/recipe_tab.dart';
import 'home_tab/convenience_tab.dart';  // ← 추가
import 'home_tab/chat_tab.dart';
import 'home_tab/settings_tab.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  static const List<Widget> _pages = <Widget>[
    ScheduleTab(),
    RecipeTab(),
    ConvenienceTab(),  // ← 추가
    ChatTab(),
    SettingsTab(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8E1),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFF8E1),
        title: const Text(
          'ATTEA',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.w900,
            fontSize: 22,
            letterSpacing: 1.5,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.brown),
      ),
      body: Column(
        children: [
          const Divider(height: 1, thickness: 0.5, color: Colors.brown),
          Expanded(child: _pages[_selectedIndex]),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color(0xFFFFF3E0),
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.brown[800],
        unselectedItemColor: Colors.brown[200],
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
        unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.normal),
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: '일정',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.restaurant_menu),
            label: '레시피',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.widgets_outlined),
            label: '편의기능', // ← 추가된 탭
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat),
            label: '채팅',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: '설정',
          ),
        ],
      ),
    );
  }
}
