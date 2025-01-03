import 'package:flutter/material.dart';
import 'package:individual1/AppsFlow/homepage.dart';
import 'package:local_auth/local_auth.dart';

class FingerprintAuthPage extends StatefulWidget {
  @override
  _FingerprintAuthPageState createState() => _FingerprintAuthPageState();
}

class _FingerprintAuthPageState extends State<FingerprintAuthPage> {
    String _daysLeft = '';

   // Method to update daysLeft value
  void updateDaysLeft(String daysLeft) {
    setState(() {
      _daysLeft = daysLeft;
    });
  }

  final LocalAuthentication _localAuth = LocalAuthentication();
  bool _isAuthenticated = false;
  String _authMessage = "Please authenticate to proceed.";

  Future<void> _authenticateWithFingerprint() async {
    try {
      // Check if fingerprint (biometric) authentication is available
      bool isBiometricAvailable = await _localAuth.canCheckBiometrics;
      if (!isBiometricAvailable) {
        setState(() {
          _authMessage = "Fingerprint authentication is not available.";
        });
        return;
      }

      // Authenticate using fingerprint
      bool authenticated = await _localAuth.authenticate(
        localizedReason: 'Use your fingerprint to authenticate',
        options: const AuthenticationOptions(
          biometricOnly: true, // Ensure only biometrics (no PIN/password)
        ),
      );

       setState(() {
        _isAuthenticated = authenticated;
        _authMessage = authenticated
            ? "Authentication successful! Welcome."
            : "Authentication failed. Try again.";
      });

      if (authenticated) {
        // Navigate to the HomePage after successful authentication
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomePage(daysLeft: _daysLeft)), 
        );
      }
    } catch (e) {
      setState(() {
        _authMessage = "Error during authentication: $e";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Welcome'),
      ),
  body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue.shade200, Colors.blue.shade600], 
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0), // Add padding for better spacing
            child: Card(
              elevation: 10, // Elevation to give it a raised effect
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15), // Rounded corners for card
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.fingerprint,
                      size: 100, 
                      color: Colors.blue,
                    ),
                    SizedBox(height: 20),
                    Text(
                      _authMessage,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 30),
                    ElevatedButton(
                      onPressed: _authenticateWithFingerprint,
                      child: Text(
                        _isAuthenticated ? "Authenticated!" : "Authenticate",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue, 
                        foregroundColor: Colors.white,
                        minimumSize: Size(200, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30), // Rounded button
                        ),
                        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}