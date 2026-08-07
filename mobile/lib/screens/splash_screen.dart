import 'dart:async';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mobile/screens/main_navigation_screen.dart';

import '../services/session.dart';
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

  /// Provjerava postoji li spremljeni token i je li jos uvijek valjan.
  /// Bez valjane sesije korisnik ide na welcome ekran.
  Future<bool> hasValidSession() async {
    final token = await Session.token();

    if (token == null || token.isEmpty) return false;

    try {
      final response = await http.get(
        Uri.parse("${Session.baseUrl}/me"),
        headers: {"Authorization": "Bearer $token"},
      );

      if (Session.isUnauthorized(response)) return false;

      return response.statusCode == 200;
    } catch (e) {
      // Bez mreze ne odjavljujemo korisnika, greske se rjesavaju u aplikaciji
      return true;
    }
  }

  Future<void> startLoading() async {
    final results = await Future.wait([
      Future.delayed(const Duration(seconds: 2)),
      hasValidSession(),
    ]);

    final loggedIn = results[1] as bool;

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) =>
            loggedIn ? const MainNavigationScreen() : const WelcomeScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF083169),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(30),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset("assets/images/logo_white.png", width: 280),

              const SizedBox(height: 10),

              const Text(
                "Track. Train. Improve.",
                style: TextStyle(color: Colors.white70, fontSize: 16),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
