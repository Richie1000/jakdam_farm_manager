import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../providers/auth.dart' as customAuth;
import 'feed_calculation_screen.dart';
import 'feed_formulae_screen.dart';
import 'inventory_screen.dart';
import 'pond_calculation_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  String _username = '';
  String _initials = '';

  @override
  void initState() {
    super.initState();
    _fetchUsernameAndInitials();
  }

  Future<void> _fetchUsernameAndInitials() async {
    // Use the custom AuthProvider with prefix
    final user = Provider.of<customAuth.AuthProvider>(context, listen: false).user;

    if (user != null) {
      // Fetch user data from Firestore
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (userDoc.exists) {
        final fullName = userDoc['username'] as String;

        // Split the name and get initials
        List<String> names = fullName.trim().split(' ');

        setState(() {
          _username = names[0]; // Set first name for greeting
          if (names.length > 1) {
            _initials = names[0][0].toUpperCase() + names[1][0].toUpperCase();
          } else {
            _initials = names[0].substring(0, 2).toUpperCase();
          }
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          // Header Container
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
              borderRadius: const BorderRadius.only(
                bottomRight: Radius.circular(50),
              ),
            ),
            child: Column(
              children: [
                const SizedBox(height: 50),
                ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 30),
                  title: Text(
                    'Hello $_username!',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: Colors.white,
                        ),
                  ),
                  subtitle: Text(
                    'Good Morning',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Colors.white54,
                        ),
                  ),
                  trailing: CircleAvatar(
                    radius: 30,
                    backgroundColor: Theme.of(context).primaryColorLight,
                    child: Text(
                      _initials,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
          // Dashboard Items Container
          Container(
            color: Theme.of(context).primaryColor,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(topLeft: Radius.circular(200)),
              ),
              child: GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 40,
                mainAxisSpacing: 30,
                children: [
                  itemDashboard('Pond Calculations', 'assets/animations/pond.json', context, () { 
                    Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>  PondCalculationsScreen()),
                  );
                   }),
                  itemDashboard('Feed Calculations', 'assets/animations/feed.json', context, () { 
                    Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const FeedCalculationScreen()),
                  );
                   }),
                  itemDashboard('Inventory', 'assets/animations/stock.json', context, () { 
                    Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) =>  InventoryScreen()),
                  );
                   }),
                  itemDashboard('Feed Formulae', 'assets/animations/group.json', context, () { 
                    Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const FeedFormulaeScreen()),
                  );
                   }),
                  itemDashboard('Request Training', 'assets/animations/training.json', context, () async { 
                    final Uri url = Uri.parse('https://jakdamfarmlife.com');
                    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
                      throw 'Could not launch $url';
                    }
                   }),
                  itemDashboard('Logout', 'assets/animations/logout.json', context, () {  
                    final authProvider = Provider.of<customAuth.AuthProvider>(context, listen: false);
                    authProvider.signOut();
                  }),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // Function to create dashboard items with onTap handling
  Widget itemDashboard(String title, String lottieFile, BuildContext context, VoidCallback onTap) => GestureDetector(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                offset: const Offset(0, 5),
                color: Theme.of(context).primaryColor.withOpacity(.2),
                spreadRadius: 2,
                blurRadius: 5,
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                height: 100,
                width: 100,
                child: Lottie.asset(lottieFile), // Display the Lottie animation
              ),
              const SizedBox(height: 8),
              Text(
                title.toUpperCase(),
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ],
          ),
        ),
      );
}
