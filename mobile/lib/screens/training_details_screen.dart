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

  String? zonesError;

  @override
  void initState() {
    super.initState();
    loadDetails();
  }

  Future<void> loadDetails() async {
    await loadStats();
    await loadZoneStats();
  }

  Future<void> loadStats() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final token = prefs.getString("token");

      final response = await http.get(
        Uri.parse("http://10.0.2.2:3000/trainings/${widget.trainingId}/stats"),
        headers: {"Authorization": "Bearer $token"},
      );

      if (!mounted) return;

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
      if (!mounted) return;

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

      if (!mounted) return;

      if (response.statusCode != 200) {
        setState(() {
          zonesError = "Could not load zone statistics.";
        });

        return;
      }

      final data = jsonDecode(response.body);

      final loadedZones = List<Map<String, dynamic>>.from(data["zones"]);

      String best = "-";
      String worst = "-";

      if (loadedZones.isNotEmpty) {
        loadedZones.sort(
          (a, b) => (b["percentage"] as int).compareTo(a["percentage"] as int),
        );

        best = loadedZones.first["zone_name"];
        worst = loadedZones.last["zone_name"];
      }

      setState(() {
        zones = loadedZones;
        bestZone = best;
        worstZone = worst;
        zonesError = null;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        zonesError = "Could not load zone statistics.";
      });
    }
  }

  Color _percentageColor(int value) {
    if (value >= 65) return const Color(0xFF00D26A);
    if (value >= 50) return Colors.orangeAccent;

    return Colors.redAccent;
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFF0D1224),
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFF7C5CFF)),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF0D1224),

      appBar: AppBar(
        backgroundColor: const Color(0xFF0D1224),
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          widget.trainingName,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeroCard(),

            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    label: "Made",
                    value: "$madeShots",
                    color: const Color(0xFF00D26A),
                    icon: Icons.check_circle_outline,
                  ),
                ),

                const SizedBox(width: 10),

                Expanded(
                  child: _buildStatCard(
                    label: "Missed",
                    value: "$missedShots",
                    color: Colors.redAccent,
                    icon: Icons.cancel_outlined,
                  ),
                ),

                const SizedBox(width: 10),

                Expanded(
                  child: _buildStatCard(
                    label: "Total",
                    value: "$totalShots",
                    color: Colors.white,
                    icon: Icons.sports_basketball_outlined,
                  ),
                ),
              ],
            ),

            if (zonesError != null) ...[
              const SizedBox(height: 26),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A2238),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.redAccent.withValues(alpha: 0.4)),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.error_outline,
                      color: Colors.redAccent,
                      size: 20,
                    ),

                    const SizedBox(width: 10),

                    Expanded(
                      child: Text(
                        zonesError!,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                    ),

                    TextButton(
                      onPressed: loadZoneStats,
                      child: const Text(
                        "Retry",
                        style: TextStyle(color: Color(0xFF7C5CFF)),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            if (zones.isNotEmpty) ...[
              const SizedBox(height: 26),

              const Text(
                "Zone Statistics",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 12),

              ...zones.map(_buildZoneRow),

              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: _buildZoneHighlight(
                      label: "Best Zone",
                      zoneName: bestZone,
                      color: const Color(0xFF00D26A),
                      icon: Icons.trending_up,
                    ),
                  ),

                  const SizedBox(width: 10),

                  Expanded(
                    child: _buildZoneHighlight(
                      label: "Worst Zone",
                      zoneName: worstZone,
                      color: Colors.redAccent,
                      icon: Icons.trending_down,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildHeroCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 30),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white10),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1A2238), Color(0xFF141C31)],
        ),
      ),
      child: Column(
        children: [
          const Text(
            "FIELD GOAL",
            style: TextStyle(
              color: Color(0xFF7C5CFF),
              fontSize: 13,
              letterSpacing: 2,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 10),

          Text(
            "$percentage%",
            style: TextStyle(
              color: _percentageColor(percentage),
              fontSize: 58,
              fontWeight: FontWeight.bold,
              height: 1,
            ),
          ),

          const SizedBox(height: 10),

          Text(
            "$madeShots of $totalShots shots made",
            style: const TextStyle(color: Colors.white60, fontSize: 15),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required String label,
    required String value,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF141C31),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),

          const SizedBox(height: 8),

          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 2),

          Text(
            label,
            style: const TextStyle(color: Colors.white54, fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildZoneRow(dynamic zone) {
    final zonePercentage = zone["percentage"] as int;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFF1A2238),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  zone["zone_name"],
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  "${zone["made_shots"]} / ${zone["total_shots"]}",
                  style: const TextStyle(color: Colors.white54, fontSize: 13),
                ),
              ],
            ),
          ),

          Text(
            "$zonePercentage%",
            style: TextStyle(
              color: _percentageColor(zonePercentage),
              fontSize: 17,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildZoneHighlight({
    required String label,
    required String zoneName,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF141C31),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 16),

              const SizedBox(width: 6),

              Text(
                label,
                style: const TextStyle(color: Colors.white54, fontSize: 13),
              ),
            ],
          ),

          const SizedBox(height: 8),

          Text(
            zoneName,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
