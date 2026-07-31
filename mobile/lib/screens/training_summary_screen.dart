import 'package:flutter/material.dart';

import '../models/position_result.dart';
import 'main_navigation_screen.dart';

class TrainingSummaryScreen extends StatelessWidget {
  final int totalShots;
  final int madeShots;
  final int missedShots;
  final int percentage;

  final List<PositionResult> results;
  final Duration? duration;
  final String workoutName;

  const TrainingSummaryScreen({
    super.key,
    required this.totalShots,
    required this.madeShots,
    required this.missedShots,
    required this.percentage,
    this.results = const [],
    this.duration,
    this.workoutName = "",
  });

  /// Prikazuju se samo pozicije na kojima je bilo pokusaja.
  List<PositionResult> get shotResults {
    return results.where((result) => result.attempts > 0).toList();
  }

  Color _percentageColor(int value) {
    if (value >= 65) return const Color(0xFF00D26A);
    if (value >= 50) return Colors.orangeAccent;

    return Colors.redAccent;
  }

  String _formatDuration(Duration value) {
    final minutes = value.inMinutes.toString().padLeft(2, '0');
    final seconds = (value.inSeconds % 60).toString().padLeft(2, '0');

    return "$minutes:$seconds";
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,

      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;

        _goHome(context);
      },

      child: Scaffold(
        backgroundColor: const Color(0xFF0D1224),

        appBar: AppBar(
          backgroundColor: const Color(0xFF0D1224),
          elevation: 0,
          centerTitle: true,
          automaticallyImplyLeading: false,
          title: const Text(
            "Training Summary",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),

        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (workoutName.isNotEmpty) ...[
                          Center(
                            child: Text(
                              workoutName,
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),

                          const SizedBox(height: 12),
                        ],

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

                        if (shotResults.isNotEmpty) ...[
                          const SizedBox(height: 26),

                          const Text(
                            "By Position",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          const SizedBox(height: 12),

                          ...shotResults.map(_buildPositionRow),
                        ],
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: () => _goHome(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF7C5CFF),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text(
                      "DONE",
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _goHome(BuildContext context) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const MainNavigationScreen()),
      (route) => false,
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

          if (duration != null) ...[
            const SizedBox(height: 14),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.timer_outlined,
                  color: Colors.white38,
                  size: 16,
                ),

                const SizedBox(width: 6),

                Text(
                  _formatDuration(duration!),
                  style: const TextStyle(color: Colors.white38, fontSize: 14),
                ),
              ],
            ),
          ],
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

  Widget _buildPositionRow(PositionResult result) {
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
                  result.position.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  "${result.makes} / ${result.attempts}",
                  style: const TextStyle(color: Colors.white54, fontSize: 13),
                ),
              ],
            ),
          ),

          Text(
            "${result.percentage}%",
            style: TextStyle(
              color: _percentageColor(result.percentage),
              fontSize: 17,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
