import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'active_training_screen.dart';

class StartTrainingScreen extends StatefulWidget {
  const StartTrainingScreen({super.key});

  @override
  State<StartTrainingScreen> createState() => _StartTrainingScreenState();
}

class _StartTrainingScreenState extends State<StartTrainingScreen> {
  final trainingNameController = TextEditingController();

  List<dynamic> zones = [];
  int? selectedZoneId;

  @override
  void initState() {
    super.initState();
    loadZones();
  }

  @override
  void dispose() {
    trainingNameController.dispose();
    super.dispose();
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
        });
      }
    } catch (e) {
      print(e);
    }
  }

  Future<void> createTraining() async {
    if (trainingNameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Enter training name")));
      return;
    }

    if (selectedZoneId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Select a zone")));
      return;
    }

    try {
      final prefs = await SharedPreferences.getInstance();

      final token = prefs.getString("token");

      final response = await http.post(
        Uri.parse("http://10.0.2.2:3000/trainings"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode({
          "training_name": trainingNameController.text,
          "template_id": null,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => ActiveTrainingScreen(
              trainingId: data["training_id"],
              zoneId: selectedZoneId!,
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(response.body)));
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Start Training")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: trainingNameController,
              decoration: const InputDecoration(labelText: "Training Name"),
            ),

            const SizedBox(height: 20),

            DropdownButton<int>(
              value: selectedZoneId,
              isExpanded: true,
              items: zones.map((zone) {
                return DropdownMenuItem<int>(
                  value: zone["zone_id"],
                  child: Text(zone["zone_name"]),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedZoneId = value;
                });
              },
            ),

            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: createTraining,
                child: const Text("START TRAINING"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
