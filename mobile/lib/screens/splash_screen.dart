import 'dart:async';
import 'package:flutter/material.dart';

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

  void startLoading() async {
    await Future.delayed(const Duration(milliseconds: 500));

    setState(() {
      progress = 0.33;
    });

    await Future.delayed(const Duration(seconds: 1));

    setState(() {
      progress = 0.99;
    });

    await Future.delayed(const Duration(seconds: 1));

    setState(() {
      progress = 1;
    });
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
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 40),

              LinearProgressIndicator(
                value: progress,
              ),
            ],
          ),
        ),
      ),
    );
  }
}