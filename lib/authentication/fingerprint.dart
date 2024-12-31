import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';

class FingerprintAuthPage extends StatefulWidget {
  @override
  _FingerprintAuthPageState createState() => _FingerprintAuthPageState();
}

class _FingerprintAuthPageState extends State<FingerprintAuthPage> {
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
        title: Text('Fingerprint Authentication'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _authMessage,
              style: TextStyle(fontSize: 18),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _authenticateWithFingerprint,
              child: Text(
                _isAuthenticated ? "Authenticated!" : "Authenticate",
                style: TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
