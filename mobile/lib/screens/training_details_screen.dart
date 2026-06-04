import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class TrainingDetailsScreen extends StatefulWidget {
  final int trainingId;
  final String trainingName;

  const TrainingDetailsScreen({
    super.key,
    required this.trainingId,
    required this.trainingName,
  });

  @override
  State<TrainingDetailsScreen> createState() => _TrainingDetailsScreenState();
}

class _TrainingDetailsScreenState extends State<TrainingDetailsScreen> {
  bool isLoading = true;

  int totalShots = 0;
  int madeShots = 0;
  int missedShots = 0;
  int percentage = 0;

  List zones = [];

  String bestZone = "-";
  String worstZone = "-";

  @override
  void initState() {
    super.initState();
    loadStats();
    loadZoneStats();
  }

  Future<void> loadStats() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final token = prefs.getString("token");

      final response = await http.get(
        Uri.parse("http://10.0.2.2:3000/trainings/${widget.trainingId}/stats"),
        headers: {"Authorization": "Bearer $token"},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        setState(() {
          totalShots = data["total_shots"];
          madeShots = data["made_shots"];
          missedShots = data["missed_shots"];
          percentage = data["percentage"];

          isLoading = false;
        });
      } else {
        setState(() {
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

  Future<void> loadZoneStats() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final token = prefs.getString("token");

      final response = await http.get(
        Uri.parse(
          "http://10.0.2.2:3000/trainings/${widget.trainingId}/zone-stats",
        ),
        headers: {"Authorization": "Bearer $token"},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        final loadedZones = data["zones"];

        String best = "-";
        String worst = "-";

        if (loadedZones.isNotEmpty) {
          loadedZones.sort(
            (a, b) => b["percentage"].compareTo(a["percentage"]),
          );

          best = loadedZones.first["zone_name"];
          worst = loadedZones.last["zone_name"];
        }

        setState(() {
          zones = loadedZones;
          bestZone = best;
          worstZone = worst;
        });
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(title: Text(widget.trainingName)),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Text(
                "$percentage%",
                style: const TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 30),

              Card(
                child: ListTile(
                  title: const Text("Total Shots"),
                  trailing: Text("$totalShots"),
                ),
              ),

              Card(
                child: ListTile(
                  title: const Text("Made Shots"),
                  trailing: Text("$madeShots"),
                ),
              ),

              Card(
                child: ListTile(
                  title: const Text("Missed Shots"),
                  trailing: Text("$missedShots"),
                ),
              ),
              const SizedBox(height: 30),

              const Text(
                "Zone Statistics",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 15),

              ...zones.map(
                (zone) => Card(
                  child: ListTile(
                    title: Text(zone["zone_name"]),
                    subtitle: Text(
                      "${zone["made_shots"]}/${zone["total_shots"]}",
                    ),
                    trailing: Text("${zone["percentage"]}%"),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              Card(
                child: ListTile(
                  title: const Text("Best Zone"),
                  trailing: Text(bestZone),
                ),
              ),

              Card(
                child: ListTile(
                  title: const Text("Worst Zone"),
                  trailing: Text(worstZone),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
