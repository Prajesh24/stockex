import 'package:flutter/material.dart';
import 'package:stockex/screen/login_screen.dart';
import 'package:stockex/screen/onboard_screen.dart';
import 'package:stockex/screen/register_screen.dart';

import 'package:stockex/screen/splash_screen.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Apps for College',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const SplashScreen(),
    );
  }
}
