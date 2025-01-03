import 'dart:ui';
import 'package:flutter/material.dart';

class FrostedGlassCard extends StatelessWidget {
  final Widget child;
  const FrostedGlassCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: EdgeInsets.all(20),
          width: 300,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withOpacity(0.2)),
          ),
          child: child,
        ),
      ),
    );
  }
}

class AuthCard extends StatelessWidget {
  final String title;
  final String buttonLabel;
  final VoidCallback onSubmit;
  final VoidCallback onSwitch;

  const AuthCard({
    required this.title,
    required this.buttonLabel,
    required this.onSubmit,
    required this.onSwitch,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.yellow[300],
          ),
        ),
        SizedBox(height: 20),
        TextField(
          decoration: InputDecoration(
            hintText: 'Full Name',
            prefixIcon: Icon(Icons.person, color: Colors.blueAccent),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: BorderSide.none,
            ),
            filled: true,
            fillColor: Colors.white.withOpacity(0.2),
          ),
        ),
        SizedBox(height: 15),
        TextField(
          decoration: InputDecoration(
            hintText: 'Password',
            prefixIcon: Icon(Icons.lock, color: Colors.blueAccent),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: BorderSide.none,
            ),
            filled: true,
            fillColor: Colors.white.withOpacity(0.2),
          ),
          obscureText: true,
        ),
        SizedBox(height: 20),
        ElevatedButton(
          onPressed: onSubmit,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blueAccent,
            padding: EdgeInsets.symmetric(vertical: 15),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          child: Text(buttonLabel),
        ),
        SizedBox(height: 15),
        GestureDetector(
          onTap: onSwitch,
          child: Text(
            title == 'Login' ? 'Sign up' : 'Login',
            style: TextStyle(
              decoration: TextDecoration.underline,
              color: Colors.yellow[300],
            ),
          ),
        ),
      ],
    );
  }
}
