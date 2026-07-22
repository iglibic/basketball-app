import 'package:flutter/material.dart';

class CourtPreview extends StatelessWidget {
  const CourtPreview({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 180,
      decoration: BoxDecoration(
        color: const Color(0xFF252E48),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Icon(
            Icons.sports_basketball_outlined,
            size: 60,
            color: Colors.white.withValues(alpha: 0.08),
          ),

          const Text(
            "Court Preview",
            style: TextStyle(
              color: Colors.white54,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
