import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:jakdam_farm_manager/screens/dashboard.dart';
import 'package:jakdam_farm_manager/screens/new_login_screen.dart';

class RegisterScreen extends StatefulWidget {
  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  int activeIndex = 0;
  String _email = '';
  String _password = '';
  String _confirmPassword = '';
  String _username = '';
  bool _isLoading = false; // Show loading indicator

  final List<String> _images = [
    'assets/images/typography-illustration-featuring-a-fish-farm-full-of-freshwater-fish-JJA207.jpg',
    'assets/images/download.png',
    'assets/images/images.jpeg'
  ];

  @override
  void initState() {
    super.initState();
    startTimer();
  }

  startTimer() {
    Timer.periodic(const Duration(seconds: 5), (timer) {
      setState(() {
        activeIndex++;
        if (activeIndex == 3) {
          activeIndex = 0;
        }
      });
    });
  }

  Future<void> _register() async {
    if (_password != _confirmPassword) {
      _showErrorDialog('Passwords do not match');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Register user
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: _email, password: _password);

      // Save user info to Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userCredential.user?.uid)
          .set({
        'email': _email,
        'username': _username,
      });

      // Navigate to the login screen or dashboard
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => DashboardScreen()),
      );
    } on FirebaseAuthException catch (e) {
      _showErrorDialog(e.message ?? 'An error occurred during registration');
    } catch (e) {
      _showErrorDialog('An unexpected error occurred. Please try again.');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            child: const Text('OK'),
            onPressed: () {
              Navigator.of(ctx).pop();
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const SizedBox(height: 50),
              FadeInUp(
                child: Container(
                  height: 350,
                  child: Stack(
                    children: [
                      ..._images.asMap().entries.map((e) {
                        return Positioned(
                          top: 0,
                          bottom: 0,
                          right: 0,
                          left: 0,
                          child: AnimatedOpacity(
                            opacity: activeIndex == e.key ? 1 : 0,
                            duration: const Duration(seconds: 1),
                            child: Image.asset(e.value, height: 400),
                          ),
                        );
                      }).toList(),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              FadeInUp(
                delay: const Duration(milliseconds: 800),
                duration: const Duration(milliseconds: 1500),
                child: TextField(
                  cursorColor: Colors.black,
                  decoration: InputDecoration(
                    labelText: "Username",
                    hintText: "Username",
                    labelStyle: const TextStyle(
                      color: Colors.black,
                      fontSize: 14,
                      fontWeight: FontWeight.w300,
                    ),
                    prefixIcon:
                        const Icon(Icons.person, color: Colors.black, size: 18),
                    enabledBorder: OutlineInputBorder(
                      borderSide:
                          BorderSide(color: Colors.grey.shade200, width: 2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    floatingLabelStyle:
                        const TextStyle(color: Colors.black, fontSize: 18),
                    focusedBorder: OutlineInputBorder(
                      borderSide:
                          const BorderSide(color: Colors.black, width: 1.5),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onChanged: (value) {
                    _username = value;
                  },
                ),
              ),
              const SizedBox(height: 10),
              FadeInUp(
                delay: const Duration(milliseconds: 800),
                duration: const Duration(milliseconds: 1500),
                child: TextField(
                  cursorColor: Colors.black,
                  decoration: InputDecoration(
                    labelText: "Email",
                    hintText: "Email",
                    labelStyle: const TextStyle(
                      color: Colors.black,
                      fontSize: 14,
                      fontWeight: FontWeight.w300,
                    ),
                    prefixIcon:
                        const Icon(Icons.email, color: Colors.black, size: 18),
                    enabledBorder: OutlineInputBorder(
                      borderSide:
                          BorderSide(color: Colors.grey.shade200, width: 2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    floatingLabelStyle:
                        const TextStyle(color: Colors.black, fontSize: 18),
                    focusedBorder: OutlineInputBorder(
                      borderSide:
                          const BorderSide(color: Colors.black, width: 1.5),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onChanged: (value) {
                    _email = value;
                  },
                ),
              ),
              const SizedBox(height: 10),
              FadeInUp(
                delay: const Duration(milliseconds: 800),
                duration: const Duration(milliseconds: 1500),
                child: TextField(
                  cursorColor: Colors.black,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: "Password",
                    hintText: "Password",
                    labelStyle: const TextStyle(
                      color: Colors.black,
                      fontSize: 14,
                      fontWeight: FontWeight.w300,
                    ),
                    prefixIcon:
                        const Icon(Icons.lock, color: Colors.black, size: 18),
                    enabledBorder: OutlineInputBorder(
                      borderSide:
                          BorderSide(color: Colors.grey.shade200, width: 2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    floatingLabelStyle:
                        const TextStyle(color: Colors.black, fontSize: 18),
                    focusedBorder: OutlineInputBorder(
                      borderSide:
                          const BorderSide(color: Colors.black, width: 1.5),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onChanged: (value) {
                    _password = value;
                  },
                ),
              ),
              const SizedBox(height: 10),
              FadeInUp(
                delay: const Duration(milliseconds: 800),
                duration: const Duration(milliseconds: 1500),
                child: TextField(
                  cursorColor: Colors.black,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: "Confirm Password",
                    hintText: "Confirm Password",
                    labelStyle: const TextStyle(
                      color: Colors.black,
                      fontSize: 14,
                      fontWeight: FontWeight.w300,
                    ),
                    prefixIcon:
                        const Icon(Icons.lock, color: Colors.black, size: 18),
                    enabledBorder: OutlineInputBorder(
                      borderSide:
                          BorderSide(color: Colors.grey.shade200, width: 2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    floatingLabelStyle:
                        const TextStyle(color: Colors.black, fontSize: 18),
                    focusedBorder: OutlineInputBorder(
                      borderSide:
                          const BorderSide(color: Colors.black, width: 1.5),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onChanged: (value) {
                    _confirmPassword = value;
                  },
                ),
              ),
              const SizedBox(height: 20),
              _isLoading
                  ? const CircularProgressIndicator()
                  : FadeInUp(
                      child: MaterialButton(
                        onPressed: _register,
                        height: 45,
                        padding: const EdgeInsets.symmetric(
                            vertical: 10, horizontal: 50),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                        color: Colors.black,
                        child: const Text(
                          "Register",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
              const SizedBox(height: 10),
              FadeInUp(
                delay: const Duration(milliseconds: 800),
                duration: const Duration(milliseconds: 1600),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Already a User?  ",
                      style:
                          TextStyle(color: Colors.grey.shade600, fontSize: 12),
                    ),
                    TextButton(
                      child: const Text("Sign in!",
                          style: TextStyle(fontSize: 14, color: Colors.blue)),
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                              builder: (BuildContext) => NewLoginScreen()),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
