import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:individual1/AppsFlow/Calendar.dart';
import 'package:individual1/AppsFlow/homepage.dart';
import 'package:individual1/AppsFlow/profile.dart';
import 'package:individual1/authentication/login.dart';
import 'package:table_calendar/table_calendar.dart';

class PeriodSelectionScreen extends StatefulWidget {
  @override
  _PeriodSelectionScreenState createState() => _PeriodSelectionScreenState();
}

class _PeriodSelectionScreenState extends State<PeriodSelectionScreen> {
  int _selectedIndex = 1;


  // Pages for bottom navigation
  final List<Widget> _pages = [
    PeriodSelectionScreenContent(),
    HomePage(),
    Profile(),
  ];

  @override

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.pink,
        title: Text(
          "MENSTRUAL CALENDAR",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
            leading:IconButton(
            icon: const Icon(Icons.logout),
            color: Colors.white,
            onPressed: () {
             Navigator.of(context).pushReplacement(
             MaterialPageRoute(builder: (_) => LoginPage()),);
                      },
                    ),
        actions: [
          
          IconButton(
            icon: Icon(Icons.notifications, color: Colors.white),
            onPressed: () {
              print("Notification tapped");
            },
          ),
        ],
      ),
      body: _pages[_selectedIndex], // Dynamically show the selected page
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'Calendar',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.pink,
        onTap: _onItemTapped,
      ),
    );
  }
}
