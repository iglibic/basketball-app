import 'package:flutter/material.dart';
import '../../models/preset_position.dart';
import '../court_preview.dart';

class PositionInfoSheet extends StatelessWidget {
  final PresetPosition position;

  const PositionInfoSheet({super.key, required this.position});

  Widget _statRow(String title, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(color: Colors.white60, fontSize: 14),
        ),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 15,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),

            const SizedBox(height: 24),

            Text(
              position.name,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: const Color(0xFF252E48),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                position.category,
                style: const TextStyle(
                  color: Color(0xFFB99CFF),
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(height: 24),

            const Text(
              "Court Preview",
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 12),

            const CourtPreview(),

            const SizedBox(height: 20),

            const SizedBox(height: 24),

            const Text(
              "Your Statistics",
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 12),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: const Color(0xFF151D33),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
              ),
              child: Column(
                children: [
                  _statRow("FG%", "--"),
                  const SizedBox(height: 14),
                  _statRow("Shots", "--"),
                  const SizedBox(height: 14),
                  _statRow("Makes", "--"),
                  const SizedBox(height: 14),
                  _statRow("Best Streak", "--"),
                ],
              ),
            ),

            const SizedBox(height: 24),

            const Text(
              "Description",
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 14),

            Text(
              position.description.isEmpty
                  ? "No description available."
                  : position.description,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 15,
                height: 1.7,
                letterSpacing: 0.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
