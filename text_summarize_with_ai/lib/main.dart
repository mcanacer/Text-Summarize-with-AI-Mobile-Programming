import 'package:flutter/material.dart';
import 'package:text_summarize_with_ai/screens/history_screen.dart';
import 'package:text_summarize_with_ai/screens/home_screen.dart';

void main() {
  runApp(const SummarizeWithAIApp());
}

class SummarizeWithAIApp extends StatelessWidget {
  const SummarizeWithAIApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Summarize with AI',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.deepPurple),
      home: const MainNavigator(),
    );
  }
}

class MainNavigator extends StatefulWidget {
  const MainNavigator({super.key});

  @override
  State<MainNavigator> createState() => _MainNavigatorState();
}

class _MainNavigatorState extends State<MainNavigator> {
  int _seciliIndex = 0;

  static const List<Widget> _ekranlar = <Widget>[HomeScreen(), HistoryScreen()];

  void _onItemTapped(int index) {
    setState(() {
      _seciliIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: _ekranlar.elementAt(_seciliIndex)),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Ana Sayfa'),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: 'Geçmiş'),
        ],
        currentIndex: _seciliIndex,
        selectedItemColor: Colors.deepPurple,
        onTap: _onItemTapped,
      ),
    );
  }
}
