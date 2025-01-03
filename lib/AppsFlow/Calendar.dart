import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:table_calendar/table_calendar.dart';

class PeriodSelectionScreenContent extends StatefulWidget {
  @override
   final Function(String) onDaysLeftUpdated;
   const PeriodSelectionScreenContent({Key? key, required this.onDaysLeftUpdated}) : super(key: key);

  _PeriodSelectionScreenContentState createState() =>
      _PeriodSelectionScreenContentState();
}

class _PeriodSelectionScreenContentState
    extends State<PeriodSelectionScreenContent> {
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
          ? '$daysLeft'
          : 'Your period is here!';
    });
     widget.onDaysLeftUpdated(_daysLeft.toString()); // Notify the parent widget
  }
  

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          margin: EdgeInsets.all(16),
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.pink.withOpacity(0.3),
                blurRadius: 20,
                spreadRadius: 5,
                offset: Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            children: [
              TableCalendar(
                firstDay: DateTime.utc(2020, 1, 1),
                lastDay: DateTime.utc(2025, 12, 31),
                focusedDay: _focusedDay,
                selectedDayPredicate: (day) {
                  return _selectedDates.any((selectedDate) =>
                      isSameDay(selectedDate, day));
                },
                onDaySelected: _onDaySelected,
                calendarStyle: CalendarStyle(
                  selectedDecoration: BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                  todayDecoration: BoxDecoration(
                    color: Colors.orange,
                    shape: BoxShape.circle,
                  ),
                ),
                headerStyle: HeaderStyle(
                  formatButtonVisible: false,
                  titleCentered: true,
                  titleTextStyle: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                availableGestures: AvailableGestures.none, // Disable swipe gestures
              ),
              SizedBox(height: 16),
              Text(
                _daysLeft,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
              Text(
                'Average Cycle: ${_averageCycle.toInt()} days', // Display average cycle
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
