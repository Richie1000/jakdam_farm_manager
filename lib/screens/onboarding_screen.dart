import 'package:flutter/material.dart';
import 'package:jakdam_farm_manager/screens/new_login_screen.dart';
import 'package:lottie/lottie.dart'; // Import Lottie package
// Import the login screen

class OnboardingScreen extends StatefulWidget {
  @override
  _OnboardingScreenState createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  // Onboarding data now includes Lottie asset file paths
  final List<Map<String, dynamic>> _onboardingData = [
    {
      'title': 'Manage Your Fish Farm',
      'description':
          'Keep track of fish health, pond conditions, and stock levels in one place for a healthy produce.',
      'lottieFile': 'assets/animations/ab.json', // Lottie file for fish farm
    },
    {
      'title': 'Monitor Water Quality',
      'description':
          'Ensure optimal water conditions with our easy-to-use monitoring tools.',
      'lottieFile':
          'assets/animations/ac.json', // Lottie file for water quality
    },
    {
      'title': 'Enhance Customer Reach',
      'description': 'Reach More Customers than ever before!',
      'lottieFile':
          'assets/animations/selling.json', // Lottie file for productivity
    },
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _skipToLastPage() {
    _pageController.animateToPage(
      _onboardingData.length - 1,
      duration: Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
  }

  void _navigateToLogin(BuildContext context) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
          builder: (ctx) => NewLoginScreen()), // Replace with login screen
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
            itemCount: _onboardingData.length,
            itemBuilder: (context, index) {
              return OnboardingPage(
                title: _onboardingData[index]['title'],
                description: _onboardingData[index]['description'],
                lottieFile: _onboardingData[index]['lottieFile'],
              );
            },
          ),
          // Bottom navigation dots
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_onboardingData.length, (index) {
                return Container(
                  margin: EdgeInsets.symmetric(horizontal: 5),
                  width: _currentPage == index ? 12 : 8,
                  height: _currentPage == index ? 12 : 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color:
                        _currentPage == index ? Colors.blueAccent : Colors.grey,
                  ),
                );
              }),
            ),
          ),
          // Skip or Get Started button
          Positioned(
            bottom: 40,
            right: 20,
            child: ElevatedButton(
              onPressed: () {
                if (_currentPage == _onboardingData.length - 1) {
                  _navigateToLogin(context);
                } else {
                  _skipToLastPage();
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30)),
                padding: EdgeInsets.symmetric(horizontal: 25, vertical: 12),
              ),
              child: Text(
                _currentPage == _onboardingData.length - 1
                    ? 'Get Started'
                    : 'Skip',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class OnboardingPage extends StatelessWidget {
  final String title;
  final String description;
  final String lottieFile;

  const OnboardingPage({
    required this.title,
    required this.description,
    required this.lottieFile,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          // Upper part with different background color
          Container(
            width: double.infinity,
            height: MediaQuery.of(context).size.height *
                0.4, // Takes 40% of the screen height
            color: Colors.blueGrey[50], // Different background color
            child: Center(
              child: Container(
                width: 250,
                height: 250,
                child: Padding(
                  padding: const EdgeInsets.all(
                      8.0), // Optional padding inside the border
                  child: Lottie.asset(lottieFile), // Lottie animation
                ),
              ),
            ),
          ),
          SizedBox(height: 40),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: 20),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey[700],
                  ),
                ),
              ],
            ),
          ),
          Spacer(),
        ],
      ),
    );
  }
}
