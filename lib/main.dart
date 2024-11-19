import 'package:flutter/material.dart';
import 'package:justhome/SplashscreenWidget.dart';
import 'package:firebase_core/firebase_core.dart';
// import 'package:justhome/additem.dart';
// import 'package:justhome/homepage.dart';
// import 'package:justhome/loginform.dart';
// import 'package:justhome/register.dart';
// import 'package:justhome/register1.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding
      .ensureInitialized(); // Ensure Flutter bindings are initialized
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    // Handle initialization error
    print("Firebase initialization error: $e");
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: SplashscreenWidget(),
    );
  }
}
