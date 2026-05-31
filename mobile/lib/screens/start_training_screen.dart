import 'package:flutter/material.dart';

import 'dart:convert';

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

  @override
  void dispose() {
    trainingNameController.dispose();
    super.dispose();
  }

  Future<void> createTraining() async {
    if (trainingNameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Enter training name")));
      return;
    }

    try {
      final prefs = await SharedPreferences.getInstance();

      final token = prefs.getString("token");
      print("TOKEN: $token");

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

      print(response.body);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) =>
                ActiveTrainingScreen(trainingId: data["training_id"]),
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
