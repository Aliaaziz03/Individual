import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:table_calendar/table_calendar.dart';

class PeriodSelectionScreenContent extends StatefulWidget {
  @override
  _PeriodSelectionScreenContentState createState() =>
      _PeriodSelectionScreenContentState();
}

class _PeriodSelectionScreenContentState
    extends State<PeriodSelectionScreenContent> {
  late DateTime _focusedDay;
  List<DateTime> _selectedDates = [];
  Timer? _saveTimer;

  @override
  void initState() {
    super.initState();
    _focusedDay = DateTime.now();
    _loadSavedDates();
  }

  Future<void> _loadSavedDates() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) return;

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('periodDates')
          .orderBy('createdAt', descending: true)
          .get();

      List<DateTime> savedDates = [];
      for (var doc in snapshot.docs) {
        DateTime startDate = DateTime.parse(doc['startDate']);
        DateTime endDate = DateTime.parse(doc['endDate']);

        for (var day = startDate;
            !day.isAfter(endDate);
            day = day.add(Duration(days: 1))) {
          savedDates.add(day);
        }
      }

      setState(() {
        _selectedDates = savedDates;
      });
    } catch (e) {
      print("Error loading saved dates: $e");
    }
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    if (selectedDay.isAfter(DateTime.now())) {
      return;
    }

    setState(() {
      _focusedDay = focusedDay;

      if (_selectedDates.contains(selectedDay)) {
        _selectedDates.remove(selectedDay);
      } else {
        _selectedDates.add(selectedDay);
      }

      _selectedDates.sort();
    });

    _saveTimer?.cancel();
    _saveTimer = Timer(Duration(seconds: 2), () => _savePeriodToFirebase());
  }

  Future<void> _savePeriodToFirebase() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null || _selectedDates.isEmpty) return;

    String startDate = _selectedDates.first.toIso8601String().split('T')[0];
    String endDate = _selectedDates.last.toIso8601String().split('T')[0];

    Map<String, dynamic> periodData = {
      'userId': user.uid,
      'startDate': startDate,
      'endDate': endDate,
      'createdAt': FieldValue.serverTimestamp(),
    };

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('periodDates')
          .add(periodData);
      print("Period saved successfully for user: ${user.email}");
    } catch (e) {
      print("Error saving period data: $e");
    }
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
          child: TableCalendar(
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2025, 12, 31),
            focusedDay: _focusedDay,
            selectedDayPredicate: (day) {
              return _selectedDates.contains(day);
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
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _saveTimer?.cancel();
    super.dispose();
  }
}
