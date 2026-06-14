import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  Widget featureTile({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF7C5CFF), size: 28),

          const SizedBox(width: 20),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 3),

                Text(
                  subtitle,
                  style: const TextStyle(color: Colors.white54, fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1224),

      appBar: AppBar(
        backgroundColor: const Color(0xFF0D1224),
        surfaceTintColor: Colors.transparent,
        scrolledUnderElevation: 0,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),

        title: const Text(
          "About BasketIQ",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 19,
          ),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Transform.translate(
              offset: const Offset(0, 0),
              child: Image.asset(
                "assets/images/basketball_logo_purple.png",
                height: 100,
                width: 100,
              ),
            ),

            RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: "Basket",
                    style: GoogleFonts.montserrat(
                      color: Colors.white,
                      fontSize: 48,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  TextSpan(
                    text: "IQ",
                    style: GoogleFonts.outfit(
                      color: const Color(0xFF6240CD),
                      fontSize: 48,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),

            const Text(
              "TRAIN. TRACK. IMPROVE.",
              style: TextStyle(
                color: Colors.white54,
                letterSpacing: 3,
                fontSize: 13,
              ),
            ),

            const SizedBox(height: 14),

            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF1A2238),
                borderRadius: BorderRadius.circular(11),
              ),
              child: const Text(
                "Version 1.0.0",
                style: TextStyle(
                  color: Color(0xFF7C5CFF),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),

            const SizedBox(height: 22),

            const Text(
              "BasketIQ helps basketball players\n track workouts, monitor shooting\n performance and improve consistency.",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white70,
                fontSize: 14,
                height: 1.5,
              ),
            ),

            const SizedBox(height: 30),

            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "FEATURES",
                style: TextStyle(
                  color: Color(0xFF7C5CFF),
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
              ),
            ),

            const SizedBox(height: 10),

            Container(
              padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF1A2238),
                borderRadius: BorderRadius.circular(11),
                border: Border.all(color: Colors.white10),
              ),
              child: Column(
                children: [
                  featureTile(
                    icon: Icons.assignment_outlined,
                    title: "Workout Tracking",
                    subtitle: "Log and manage your workouts",
                  ),

                  const Divider(color: Colors.white10),

                  featureTile(
                    icon: Icons.track_changes,
                    title: "Shot Statistics",
                    subtitle: "Track makes, attempts and percentages",
                  ),

                  const Divider(color: Colors.white10),

                  featureTile(
                    icon: Icons.bar_chart_rounded,
                    title: "FG% Analytics",
                    subtitle: "Analyze your shooting efficiency",
                  ),

                  const Divider(color: Colors.white10),

                  featureTile(
                    icon: Icons.calendar_month_outlined,
                    title: "Training History",
                    subtitle: "Review your progress over time",
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            const Icon(
              Icons.account_box_outlined,
              color: Color(0xFF7C5CFF),
              size: 34,
            ),

            const SizedBox(height: 4),

            RichText(
              text: const TextSpan(
                children: [
                  TextSpan(
                    text: "Developed by ",
                    style: TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                  TextSpan(
                    text: "Ivan Glibić",
                    style: TextStyle(
                      color: Color(0xFF7C5CFF),
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),

            Container(width: 300, height: 1, color: Colors.white10),

            const SizedBox(height: 20),

            const Text(
              "© 2026 BasketIQ. All rights reserved.",
              style: TextStyle(color: Colors.white38, fontSize: 13),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
