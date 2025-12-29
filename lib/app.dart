import 'package:flutter/material.dart';


import 'package:stockex/screen/splash_screen.dart';
import 'package:stockex/theme/theme_data.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Apps for College',
      debugShowCheckedModeBanner: false,
      theme: getAppThemeData(),
      home: const SplashScreen(),
    );
  }
}
