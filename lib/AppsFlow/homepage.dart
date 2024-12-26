import 'package:flutter/material.dart';
import 'package:individual1/authentication/login.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  double moodSwingsValue = 2; // Scale from 1 (normal) to 5 (very bad)
  double headacheValue = 2;
  double crampsValue = 2;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "My Cycle",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.pink,
        centerTitle: true,
          // Logout Button
          leading:IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
             Navigator.of(context).pushReplacement(
             MaterialPageRoute(builder: (_) => LoginPage()),);
                      },
                    ),
                  
                ),
              
      
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const SizedBox(height: 50), // Space from the top

              // Circle displaying the countdown
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
                  children: const [
                    Text(
                      "2", // Number of days
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

              // Symptom tracking interface
              buildSymptomSlider(
                context,
                "Mood Swings",
                moodSwingsValue,
                (value) {
                  setState(() {
                    moodSwingsValue = value;
                  });
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
                },
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
