import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:individual1/AppsFlow/homepage.dart';
import 'package:individual1/AppsFlow/profile.dart';
import 'package:individual1/authentication/register.dart';
import 'auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:individual1/authentication/fingerprint.dart';
import 'package:individual1/AppsFlow/Calendar.dart';



class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  String? errorMessage = '';
  bool isLogin = true;

  final TextEditingController _controllerEmail = TextEditingController();
  final TextEditingController _controllerPassword = TextEditingController();

  Future<void> signInWithEmailAndPassword() async {
  if (_controllerEmail.text.isEmpty || !_controllerEmail.text.contains('@')) {
    setState(() {
      errorMessage = "Please enter a valid email.";
    });
    return;
  }

  if (_controllerPassword.text.isEmpty ||_controllerPassword.text.length < 6) {
    setState(() {
      errorMessage = "Password must be at least 6 characters.";
    });
    return;
  }

  try {
      await Auth().signInWithEmailAndPassword(
        email: _controllerEmail.text, 
        password: _controllerPassword.text
      );
      Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) =>  HomePage()),
    );
    } on FirebaseAuthException catch (e) {
      
      if (e.code == 'user-not-found') {
      setState(() {
        errorMessage = "No user found for this email. Please register first.";
      });
    } else if (e.code == 'wrong-password') {
      setState(() {
        errorMessage = "Incorrect password. Please try again.";
      });
    } else {
      setState(() {
        errorMessage = e.message ?? "An unknown error occurred.";
      });
    };

    } catch (e) {
    setState(() {
      errorMessage = "An unexpected error occurred. Please try again.";
    });
  }

  }


  @override
Widget build(BuildContext context) {
    return Scaffold(
 body: SafeArea(
        child: Stack(
          children: [
            Container(
              width: double.infinity,
              height: double.infinity,
              color: Colors.pink.withOpacity(0.3), // Background color
            ),
            Center(
              child: Container(
                width: MediaQuery.of(context).size.width * 0.7, // Adjust width
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 10,
                      offset: Offset(0, 5),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(30),
                child: Column(
                  mainAxisSize: MainAxisSize.min, // Shrinks to fit content
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                Text(
                  'LOGIN',
                  style: GoogleFonts.patrickHand(
                    fontSize: 40,
                    color: Colors.pink,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                
                Form(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 50, horizontal: 20),
                    child: Column(
                      children: [
                        TextFormField(
                          controller: _controllerEmail, //create field
                          keyboardType: TextInputType.emailAddress,
                          
                          style: GoogleFonts.patrickHand(),
                          decoration: InputDecoration(
                            labelText: 'Email',
                            labelStyle: GoogleFonts.patrickHand(),
                            hintText: 'Enter email',
                            hintStyle: GoogleFonts.patrickHand(),
                            prefixIcon: const Icon(Icons.email),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30.0),
                            ),
                          ),
                          onChanged: (String value) {},
                          validator: (value) {
                            return value!.isEmpty ? 'Please enter email' : null;
                          },
                        ),
                        const SizedBox(height: 20),
                        TextFormField(
                          controller: _controllerPassword, //create field
                          keyboardType: TextInputType.visiblePassword,
                          obscureText: true,
                          style: GoogleFonts.patrickHand(),
                          decoration: InputDecoration(
                            labelText: 'Password',
                            labelStyle: GoogleFonts.patrickHand(),
                            hintText: 'Enter password',
                            hintStyle: GoogleFonts.patrickHand(),
                            prefixIcon: const Icon(Icons.lock),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30.0),
                            ),
                          ),
                          onChanged: (String value) {},
                          validator: (value) {
                            return value!.isEmpty ? 'Please enter password' : null;
                          },
                        ),
                        const SizedBox(height: 20),
                         if (errorMessage != null && errorMessage!.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 10),
                                child: Text(
                                  errorMessage!,
                                  style: const TextStyle(color: Colors.red, fontSize: 14),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color.fromARGB(255, 175, 69, 105), Color.fromARGB(255, 228, 157, 181)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(30),
                              boxShadow: const [
                                BoxShadow(
                                  color: Colors.black26,
                                  blurRadius: 10,
                                  offset: Offset(0, 5),
                                ),
                              ],
                            ),
                            child: MaterialButton(
                              minWidth: double.infinity,
                              onPressed: () {
                                signInWithEmailAndPassword();
                                
                              },
                              textColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 15),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                              child: const Text(
                                'Login',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    ),
                ),
              ],
            ),
          ),
            ),
          ]
      ),
    ));
}
}