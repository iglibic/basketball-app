import 'package:flutter/material.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Register")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: ListView(
          children: const [
            TextField(decoration: InputDecoration(labelText: "First Name")),

            SizedBox(height: 15),

            TextField(decoration: InputDecoration(labelText: "Last Name")),

            SizedBox(height: 15),

            TextField(decoration: InputDecoration(labelText: "Nickname")),

            SizedBox(height: 15),

            TextField(
              obscureText: true,
              decoration: InputDecoration(labelText: "Password"),
            ),

            SizedBox(height: 15),

            TextField(
              obscureText: true,
              decoration: InputDecoration(labelText: "Repeat Password"),
            ),

            SizedBox(height: 30),

            SizedBox(
              height: 50,
              child: ElevatedButton(onPressed: null, child: Text("Register")),
            ),
          ],
        ),
      ),
    );
  }
}
