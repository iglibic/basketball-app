import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'training_summary_screen.dart';

class ActiveTrainingScreen extends StatefulWidget {
  final int trainingId;

  const ActiveTrainingScreen({super.key, required this.trainingId});

  @override
  State<ActiveTrainingScreen> createState() => _ActiveTrainingScreenState();
}

class _ActiveTrainingScreenState extends State<ActiveTrainingScreen> {
  int madeShots = 0;
  int missedShots = 0;

  List zones = [];

  int? selectedZoneId;

  bool isLoadingZones = true;

  @override
  void initState() {
    super.initState();
    loadZones();
  }

  Future<void> loadZones() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final token = prefs.getString("token");

      final response = await http.get(
        Uri.parse("http://10.0.2.2:3000/zones"),
        headers: {"Authorization": "Bearer $token"},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        setState(() {
          zones = data;

          if (zones.isNotEmpty) {
            selectedZoneId = zones[0]["zone_id"];
          }

          isLoadingZones = false;
        });
      }
    } catch (e) {
      print(e);

      setState(() {
        isLoadingZones = false;
      });
    }
  }

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
    if (selectedZoneId == null) {
      return;
    }

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
          "zone_id": selectedZoneId,
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
    if (isLoadingZones) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(title: Text("Training #${widget.trainingId}")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Text("Made: $madeShots", style: const TextStyle(fontSize: 24)),

              const SizedBox(height: 10),

              Text(
                "Missed: $missedShots",
                style: const TextStyle(fontSize: 24),
              ),

              const SizedBox(height: 30),

              const Text(
                "Selected Zone",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 15),

              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: zones.map<Widget>((zone) {
                  final isSelected = selectedZoneId == zone["zone_id"];

                  return ElevatedButton(
                    onPressed: () {
                      setState(() {
                        selectedZoneId = zone["zone_id"];
                      });
                    },
                    child: Text(
                      isSelected ? "✓ ${zone["zone_name"]}" : zone["zone_name"],
                    ),
                  );
                }).toList(),
              ),

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
      ),
    );
  }
}
