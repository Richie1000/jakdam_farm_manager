import 'package:flutter/material.dart';

class AuthScreen extends StatelessWidget {
  static const routeName = '/auth';

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;
    return Scaffold(
      body: Stack(
        children: <Widget>[
          // Background Image
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/jakdam.jpg'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          SingleChildScrollView(
            child: Container(
              height: deviceSize.height,
              width: deviceSize.width,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  // Sign-in card
                  Flexible(
                    child: Container(
                      margin: EdgeInsets.only(bottom: 30.0),
                      padding:
                          EdgeInsets.symmetric(vertical: 8.0, horizontal: 50.0),
                      child: Text(
                        'The best app for your plants',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  AuthCard(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class AuthCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 20),
      elevation: 8.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            // Full Name Field
            TextFormField(
              decoration: InputDecoration(
                labelText: 'Full Name',
                labelStyle: TextStyle(color: Colors.green),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: Icon(Icons.person, color: Colors.green),
              ),
            ),
            SizedBox(height: 10),
            // Email Field
            TextFormField(
              decoration: InputDecoration(
                labelText: 'Email Address',
                labelStyle: TextStyle(color: Colors.green),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: Icon(Icons.email, color: Colors.green),
              ),
            ),
            SizedBox(height: 10),
            // Password Field
            TextFormField(
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Password',
                labelStyle: TextStyle(color: Colors.green),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: Icon(Icons.lock, color: Colors.green),
              ),
            ),
            SizedBox(height: 20),
            // Login Button
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: EdgeInsets.symmetric(vertical: 12, horizontal: 20),
              ),
              onPressed: () {},
              child: Text(
                'Login',
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
            ),
            // Optional: Social Media Sign-in
            SizedBox(height: 10),
            Text('Or continue with'),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // IconButton(
                //   icon: Image.asset('assets/icons/google_icon.png'), // Add your Google icon
                //   onPressed: () {},
                // ),
                // IconButton(
                //   icon: Image.asset('assets/icons/facebook_icon.png'), // Add your Facebook icon
                //   onPressed: () {},
                // ),
                // IconButton(
                //   icon: Image.asset('assets/icons/apple_icon.png'), // Add your Apple icon
                //   onPressed: () {},
                // ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
