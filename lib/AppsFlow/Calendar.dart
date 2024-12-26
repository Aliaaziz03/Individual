import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shake/shake.dart';

class PeriodSelectionScreen extends StatefulWidget {
  @override
  _PeriodSelectionScreenState createState() => _PeriodSelectionScreenState();
}

class _PeriodSelectionScreenState extends State<PeriodSelectionScreen> {
  late DateTime _focusedDay;
  List<DateTime> _selectedDates = [];
  List<List<DateTime>> _periods = [];
  int _selectedIndex = 0; // For navigation bar

  @override
  void initState() {
    super.initState();
    _focusedDay = DateTime.now();

    // Initialize the shake detector
    ShakeDetector.autoStart(
      onPhoneShake: () {
        _savePeriodToFirebase(_selectedDates);
      },
    );
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    if (selectedDay.isAfter(DateTime.now())) {
      // If the selected day is in the future, do nothing
      return;
    }

    setState(() {
      _focusedDay = focusedDay;

      // If the date is already selected, remove it
      if (_selectedDates.contains(selectedDay)) {
        _selectedDates.remove(selectedDay);
      } else {
        _selectedDates.add(selectedDay);
      }

      // Sort the list to make sure the dates are in chronological order
      _selectedDates.sort();
      _periods = _detectPeriods(_selectedDates);
    });
  }

  List<List<DateTime>> _detectPeriods(List<DateTime> selectedDates) {
    List<List<DateTime>> periods = [];
    List<DateTime> currentPeriod = [];

    for (int i = 0; i < selectedDates.length; i++) {
      if (currentPeriod.isEmpty) {
        currentPeriod.add(selectedDates[i]);
      } else {
        if (selectedDates[i].difference(currentPeriod.last).inDays > 1) {
          periods.add(currentPeriod);
          currentPeriod = [selectedDates[i]];
        } else {
          currentPeriod.add(selectedDates[i]);
        }
      }
    }
    if (currentPeriod.isNotEmpty) {
      periods.add(currentPeriod);
    }
    return periods;
  }

  Future<void> _savePeriodToFirebase(List<DateTime> periodDates) async {
    if (periodDates.isEmpty) return;

    String startDate = periodDates.first.toIso8601String().split('T')[0];
    String endDate = periodDates.last.toIso8601String().split('T')[0];

    Map<String, dynamic> periodData = {
      'startDate': startDate,
      'endDate': endDate,
      'createdAt': FieldValue.serverTimestamp(),
    };

    try {
      await FirebaseFirestore.instance.collection('periodDates').add(periodData);
      print("Period saved successfully!");
    } catch (e) {
      print("Error saving period data: $e");
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    // Add navigation logic here for each index
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
        actions: [
          IconButton(
            icon: Icon(Icons.notifications, color: Colors.white),
            onPressed: () {
              // Handle notification icon tap
              print("Notification tapped");
            },
          ),
        ],
      ),
      body: Column(
        children: [
        Container(
  margin: EdgeInsets.all(16),
  padding: EdgeInsets.all(16),
  decoration: BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(16),
    boxShadow: [
      BoxShadow(
        color: Colors.pink.withOpacity(0.3), // Adjust opacity for a glowing effect
        blurRadius: 20, // Increase blur for a soft glow
        spreadRadius: 5, // Spread the glow effect further
        offset: Offset(0, 5), // Subtle elevation effect
      ),
    ],
  ),
  child: TableCalendar(
    firstDay: DateTime.utc(2020, 1, 1),
    lastDay: DateTime.utc(2025, 12, 31),
    focusedDay: _focusedDay,
    selectedDayPredicate: (day) {
      return _periods.any((period) => period.contains(day));
    },
    onDaySelected: _onDaySelected,
    calendarStyle: CalendarStyle(
      selectedDecoration: BoxDecoration(
        color: Colors.red,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.redAccent.withOpacity(0.4), // Add glow to selected days
            blurRadius: 15,
            spreadRadius: 3,
          ),
        ],
      ),
      todayDecoration: BoxDecoration(
        color: Colors.orange,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.orange.withOpacity(0.4), // Glow for today
            blurRadius: 15,
            spreadRadius: 3,
          ),
        ],
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
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                
                _buildInfoCard(
                  color: Colors.pink.shade100,
                  icon: Icons.bloodtype,
                  title: '5 Days',
                  subtitle: 'Average period'
                ),
                _buildInfoCard(
                  color: Colors.orange.shade100,
                  icon: Icons.loop,
                  title: '28 Days',
                  subtitle: 'Average cycle',
                ),
              ],
            ),
          ),
          Expanded(
            child: Container(
              color: Colors.pink.shade50,
              child: ListView(
                children: [
                  for (var period in _periods) ...[
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        '${period.first.toLocal().toString().split(' ')[0]} to ${period.last.toLocal().toString().split(' ')[0]}',
                        style: TextStyle(fontSize: 16, color: Colors.pink.shade700),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.pink.shade100,
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
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
      ),
    );
  }

  Widget _buildInfoCard({
    required Color color,
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.pink, size: 32),
          SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.pink.shade800,
            ),
          ),
          SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 14,
              color: Colors.pink.shade600,
            ),
          ),
        ],
      ),
    );
  }
}