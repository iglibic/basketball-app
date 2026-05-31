import 'package:flutter/material.dart';

class TrainingSummaryScreen extends StatelessWidget {
  final int totalShots;
  final int madeShots;
  final int missedShots;
  final int percentage;

  const TrainingSummaryScreen({
    super.key,
    required this.totalShots,
    required this.madeShots,
    required this.missedShots,
    required this.percentage,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Training Summary")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text(
              "$percentage%",
              style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 30),

            Text(
              "Total Shots: $totalShots",
              style: const TextStyle(fontSize: 24),
            ),

            const SizedBox(height: 10),

            Text(
              "Made Shots: $madeShots",
              style: const TextStyle(fontSize: 24),
            ),

            const SizedBox(height: 10),

            Text(
              "Missed Shots: $missedShots",
              style: const TextStyle(fontSize: 24),
            ),
          ],
        ),
      ),
    );
  }
}
