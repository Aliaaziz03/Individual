import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';

class MoodTrackerPage extends StatefulWidget {
  @override
  _MoodTrackerPageState createState() => _MoodTrackerPageState();
}

class _MoodTrackerPageState extends State<MoodTrackerPage> {
  static const double shakeThreshold = 15.0; // Sensitivity for shake detection
  late StreamSubscription _accelerometerSubscription;
  bool _isSnackbarActive = false;
  bool _hasSelectedMood = false; // Track if the user has selected their mood for the day

  @override
  void initState() {
    super.initState();
    _startShakeDetection();
    _showSnackbarPeriodically();
  }

  @override
  void dispose() {
    _accelerometerSubscription.cancel();
    super.dispose();
  }

  void _startShakeDetection() {
    _accelerometerSubscription = accelerometerEvents.listen((event) {
      if (_hasSelectedMood) return; // Don't detect shakes if the user has selected their mood

      double gX = event.x;
      double gY = event.y;
      double gZ = event.z;

      double gForce = sqrt(gX * gX + gY * gY + gZ * gZ) - 9.8; // Gravity compensation
      if (gForce > shakeThreshold) {
        _showMoodPrompt();
      }
    });
  }

  void _showMoodPrompt() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("How's your mood?"),
          content: Wrap(
            spacing: 10,
            children: [
              IconButton(
                icon: Text('😊', style: TextStyle(fontSize: 30)),
                onPressed: () => _submitMood("Happy"),
              ),
              IconButton(
                icon: Text('😢', style: TextStyle(fontSize: 30)),
                onPressed: () => _submitMood("Sad"),
              ),
              IconButton(
                icon: Text('😡', style: TextStyle(fontSize: 30)),
                onPressed: () => _submitMood("Angry"),
              ),
              IconButton(
                icon: Text('😴', style: TextStyle(fontSize: 30)),
                onPressed: () => _submitMood("Tired"),
              ),
              IconButton(
                icon: Text('😎', style: TextStyle(fontSize: 30)),
                onPressed: () => _submitMood("Cool"),
              ),
            ],
          ),
        );
      },
    );
  }

  void _submitMood(String mood) {
    Navigator.of(context).pop(); // Close the dialog
    setState(() {
      _hasSelectedMood = true; // Mark mood as selected
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("You feel $mood"),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _showSnackbarPeriodically() {
    Timer.periodic(Duration(seconds: 10), (timer) {
      if (mounted && !_isSnackbarActive && !_hasSelectedMood) {
        _isSnackbarActive = true;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Shake to tell us your mood!"),
            duration: Duration(seconds: 2),
          ),
        ).closed.then((_) {
          _isSnackbarActive = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Mood Tracker")),
      body: Center(
        child: Text(
          "Shake your phone to update your mood!",
          style: TextStyle(fontSize: 18),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
