import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'firebase_options.dart';
import 'screens/recycler_login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const KollektApp());
}

class KollektApp extends StatelessWidget {
  const KollektApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kollekt',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.green,
        ),
        useMaterial3: true,
      ),
      home: const RecyclerLoginScreen(),
    );
  }
}