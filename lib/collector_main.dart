import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'firebase_options.dart';
import 'screens/collector/auth/collector_login_screen.dart';

import 'screens/collector/localization/collector_localization.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    CollectorLanguageScope(
      child: CollectorApp(),
    ),
  );
}

class CollectorApp extends StatelessWidget {
  const CollectorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Kollekt Collector',
      home: const CollectorLoginScreen(),
    );
  }
}