import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../screens/welcome_screen.dart';

/// Zajednicko mjesto za rad s prijavom.
/// Svi ekrani preko ovoga citaju token i reagiraju na istekle sesije,
/// da se logika odjave ne ponavlja po ekranima.
class Session {
  static const String baseUrl = "http://10.0.2.2:3000";

  static Future<String?> token() async {
    final prefs = await SharedPreferences.getInstance();

    return prefs.getString("token");
  }

  static Future<Map<String, String>> headers({bool json = false}) async {
    final value = await token();

    return {
      if (json) "Content-Type": "application/json",
      "Authorization": "Bearer $value",
    };
  }

  static bool isUnauthorized(http.Response response) {
    return response.statusCode == 401 || response.statusCode == 403;
  }

  /// Ako je sesija istekla, odjavljuje korisnika i vraca true.
  /// Ekran tada treba samo prekinuti svoju obradu.
  static Future<bool> handleUnauthorized(
    BuildContext context,
    http.Response response,
  ) async {
    if (!isUnauthorized(response)) return false;

    await logout(context, expired: true);

    return true;
  }

  static Future<void> logout(
    BuildContext context, {
    bool expired = false,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.remove("token");

    if (!context.mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const WelcomeScreen()),
      (route) => false,
    );

    if (expired) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Your session expired. Please log in again."),
          backgroundColor: Color(0xFF7C5CFF),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  /// Backend vraca greske kao {"message": "..."}.
  /// Ostavljen je i fallback za obican tekst.
  static String errorMessage(http.Response response, String fallback) {
    if (response.body.isEmpty) return fallback;

    try {
      final data = jsonDecode(response.body);

      if (data is Map && data["message"] is String) {
        return data["message"];
      }
    } catch (e) {
      // Odgovor nije JSON, koristi se sirovi tekst
    }

    return response.body;
  }
}
