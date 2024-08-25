import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../providers/auth.dart';
import './feed_calculation_screen.dart';
import './pond_calculation_screen.dart';
import './feed_formulae_screen.dart';
import './inventory_screen.dart';

class DashboardScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Jakdam'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(2),
        child: GridView.count(
          crossAxisCount: 2,
          //crossAxisSpacing: 5,
          mainAxisSpacing: 5,
          children: [
            DashboardCard(
              title: ' Pond  Calculations',
              lottieAsset: 'assets/animations/pond.json',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => PondCalculationsScreen()),
                );
              },
            ),
            DashboardCard(
              title: ' Feed  Calculations',
              lottieAsset: 'assets/animations/feed.json',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => FeedCalculationScreen()),
                );
              },
            ),
            DashboardCard(
              title: 'Inventory',
              lottieAsset: 'assets/animations/stock.json',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => InventoryScreen()),
                );
              },
            ),
            DashboardCard(
              title: 'Feed Formulae',
              lottieAsset: 'assets/animations/group.json',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => FeedFormulaeScreen()),
                );
              },
            ),
            DashboardCard(
              title: 'Request Training',
              lottieAsset: 'assets/animations/training.json',
              onTap: () async {
              final Uri url = Uri.parse('https://jakdamfarmlife.com');
              if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
                throw 'Could not launch $url';
              }
            },
            ),
            DashboardCard(
              title: 'Logout',
              lottieAsset: 'assets/animations/logout.json',
              onTap: () {
                // Handle logout action
                final authProvider =
                    Provider.of<AuthProvider>(context, listen: false);
                authProvider.signOut();
              },
            ),
          ],
        ),
      ),
    );
  }
}

class DashboardCard extends StatelessWidget {
  final String title;
  final String lottieAsset;
  final VoidCallback onTap;

  DashboardCard(
      {required this.title, required this.lottieAsset, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 4.0,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Lottie.asset(
              lottieAsset,
              width: 100,
              height: 100,
            ),
            SizedBox(height: 10),
            Text(
              title,
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}

Widget _buildManagementToolCard(
    {required IconData icon,
    required String title,
    required VoidCallback onTap}) {
  return Card(
    elevation: 4,
    child: ListTile(
      leading: Icon(icon, size: 36, color: Colors.blueAccent),
      title: Text(
        title,
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
      ),
      trailing: Icon(Icons.arrow_forward_ios),
      onTap: onTap,
    ),
  );
}
