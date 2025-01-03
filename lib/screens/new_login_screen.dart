import 'dart:async';

import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:jakdam_farm_manager/screens/dashboard.dart';
import 'package:jakdam_farm_manager/screens/register_screen.dart';
import 'package:fluttertoast/fluttertoast.dart'; // Import the fluttertoast package
import '../models/exception_handler.dart';

class NewLoginScreen extends StatefulWidget {
  const NewLoginScreen({super.key});

  @override
  State<NewLoginScreen> createState() => _NewLoginScreenState();
}

class _NewLoginScreenState extends State<NewLoginScreen> {
  int activeIndex = 0;
  bool _isLoading = false; // To show loading indicator
  String _email = '';
  String _password = '';

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

  // Function to show alert dialog with error message
  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Login Failed'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> _login() async {
    if (_email.isEmpty || _password.isEmpty) {
      // Show toast if fields are empty
      Fluttertoast.showToast(
        msg: "Please enter both email and password",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        //backgroundColor: Colors.red,
        //textColor: Colors.white,
        fontSize: 16.0,
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _email,
        password: _password,
      );
      Navigator.of(context).push(
        MaterialPageRoute(builder: (context) => DashboardScreen()),
      );
    } on FirebaseAuthException catch (e) {
      final errorMessage = FirebaseAuthErrorHandler.getErrorMessage(
          e.code); // Use custom error handler
      _showErrorDialog(errorMessage);
    } catch (e) {
      _showErrorDialog('An unexpected error occurred. Please try again.');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
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
                            child: Image.asset(
                              e.value,
                              height: 400,
                            ),
                          ),
                        );
                      }).toList(),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 40),
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
                    prefixIcon: const Icon(
                      Icons.person,
                      color: Colors.black,
                      size: 18,
                    ),
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
                    setState(() {
                      _email = value;
                    });
                  },
                ),
              ),
              const SizedBox(height: 20),
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
                    prefixIcon: const Icon(
                      Icons.lock,
                      color: Colors.black,
                      size: 18,
                    ),
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
                    setState(() {
                      _password = value;
                    });
                  },
                ),
              ),
              FadeInUp(
                duration: const Duration(milliseconds: 1300),
                delay: const Duration(milliseconds: 800),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () {},
                      child: const Text(
                        "Forgot Password",
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 14,
                            fontWeight: FontWeight.w400),
                      ),
                    )
                  ],
                ),
              ),
              const SizedBox(height: 30),
              _isLoading
                  ? const CircularProgressIndicator() // Show loading indicator
                  : FadeInUp(
                      child: MaterialButton(
                        onPressed: _login,
                        height: 45,
                        padding: const EdgeInsets.symmetric(
                            vertical: 10, horizontal: 50),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                        color: Colors.black,
                        child: const Text(
                          "Login",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
              const SizedBox(height: 40),
              FadeInUp(
                delay: const Duration(milliseconds: 800),
                duration: const Duration(milliseconds: 1600),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Don\'t have an account?  ",
                      style:
                          TextStyle(color: Colors.grey.shade600, fontSize: 12),
                    ),
                    TextButton(
                      child: const Text("Register!",
                          style: TextStyle(fontSize: 14, color: Colors.blue)),
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                              builder: (BuildContext) => RegisterScreen()),
                        );
                      },
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
