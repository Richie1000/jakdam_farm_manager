import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:jakdam_farm_manager/providers/farm_id.dart';
import 'package:jakdam_farm_manager/providers/inventory_provider.dart';
import 'package:jakdam_farm_manager/screens/onboarding_screen.dart';
import 'package:provider/provider.dart';

import './providers/auth.dart';
import 'screens/dashboard.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp();
  } catch (e) {
    print('Firebase initialization error: $e');
  }
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => AuthProvider()),
        ChangeNotifierProvider(create: (context) => InventoryProvider()),
        ChangeNotifierProvider(create: (context) => FarmIDProvider())
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Jakdam Farm Manager',
        //theme: ThemeData.dark(),
        home: Consumer<AuthProvider>(
          builder: (context, auth, _) {
            //print("current user is ${auth.user}");
            if (auth.user != null) {
              return DashboardScreen();
            } else {
              return OnboardingScreen();
            }
          },
        ),
      ),
    );
  }
}
