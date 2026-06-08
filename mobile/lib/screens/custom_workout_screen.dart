import 'package:flutter/material.dart';

class CustomWorkoutScreen extends StatelessWidget {
  const CustomWorkoutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1224),

      appBar: AppBar(
        backgroundColor: const Color(0xFF0D1224),
        elevation: 0,

        iconTheme: const IconThemeData(color: Colors.white),
      ),

      body: const Center(
        child: Text(
          "Custom Workout",
          style: TextStyle(
            color: Colors.white,
            fontSize: 30,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
