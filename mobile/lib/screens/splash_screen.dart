import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'home_screen.dart';
import 'welcome_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  double progress = 0;

  @override
  void initState() {
    super.initState();
    startLoading();
  }

  Future<void> startLoading() async {
    await Future.delayed(const Duration(milliseconds: 500));

    setState(() {
      progress = 0.33;
    });

    await Future.delayed(const Duration(seconds: 1));

    setState(() {
      progress = 0.66;
    });

    await Future.delayed(const Duration(seconds: 1));

    setState(() {
      progress = 1;
    });

    final prefs = await SharedPreferences.getInstance();

    final token = prefs.getString("token");

    if (!mounted) return;

    if (token != null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const WelcomeScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(30),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "Basketball App",
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 40),

              LinearProgressIndicator(value: progress),
            ],
          ),
        ),
      ),
    );
  }
}
