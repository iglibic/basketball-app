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

  /// Lokalno pracenje makes/attempts po zoni (kljuc = zone_id)
  final Map<int, int> _makesByZone = {};
  final Map<int, int> _attemptsByZone = {};

  bool isLoadingZones = true;
  bool isFinishing = false;

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

  void addShot(bool made) {
    if (selectedZoneId == null) return;

    setState(() {
      _attemptsByZone[selectedZoneId!] =
          (_attemptsByZone[selectedZoneId!] ?? 0) + 1;

      if (made) {
        _makesByZone[selectedZoneId!] =
            (_makesByZone[selectedZoneId!] ?? 0) + 1;
        madeShots++;
      } else {
        missedShots++;
      }
    });
  }

  Future<void> finishTraining() async {
    if (isFinishing) return;
    setState(() => isFinishing = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("token");

      // 1. Posalji POST za svaku zonu koja ima > 0 attempts
      for (final zone in zones) {
        final zoneId = zone["zone_id"] as int;
        final attempts = _attemptsByZone[zoneId] ?? 0;
        final makes = _makesByZone[zoneId] ?? 0;

        if (attempts == 0) continue;

        final response = await http.post(
          Uri.parse("http://10.0.2.2:3000/shots"),
          headers: {
            "Content-Type": "application/json",
            "Authorization": "Bearer $token",
          },
          body: jsonEncode({
            "training_id": widget.trainingId,
            "zone_id": zoneId,
            "makes": makes,
            "attempts": attempts,
          }),
        );

        if (response.statusCode != 200 && response.statusCode != 201) {
          setState(() => isFinishing = false);

          if (!mounted) return;

          String errorMsg;
          if (response.statusCode == 409) {
            errorMsg =
                "Shot record already exists for zone '${zone["zone_name"]}'. "
                "A training cannot have duplicate zone entries. "
                "Please start a new training.";
          } else {
            errorMsg =
                "Failed to save data for zone '${zone["zone_name"]}'. "
                "Please try again. (Error ${response.statusCode})";
          }

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: Colors.red.shade700,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              content: Text(errorMsg),
            ),
          );
          return;
        }
      }

      // 2. Oznaci trening kao zavrsen
      final finishResponse = await http.put(
        Uri.parse("http://10.0.2.2:3000/trainings/${widget.trainingId}/finish"),
        headers: {"Authorization": "Bearer $token"},
      );

      if (finishResponse.statusCode != 200) {
        setState(() => isFinishing = false);
        return;
      }

      // 3. Dohvati statistikU i navigiraj na summary
      final statsResponse = await http.get(
        Uri.parse("http://10.0.2.2:3000/trainings/${widget.trainingId}/stats"),
        headers: {"Authorization": "Bearer $token"},
      );

      if (statsResponse.statusCode == 200) {
        final data = jsonDecode(statsResponse.body);

        if (!mounted) return;
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
      setState(() => isFinishing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoadingZones) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: const Color(0xFF0D1224),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D1224),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          "Training #${widget.trainingId}",
          style: const TextStyle(color: Colors.white),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Prikaz ukupnih rezultata
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildStatCard("Made", madeShots, const Color(0xFF00D26A)),
                  _buildStatCard("Missed", missedShots, Colors.redAccent),
                  _buildStatCard(
                    "Total",
                    madeShots + missedShots,
                    Colors.white,
                  ),
                ],
              ),

              const SizedBox(height: 30),

              const Text(
                "Select Zone",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 15),

              // Zone buttons with local zone stats
              ...zones.map<Widget>((zone) {
                final zoneId = zone["zone_id"] as int;
                final isSelected = selectedZoneId == zoneId;
                final zoneMakes = _makesByZone[zoneId] ?? 0;
                final zoneAttempts = _attemptsByZone[zoneId] ?? 0;

                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        selectedZoneId = zoneId;
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isSelected
                          ? const Color(0xFF7C5CFF)
                          : const Color(0xFF1A2238),
                      minimumSize: const Size(double.infinity, 52),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          zone["zone_name"],
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                        if (zoneAttempts > 0)
                          Text(
                            "$zoneMakes/$zoneAttempts",
                            style: const TextStyle(
                              color: Color(0xFF7C5CFF),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              }),

              const SizedBox(height: 30),

              // Dugmad za MADE / MISSED
              SizedBox(
                width: double.infinity,
                height: 60,
                child: ElevatedButton(
                  onPressed: selectedZoneId == null
                      ? null
                      : () => addShot(true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00D26A),
                    disabledBackgroundColor: const Color(0xFF1A2238),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    "MADE",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 15),

              SizedBox(
                width: double.infinity,
                height: 60,
                child: ElevatedButton(
                  onPressed: selectedZoneId == null
                      ? null
                      : () => addShot(false),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    disabledBackgroundColor: const Color(0xFF1A2238),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    "MISSED",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 30),

              SizedBox(
                width: double.infinity,
                height: 60,
                child: ElevatedButton(
                  onPressed: isFinishing ? null : finishTraining,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF7C5CFF),
                    disabledBackgroundColor: const Color(0xFF1A2238),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: isFinishing
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          "FINISH TRAINING",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(String label, int value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF1A2238),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            value.toString(),
            style: TextStyle(
              color: color,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(color: Colors.white54, fontSize: 13),
          ),
        ],
      ),
    );
  }
}
