import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'training_summary_screen.dart';

class ActiveTrainingScreen extends StatefulWidget {
  final int trainingId;
  final int zoneId;

  const ActiveTrainingScreen({
    super.key,
    required this.trainingId,
    required this.zoneId,
  });

  @override
  State<ActiveTrainingScreen> createState() => _ActiveTrainingScreenState();
}

class _ActiveTrainingScreenState extends State<ActiveTrainingScreen> {
  int madeShots = 0;
  int missedShots = 0;

  Future<void> finishTraining() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final token = prefs.getString("token");

      final finishResponse = await http.put(
        Uri.parse("http://10.0.2.2:3000/trainings/${widget.trainingId}/finish"),
        headers: {"Authorization": "Bearer $token"},
      );

      if (finishResponse.statusCode != 200) {
        return;
      }

      final statsResponse = await http.get(
        Uri.parse("http://10.0.2.2:3000/trainings/${widget.trainingId}/stats"),
        headers: {"Authorization": "Bearer $token"},
      );

      if (statsResponse.statusCode == 200) {
        final data = jsonDecode(statsResponse.body);

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => TrainingSummaryScreen(
              totalShots: data["total_shots"],
              madeShots: data["made_shots"],
              missedShots: data["missed_shots"],
              percentage: data["percentage"],
            ),
          ),
        );
      }
    } catch (e) {
      print(e);
    }
  }

  Future<void> addShot(bool made) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final token = prefs.getString("token");

      final response = await http.post(
        Uri.parse("http://10.0.2.2:3000/shots"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode({
          "training_id": widget.trainingId,
          "zone_id": widget.zoneId,
          "made": made,
        }),
      );

      if (response.statusCode == 200) {
        setState(() {
          if (made) {
            madeShots++;
          } else {
            missedShots++;
          }
        });
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Training #${widget.trainingId}")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text("Made: $madeShots", style: const TextStyle(fontSize: 24)),

            const SizedBox(height: 10),

            Text("Missed: $missedShots", style: const TextStyle(fontSize: 24)),

            const SizedBox(height: 40),

            SizedBox(
              width: double.infinity,
              height: 60,
              child: ElevatedButton(
                onPressed: () => addShot(true),
                child: const Text("MADE"),
              ),
            ),

            const SizedBox(height: 15),

            SizedBox(
              width: double.infinity,
              height: 60,
              child: ElevatedButton(
                onPressed: () => addShot(false),
                child: const Text("MISSED"),
              ),
            ),
            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              height: 60,
              child: ElevatedButton(
                onPressed: finishTraining,
                child: const Text("FINISH TRAINING"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
