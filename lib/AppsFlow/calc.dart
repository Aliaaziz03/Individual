import 'package:flutter/material.dart';
import 'package:individual1/AppsFlow/homepage.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Calculate extends StatefulWidget {
  const Calculate({super.key});

  @override
  State<Calculate> createState() => _CalculateState();
}

class _CalculateState extends State<Calculate> {
   late DateTime _focusedDay;
  List<DateTime> _selectedDates = [];
  String _daysLeft = '';
  double _averageCycle = 28.0; // Default cycle length

  @override
  void initState() {
    super.initState();
    _focusedDay = DateTime.now();
    _loadSavedDates();
  }

  /// Load saved dates from Firestore
  Future<void> _loadSavedDates() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) return;

    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (doc.exists) {
        final data = doc.data();
        if (data != null && data['selectedDates'] is List) {
          List<DateTime> savedDates = (data['selectedDates'] as List)
              .map((date) => DateTime.parse(date))
              .toList();

          setState(() {
            _selectedDates = savedDates;
            _calculateDaysUntilNextPeriod();
            _calculateAverageCycle(); // Add this call here to calculate the average cycle
          });
        }
      }
    } catch (e) {
      print("Error loading saved dates: $e");
    }
  }

  /// Save selected dates to Firestore
  Future<void> _saveSelectedDatesToFirebase() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) return;

    try {
      List<String> formattedDates = _selectedDates
          .map((date) => date.toIso8601String().split('T')[0])
          .toList();

      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .set({
        "selectedDates": formattedDates,
      }, SetOptions(merge: true));

      print("Selected dates saved successfully.");
    } catch (e) {
      print("Error saving selected dates: $e");
    }
  }

  /// Handle date selection
  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    // Prevent selecting future dates
    if (selectedDay.isAfter(DateTime.now())) {
      return; // Do nothing if the date is in the future
    }

    setState(() {
      _focusedDay = focusedDay;

      if (_selectedDates.contains(selectedDay)) {
        _selectedDates.remove(selectedDay);
      } else {
        _selectedDates.add(selectedDay);
      }
    });

    _saveSelectedDatesToFirebase();
    _calculateDaysUntilNextPeriod();
    _calculateAverageCycle(); // Ensure average cycle is calculated when a date is selected
  }

  /// Calculate the average cycle length
  void _calculateAverageCycle() {
    if (_selectedDates.length > 1) {
      // Ensure the dates are sorted
      _selectedDates.sort();

      List<int> cycleLengths = [];

      for (int i = 1; i < _selectedDates.length; i++) {
        int cycleLength =
            _selectedDates[i].difference(_selectedDates[i - 1]).inDays;

        // Consider only realistic cycle lengths (e.g., greater than 20 days)
        if (cycleLength > 20) {
          cycleLengths.add(cycleLength);
        }
      }

      if (cycleLengths.isNotEmpty) {
        int totalCycleLength = cycleLengths.reduce((a, b) => a + b);
        _averageCycle =
            (totalCycleLength / cycleLengths.length).roundToDouble();
      } else {
        // Default to 28 days if no valid cycles are found
        _averageCycle = 28.0;
      }
    } else {
      // Default to 28 days if there are not enough dates
      _averageCycle = 28.0;
    }
  }

  /// Calculate days left until the next period
  void _calculateDaysUntilNextPeriod() {
    if (_selectedDates.isEmpty) return;

    _selectedDates.sort();

    DateTime lastDate = _selectedDates.last;
    _calculateAverageCycle();

    DateTime nextPeriod = lastDate.add(Duration(days: _averageCycle.toInt()));
    int daysLeft = nextPeriod.difference(DateTime.now()).inDays;

    setState(() {
      _daysLeft = daysLeft > 0
          ? '$daysLeft days until your next period'
          : 'Your period is here!';
    });
  }
  

  @override
  Widget build(BuildContext context) {
    return HomePage(daysLeft: _daysLeft);
  }
}