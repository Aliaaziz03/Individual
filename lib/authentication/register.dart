import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:individual1/authentication/login.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  String? errorMessage = '';
  bool isLogin = true;

  final TextEditingController _controllerEmail = TextEditingController();
  final TextEditingController _controllerUsername = TextEditingController();
  final TextEditingController _controllerPassword = TextEditingController();
  final TextEditingController _controllerConfirmPassword = TextEditingController();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

Future<void> createUserWithEmailAndPassword() async {
  String email = _controllerEmail.text.trim();
  String username = _controllerUsername.text.trim();
  String password = _controllerPassword.text.trim();
  String confirmPassword = _controllerConfirmPassword.text.trim();

  if (password != confirmPassword) {
    setState(() {
      errorMessage = "Passwords do not match.";
    });
    return;
  }

  try {
    // Firebase Authentication
    UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    if (userCredential.user != null) {
      print("User registered successfully. UID: ${userCredential.user!.uid}");
      
      // Store additional user data in Firestore
      await _firestore.collection("users").doc(userCredential.user!.uid).set({
        "username": username,
      });

      print("Firestore data written successfully.");

      // Navigate to Login Page
      setState(() {
        errorMessage = null; // Clear any error messages
      });
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
      );
    } else {
      print("Error: UserCredential.user is null.");
      setState(() {
        errorMessage = "Unexpected error occurred.";
      });
    }
  } on FirebaseAuthException catch (e) {
    print("FirebaseAuthException: ${e.message}");
    setState(() {
      errorMessage = e.message ?? "An unknown error occurred.";
    });
  } catch (e) {
    print("General Exception: $e");
    setState(() {
      errorMessage = e.toString();
    });
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios,color: Colors.black),
           onPressed: () {
            Navigator.push(context, 
             MaterialPageRoute(builder: (context) => LoginPage())); // Navigate to the previous screen
           },
        ),
      ),
      body: SafeArea(
        child: Stack(
          children: [
            
            Container(
              width: double.infinity,
              height: double.infinity,
              color: Colors.white, // Background color
            ),

            Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 400, // Adjust this height as per your need
              decoration: const BoxDecoration(
                color: Colors.grey,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),))),

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
                      'Sign Up',
                      style: GoogleFonts.patrickHand(
                        fontSize: 40,
                        color: const Color.fromARGB(255, 81, 58, 145),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Form(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 50, horizontal: 20),
                        child: Column(
                          children: [
                              TextFormField(
                              controller: _controllerEmail,
                              keyboardType: TextInputType.emailAddress,
                              style: GoogleFonts.patrickHand(),
                              decoration: InputDecoration(
                                labelText: 'Email',
                                labelStyle: GoogleFonts.patrickHand(),
                                hintText: 'Enter Email',
                                hintStyle: GoogleFonts.patrickHand(),
                                prefixIcon: const Icon(Icons.badge),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(30.0),
                                ),
                              ),
                              validator: (value) {
                                return value!.isEmpty ? 'Please enter email' : null;
                              },
                            ),

                            const SizedBox(height: 20),
                            TextFormField(
                              controller: _controllerUsername,
                              keyboardType: TextInputType.text,
                              style: GoogleFonts.patrickHand(),
                              decoration: InputDecoration(
                                labelText: 'Username',
                                labelStyle: GoogleFonts.patrickHand(),
                                hintText: 'Enter username',
                                hintStyle: GoogleFonts.patrickHand(),
                                prefixIcon: const Icon(Icons.person),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(30.0),
                                ),
                              ),
                              validator: (value) {
                                return value!.isEmpty ? 'Please enter username' : null;
                              },
                            ),

                            const SizedBox(height: 20),
                            TextFormField(
                              controller: _controllerPassword,
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
                              validator: (value) {
                                return value!.isEmpty ? 'Please enter password' : null;
                              },
                            ),

                            const SizedBox(height: 20),
                            TextFormField(
                              controller: _controllerConfirmPassword,
                              keyboardType: TextInputType.visiblePassword,
                              obscureText: true,
                              style: GoogleFonts.patrickHand(),
                              decoration: InputDecoration(
                                labelText: 'Confirm Password',
                                labelStyle: GoogleFonts.patrickHand(),
                                hintText: 'Confirm password',
                                hintStyle: GoogleFonts.patrickHand(),
                                prefixIcon: const Icon(Icons.lock_outline),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(30.0),
                                ),
                              ),
                              validator: (value) {
                                return value!.isEmpty ? 'Please confirm password' : null;
                              },
                            ),
                            const SizedBox(height: 20),
                            if (errorMessage != null && errorMessage!.isNotEmpty)
                              Text(
                                errorMessage!,
                                style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                              ),
                            const SizedBox(height: 20),
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                              child: Container(
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [Colors.deepPurple, Colors.purpleAccent],
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
                                  onPressed: () async {
                                    
                                    if (_controllerEmail.text.isEmpty ) {
                                      setState(() => errorMessage = "Please enter a valid student ID.");
                                      return;
                                      }
                                    
                                    else
                                     {createUserWithEmailAndPassword();}
                                  },
                                  textColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 15),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                  child: const Text(
                                    'Sign Up',
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
          ],
        ),
      ),
    );
  }
}
