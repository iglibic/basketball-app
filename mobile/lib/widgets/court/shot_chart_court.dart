import 'package:flutter/material.dart';

import 'basketball_court.dart' show kCourtAspectRatio;

/// Prikazuje statistiku po zonama na terenu.
/// Ocekuje mape iz GET /my-zone-stats (x_position / y_position su postoci 0-100).
class ShotChartCourt extends StatelessWidget {
  final List zones;

  const ShotChartCourt({super.key, required this.zones});

  static Color colorFor(int percentage) {
    if (percentage >= 65) return const Color(0xFF00D26A);
    if (percentage >= 50) return Colors.orangeAccent;

    return Colors.redAccent;
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: AspectRatio(
        aspectRatio: kCourtAspectRatio,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;
            final height = constraints.maxHeight;

            return Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned.fill(
                  child: Opacity(
                    opacity: 0.6,
                    child: Image.asset(
                      "assets/court/half_court.png",
                      fit: BoxFit.fill,
                    ),
                  ),
                ),

                ...zones.map((zone) {
                  final percentage = zone["percentage"] as int;
                  final color = colorFor(percentage);

                  final x = (zone["x_position"] as num) / 100;
                  final y = (zone["y_position"] as num) / 100;

                  const size = 40.0;

                  return Positioned(
                    left: (x * width) - (size / 2),
                    top: (y * height) - (size / 2),
                    child: Container(
                      width: size,
                      height: size,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.22),
                        shape: BoxShape.circle,
                        border: Border.all(color: color, width: 2),
                        boxShadow: [
                          BoxShadow(
                            color: color.withValues(alpha: 0.35),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                      child: Text(
                        "$percentage",
                        style: TextStyle(
                          color: color,
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  );
                }),
              ],
            );
          },
        ),
      ),
    );
  }
}
