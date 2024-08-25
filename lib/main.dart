import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:jakdam_farm_manager/providers/inventory_provider.dart';
import 'package:jakdam_farm_manager/utils/theme_data.dart';
import 'package:provider/provider.dart';

import './providers/auth.dart';
import './screens/auth_screen.dart';
import 'screens/dashboard.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => AuthProvider()),
        ChangeNotifierProvider(create: (context) => InventoryProvider())
      ],
      child: MaterialApp(
        title: 'Jakdam Farm Manager',
        theme: buildThemeData(),
        home: Consumer<AuthProvider>(
          builder: (context, auth, _) {
            if (auth.user != null) {
              return DashboardScreen();
            } else {
              return AuthScreen();
            }
          },
        ),
        
      ),
    );
  }
}
