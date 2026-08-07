import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../services/session.dart';
import '../widgets/court/shot_chart_court.dart';

class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  bool isLoading = true;
  String? loadError;

  int totalShots = 0;
  int madeShots = 0;
  int missedShots = 0;
  int percentage = 0;
  int trainings = 0;

  List zones = [];
  List recentTrainings = [];

  int globalPercentage = 0;

  @override
  void initState() {
    super.initState();
    loadStatistics();
  }

  Future<void> loadStatistics() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("token");

      final headers = {"Authorization": "Bearer $token"};

      final responses = await Future.wait([
        http.get(
          Uri.parse("http://10.0.2.2:3000/my-stats"),
          headers: headers,
        ),
        http.get(
          Uri.parse("http://10.0.2.2:3000/my-zone-stats"),
          headers: headers,
        ),
        http.get(
          Uri.parse("http://10.0.2.2:3000/global-stats"),
          headers: headers,
        ),
        http.get(
          Uri.parse("http://10.0.2.2:3000/all-trainings"),
          headers: headers,
        ),
      ]);

      if (!mounted) return;

      for (final response in responses) {
        if (await Session.handleUnauthorized(context, response)) return;
      }

      if (!mounted) return;

      final failed = responses.any((response) => response.statusCode != 200);

      if (failed) {
        setState(() {
          isLoading = false;
          loadError = "Could not load your statistics.";
        });

        return;
      }

      final myStats = jsonDecode(responses[0].body);
      final zoneStats = jsonDecode(responses[1].body);
      final globalStats = jsonDecode(responses[2].body);
      final allTrainings = jsonDecode(responses[3].body);

      setState(() {
        totalShots = myStats["total_shots"];
        madeShots = myStats["made_shots"];
        missedShots = myStats["missed_shots"];
        percentage = myStats["percentage"];
        trainings = myStats["trainings"];

        zones = zoneStats["zones"];
        globalPercentage = globalStats["overall_percentage"];

        // Zadnjih 7 treninga, poredanih od najstarijeg prema najnovijem
        recentTrainings = allTrainings.take(7).toList().reversed.toList();

        isLoading = false;
        loadError = null;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
        loadError = "Could not load your statistics.";
      });
    }
  }

  Color _percentageColor(int value) {
    if (value >= 65) return const Color(0xFF00D26A);
    if (value >= 50) return Colors.orangeAccent;

    return Colors.redAccent;
  }

  List get sortedZones {
    final sorted = List.from(zones);

    sorted.sort(
      (a, b) => (b["percentage"] as int).compareTo(a["percentage"] as int),
    );

    return sorted;
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
        automaticallyImplyLeading: false,
        title: const Text(
          "Statistics",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),

      body: SafeArea(
        child: RefreshIndicator(
          color: const Color(0xFF7C5CFF),
          backgroundColor: const Color(0xFF1A2238),
          onRefresh: loadStatistics,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 110),
            children: [
              if (loadError != null)
                _buildErrorCard()
              else if (totalShots == 0)
                _buildEmptyState()
              else ...[
                _buildOverallCard(),

                const SizedBox(height: 16),

                _buildSummaryRow(),

                const SizedBox(height: 26),

                _buildSectionTitle("Shot Chart"),

                const SizedBox(height: 12),

                _buildShotChart(),

                const SizedBox(height: 26),

                _buildSectionTitle("Compared to Everyone"),

                const SizedBox(height: 12),

                _buildComparisonCard(),

                if (recentTrainings.length >= 2) ...[
                  const SizedBox(height: 26),

                  _buildSectionTitle("Recent Form"),

                  const SizedBox(height: 12),

                  _buildTrendCard(),
                ],

                const SizedBox(height: 26),

                _buildSectionTitle("By Zone"),

                const SizedBox(height: 12),

                ...sortedZones.map(_buildZoneRow),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildErrorCard() {
    return Container(
      margin: const EdgeInsets.only(top: 40),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1A2238),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.redAccent.withValues(alpha: 0.4)),
      ),
      child: Column(
        children: [
          const Icon(Icons.error_outline, color: Colors.redAccent, size: 36),

          const SizedBox(height: 12),

          Text(
            loadError!,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white70, fontSize: 15),
          ),

          const SizedBox(height: 12),

          TextButton(
            onPressed: loadStatistics,
            child: const Text(
              "Retry",
              style: TextStyle(
                color: Color(0xFF7C5CFF),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.only(top: 80),
      child: Column(
        children: [
          const Icon(
            Icons.query_stats,
            color: Colors.white24,
            size: 64,
          ),

          const SizedBox(height: 16),

          const Text(
            "No statistics yet",
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 8),

          const Text(
            "Finish your first workout and your\nshooting statistics will appear here.",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white54, fontSize: 14, height: 1.5),
          ),
        ],
      ),
    );
  }

  Widget _buildOverallCard() {
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
            "CAREER FIELD GOAL",
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

  Widget _buildSummaryRow() {
    return Row(
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
            label: "Workouts",
            value: "$trainings",
            color: Colors.white,
            icon: Icons.event_available_outlined,
          ),
        ),
      ],
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

  Widget _buildShotChart() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF10192E),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF2A3661)),
      ),
      child: Column(
        children: [
          ShotChartCourt(zones: zones),

          const SizedBox(height: 12),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildLegendDot(const Color(0xFF00D26A), "65%+"),

              const SizedBox(width: 16),

              _buildLegendDot(Colors.orangeAccent, "50-64%"),

              const SizedBox(width: 16),

              _buildLegendDot(Colors.redAccent, "under 50%"),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegendDot(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),

        const SizedBox(width: 6),

        Text(
          label,
          style: const TextStyle(color: Colors.white54, fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildComparisonCard() {
    final difference = percentage - globalPercentage;

    final isAhead = difference >= 0;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1A2238),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              children: [
                const Text(
                  "You",
                  style: TextStyle(color: Colors.white54, fontSize: 13),
                ),

                const SizedBox(height: 6),

                Text(
                  "$percentage%",
                  style: TextStyle(
                    color: _percentageColor(percentage),
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          Container(width: 1, height: 46, color: Colors.white12),

          Expanded(
            child: Column(
              children: [
                const Text(
                  "Everyone",
                  style: TextStyle(color: Colors.white54, fontSize: 13),
                ),

                const SizedBox(height: 6),

                Text(
                  "$globalPercentage%",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          Container(width: 1, height: 46, color: Colors.white12),

          Expanded(
            child: Column(
              children: [
                const Text(
                  "Difference",
                  style: TextStyle(color: Colors.white54, fontSize: 13),
                ),

                const SizedBox(height: 6),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      isAhead ? Icons.trending_up : Icons.trending_down,
                      color: isAhead
                          ? const Color(0xFF00D26A)
                          : Colors.redAccent,
                      size: 18,
                    ),

                    const SizedBox(width: 4),

                    Text(
                      "${isAhead ? "+" : ""}$difference",
                      style: TextStyle(
                        color: isAhead
                            ? const Color(0xFF00D26A)
                            : Colors.redAccent,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrendCard() {
    int maxPercentage = 0;

    for (final training in recentTrainings) {
      final value = int.tryParse(training["percentage"].toString()) ?? 0;

      if (value > maxPercentage) maxPercentage = value;
    }

    if (maxPercentage == 0) maxPercentage = 100;

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 14),
      decoration: BoxDecoration(
        color: const Color(0xFF1A2238),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        children: [
          // 132 = label (~15) + razmak (4) + najvisi stupac (100) + rezerva
          SizedBox(
            height: 132,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: recentTrainings.map<Widget>((training) {
                final value =
                    int.tryParse(training["percentage"].toString()) ?? 0;

                final barHeight = 20 + (value / maxPercentage) * 80;

                return Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      "$value",
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 4),

                    Container(
                      width: 18,
                      height: barHeight,
                      decoration: BoxDecoration(
                        color: _percentageColor(value),
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),

          const SizedBox(height: 10),

          const Text(
            "Field goal % of your most recent workouts",
            style: TextStyle(color: Colors.white38, fontSize: 12),
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

                const SizedBox(height: 6),

                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: zonePercentage / 100,
                    minHeight: 6,
                    backgroundColor: const Color(0xFF252E48),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      _percentageColor(zonePercentage),
                    ),
                  ),
                ),

                const SizedBox(height: 6),

                Text(
                  "${zone["made_shots"]} / ${zone["total_shots"]} shots",
                  style: const TextStyle(color: Colors.white54, fontSize: 12),
                ),
              ],
            ),
          ),

          const SizedBox(width: 16),

          Text(
            "$zonePercentage%",
            style: TextStyle(
              color: _percentageColor(zonePercentage),
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
