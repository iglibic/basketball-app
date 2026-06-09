import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import 'dart:convert';

import 'welcome_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String firstName = "";
  String lastName = "";
  String nickname = "";
  String email = "";

  int totalShots = 0;
  int trainings = 0;
  int percentage = 0;

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadUser();
    loadStats();
  }

  Future<void> loadUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("token");

      final response = await http.get(
        Uri.parse("http://10.0.2.2:3000/me"),
        headers: {"Authorization": "Bearer $token"},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        setState(() {
          firstName = data["first_name"] ?? "";
          lastName = data["last_name"] ?? "";
          nickname = data["nickname"] ?? "";
          email = data["email"] ?? "";
        });
      }
    } catch (e) {
      print(e);
    }
  }

  Future<void> loadStats() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("token");

      final response = await http.get(
        Uri.parse("http://10.0.2.2:3000/my-stats"),
        headers: {"Authorization": "Bearer $token"},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        setState(() {
          totalShots = data["total_shots"];
          trainings = data["trainings"];
          percentage = data["percentage"];
          isLoading = false;
        });
      }
    } catch (e) {
      print(e);

      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.remove("token");

    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const WelcomeScreen()),
      (route) => false,
    );
  }

  Widget profileTile({
    required IconData icon,
    required String title,
    VoidCallback? onTap,
    Color iconColor = const Color(0xFF7C5CFF),
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(11)),
      child: Material(
        color: const Color(0xFF1A2238),
        borderRadius: BorderRadius.circular(11),
        child: InkWell(
          borderRadius: BorderRadius.circular(11),
          onTap: onTap,
          child: ListTile(
            onTap: onTap,
            leading: Icon(icon, color: iconColor),
            title: Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
            trailing: Icon(Icons.arrow_forward_ios, color: iconColor, size: 16),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFF0D1224),
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFF7C5CFF)),
        ),
      );
    }
    return Scaffold(
      backgroundColor: const Color(0xFF0D1224),

      body: SingleChildScrollView(
        physics: const ClampingScrollPhysics(),
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 90),

            Transform.translate(
              offset: const Offset(0, -15),
              child: Stack(
                children: [
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,

                      border: Border.all(
                        color: const Color(0xFF7C5CFF),
                        width: 2,
                      ),

                      boxShadow: [
                        BoxShadow(
                          color: const Color(
                            0xFF7C5CFF,
                          ).withValues(alpha: 0.25),
                          blurRadius: 4,
                          spreadRadius: 2,
                        ),
                      ],
                    ),

                    child: Center(
                      child: Center(
                        child: Text(
                          "${firstName.isNotEmpty ? firstName[0] : ""}${lastName.isNotEmpty ? lastName[0] : ""}",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),

                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        color: const Color(0xFF7C5CFF),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: const Color(0xFF0D1224),
                          width: 3,
                        ),
                      ),
                      child: const Icon(
                        Icons.add_a_photo_outlined,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 0),

            Text(
              "$firstName $lastName",
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            Text(
              "@$nickname",
              style: TextStyle(color: Colors.white54, fontSize: 14),
            ),

            const SizedBox(height: 14),

            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF1A2238),
                borderRadius: BorderRadius.circular(11),
                border: Border.all(color: Colors.white10),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        const Icon(
                          Icons.sports_basketball_outlined,
                          color: Color(0xFF7C5CFF),
                        ),
                        const SizedBox(height: 3),
                        const Text(
                          "Shots",
                          style: TextStyle(color: Colors.white54, fontSize: 13),
                        ),
                        Text(
                          totalShots.toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),

                  Container(
                    width: 1,
                    height: 80,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.white24,
                          Colors.white24,
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: Column(
                      children: [
                        const Icon(
                          Icons.gps_fixed_outlined,
                          color: Color(0xFF7C5CFF),
                        ),
                        const SizedBox(height: 3),
                        const Text(
                          "FG %",
                          style: TextStyle(color: Colors.white54, fontSize: 13),
                        ),

                        Text(
                          "$percentage%",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),

                  Container(
                    width: 1,
                    height: 80,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.white24,
                          Colors.white24,
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),

                  Expanded(
                    child: Column(
                      children: [
                        const Icon(
                          Icons.bar_chart_rounded,
                          color: Color(0xFF7C5CFF),
                          size: 24,
                        ),
                        const SizedBox(height: 3),
                        const Text(
                          "Trainings",
                          style: TextStyle(color: Colors.white54, fontSize: 13),
                        ),
                        Text(
                          trainings.toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 18),

            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Account",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(height: 10),

            profileTile(icon: Icons.person_outline, title: "Edit Profile"),

            profileTile(icon: Icons.lock_outline, title: "Change Password"),

            const SizedBox(height: 12),

            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Support",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(height: 12),

            profileTile(icon: Icons.info_outline, title: "About BasketIQ"),

            const SizedBox(height: 14),

            profileTile(
              icon: Icons.logout,
              title: "Logout",
              iconColor: Colors.redAccent,
              onTap: logout,
            ),

            const SizedBox(height: 60),
          ],
        ),
      ),
    );
  }
}
