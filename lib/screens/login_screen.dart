import 'package:flutter/material.dart';
import '../widgets/frosted_glass_card.dart';

class LoginScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Image
          Positioned.fill(
            child: Image.asset(
              'assets/images/jakdam.jpg', // Path to the logo image
              fit: BoxFit.cover,
              color: Colors.black.withOpacity(0.3),
              colorBlendMode: BlendMode.darken,
            ),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
              
                SizedBox(height: 30),
                // Frosted Glass Login Card
                FrostedGlassCard(
                  child: AuthCard(
                    title: 'Login',
                    buttonLabel: 'Sign In',
                    onSubmit: () {
                      // Handle login logic
                    },
                    onSwitch: () {
                      Navigator.pushNamed(context, '/register');
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
