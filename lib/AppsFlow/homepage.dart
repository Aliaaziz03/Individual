import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatefulWidget {
  final String daysLeft;
  const HomePage({required this.daysLeft, Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  double moodSwingsValue = 2;
  double headacheValue = 2;
  double crampsValue = 2;
  bool _hasSelectedMood = false;
  bool _isSnackbarActive = false;
  late StreamSubscription _accelerometerSubscription;

  static const double shakeThreshold = 15.0;

  @override
  void initState() {
    super.initState();
    _loadSavedValues();
    _startShakeDetection();
    _showSnackbarPeriodically();
  }

  @override
  void dispose() {
    _accelerometerSubscription.cancel();
    super.dispose();
  }

  Future<void> _loadSavedValues() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      moodSwingsValue = prefs.getDouble('moodSwingsValue') ?? 2;
      headacheValue = prefs.getDouble('headacheValue') ?? 2;
      crampsValue = prefs.getDouble('crampsValue') ?? 2;
      _hasSelectedMood = prefs.getBool('hasSelectedMood') ?? false;
    });
  }

  Future<void> _saveValue(String key, dynamic value) async {
    final prefs = await SharedPreferences.getInstance();
    if (value is double) {
      await prefs.setDouble(key, value);
    } else if (value is bool) {
      await prefs.setBool(key, value);
    }
  }

  void _startShakeDetection() {
    _accelerometerSubscription = accelerometerEvents.listen((event) {
      double gX = event.x;
      double gY = event.y;
      double gZ = event.z;

      double gForce = sqrt(gX * gX + gY * gY + gZ * gZ) - 9.8;
      if (gForce > shakeThreshold && !_hasSelectedMood) {
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
    Navigator.of(context).pop();
    setState(() {
      _hasSelectedMood = true;
    });
    _saveValue('hasSelectedMood', true);
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
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const SizedBox(height: 50),
              Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.pink.shade100,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.pink.withOpacity(0.4),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      widget.daysLeft.isEmpty ? "0" : widget.daysLeft,
                      style: TextStyle(
                        fontSize: 150,
                        fontWeight: FontWeight.bold,
                        color: Colors.pink,
                      ),
                    ),
                    Text(
                      "days until your next period",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.pink,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                "Track your cycle and stay prepared!",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 20),
              buildSymptomSlider(
                context,
                "Mood Swings",
                moodSwingsValue,
                (value) {
                  setState(() {
                    moodSwingsValue = value;
                  });
                  _saveValue('moodSwingsValue', value);
                },
              ),
              buildSymptomSlider(
                context,
                "Headache",
                headacheValue,
                (value) {
                  setState(() {
                    headacheValue = value;
                  });
                  _saveValue('headacheValue', value);
                },
              ),
              buildSymptomSlider(
                context,
                "Cramps",
                crampsValue,
                (value) {
                  setState(() {
                    crampsValue = value;
                  });
                  _saveValue('crampsValue', value);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildSymptomSlider(
    BuildContext context,
    String label,
    double currentValue,
    ValueChanged<double> onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Container(
        margin: EdgeInsets.all(16),
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.pink.withOpacity(0.4),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            Slider(
              value: currentValue,
              min: 1,
              max: 5,
              divisions: 4,
              activeColor: Colors.pink,
              inactiveColor: Colors.pink.shade100,
              label: getSymptomLabel(currentValue),
              onChanged: onChanged,
            ),
          ],
        ),
      ),
    );
  }

  String getSymptomLabel(double value) {
    switch (value.round()) {
      case 1:
        return "Normal";
      case 2:
        return "Mild";
      case 3:
        return "Moderate";
      case 4:
        return "Bad";
      case 5:
        return "Very Bad";
      default:
        return "";
    }
  }
}
