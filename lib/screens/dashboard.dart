import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:jakdam_farm_manager/screens/feed_calculation_screen.dart';
import 'package:jakdam_farm_manager/screens/feed_formulae_screen.dart';
import 'package:jakdam_farm_manager/screens/onboarding_screen.dart';
import 'package:jakdam_farm_manager/screens/select_farm_screen.dart';
import 'package:jakdam_farm_manager/screens/stock_rate_screen.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../providers/auth.dart' as customAuth;

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
    setState(() {
      _username = "User";
      _initials = "US";
    });
  }

  Future<void> openWhatsAppChat({String? message}) async {
    final encodedMessage = Uri.encodeComponent(message ?? '');
    final whatsappUrl = 'https://wa.me/+233248570441?text=$encodedMessage';

    if (await canLaunchUrl(Uri.parse(whatsappUrl))) {
      await launchUrl(Uri.parse(whatsappUrl),
          mode: LaunchMode.externalApplication);
    } else {
      throw 'Could not launch WhatsApp chat';
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<VoidCallback> actions = [
      () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => StockRateScreen()),
        );
      },
      () {
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => const FeedCalculationScreen()),
        );
      },
      () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const SelectFarmScreen()),
        );
      },
      () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const FeedFormulaeScreen()),
        );
      },
      () async {
        final Uri url = Uri.parse('https://jakdamfarmlife.com');
        if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
          throw 'Could not launch $url';
        }
      },
      () async {
        openWhatsAppChat();
      },
      () async {
        print("Logging out...");
        final authProvider =
            Provider.of<customAuth.AuthProvider>(context, listen: false);
        await authProvider.signOut();

        if (authProvider.user == null) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => OnboardingScreen()),
          );
        }
      },
    ];
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
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
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: MediaQuery.of(context).size.width * 0.08,
                    ),
                    title: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Hello $_username!',
                        style:
                            Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  color: Colors.white,
                                ),
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
            Container(
              color: Theme.of(context).primaryColor,
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: MediaQuery.of(context).size.width * 0.08,
                ),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius:
                      BorderRadius.only(topLeft: Radius.circular(200)),
                ),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    int crossAxisCount = constraints.maxWidth > 600 ? 3 : 2;
                    double aspectRatio = constraints.maxWidth > 600 ? 1.2 : 0.8;
                    return GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: crossAxisCount,
                        crossAxisSpacing: 20,
                        mainAxisSpacing: 20,
                        childAspectRatio: aspectRatio,
                      ),
                      itemCount: 7,
                      itemBuilder: (context, index) {
                        return itemDashboard(
                          titles[index],
                          lottieFiles[index],
                          context,
                          actions[index],
                        );
                      },
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  final List<String> titles = [
    'Pond Calculations',
    'Feed Calculations',
    'Inventory',
    'Feed Formulae',
    'Request Training',
    'Contact us',
    'Logout'
  ];

  final List<String> lottieFiles = [
    'assets/animations/pond.json',
    'assets/animations/ab.json',
    'assets/animations/stock.json',
    'assets/animations/cooking.json',
    'assets/animations/training.json',
    'assets/animations/contact_us.json',
    'assets/animations/logout.json',
  ];

  Widget itemDashboard(String title, String lottieFile, BuildContext context,
          VoidCallback onTap) =>
      GestureDetector(
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
              Flexible(
                flex: 2,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Lottie.asset(
                    lottieFile,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              Flexible(
                flex: 1,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Text(
                    title.toUpperCase(),
                    style: Theme.of(context).textTheme.titleMedium,
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
}
