import 'package:flutter/material.dart';
import 'package:individual1/authentication/register.dart';
import 'package:local_auth/local_auth.dart';

class FingerprintLoginScreen extends StatefulWidget {
  @override
  _FingerprintLoginScreenState createState() => _FingerprintLoginScreenState();
}

class _FingerprintLoginScreenState extends State<FingerprintLoginScreen> {
  final LocalAuthentication _localAuthentication = LocalAuthentication();
  String _authorized = "Not Authorized";

  /// Check if device supports biometrics
  Future<bool> _checkBiometricAvailability() async {
    bool canAuthenticate = false;
    try {
      canAuthenticate = await _localAuthentication.canCheckBiometrics;
    } catch (e) {
      print("Error checking biometrics: $e");
    }
    return canAuthenticate;
  }

  /// Authenticate using biometrics
  Future<void> _authenticate() async {
    bool isAuthenticated = false;
    try {
      isAuthenticated = await _localAuthentication.authenticate(
        localizedReason: "Authenticate to access the app",
        options: const AuthenticationOptions(
          biometricOnly: true,
        ),
      );
    } catch (e) {
      print("Error authenticating: $e");
    }

    setState(() {
      _authorized = isAuthenticated ? "Authorized" : "Not Authorized";
    });

    if (isAuthenticated) {
      // Navigate to the home screen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => RegisterPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Fingerprint Login"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Status: $_authorized",
              style: const TextStyle(fontSize: 20),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                bool canAuthenticate = await _checkBiometricAvailability();
                if (canAuthenticate) {
                  _authenticate();
                } else {
                  setState(() {
                    _authorized = "Biometric authentication not available.";
                  });
                }
              },
              child: const Text("Login with Fingerprint"),
            ),
          ],
        ),
      ),
    );
  }
}

