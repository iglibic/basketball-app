import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../services/session.dart';
import 'training_details_screen.dart';

class TrainingHistoryScreen extends StatefulWidget {
  const TrainingHistoryScreen({super.key});

  @override
  State<TrainingHistoryScreen> createState() => _TrainingHistoryScreenState();
}

class _TrainingHistoryScreenState extends State<TrainingHistoryScreen> {
  List trainings = [];

  List filteredTrainings = [];
  String selectedFilter = "All";
  String searchQuery = "";

  final TextEditingController searchController = TextEditingController();

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadTrainings();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  Future<void> loadTrainings() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final token = prefs.getString("token");

      final response = await http.get(
        Uri.parse("http://10.0.2.2:3000/all-trainings"),
        headers: {"Authorization": "Bearer $token"},
      );

      if (!mounted) return;

      if (await Session.handleUnauthorized(context, response)) return;

      if (response.statusCode == 200) {
        setState(() {
          trainings = jsonDecode(response.body);
          isLoading = false;
        });

        applyFilters();
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

  /// Pretraga i filter po datumu se primjenjuju zajedno,
  /// tako da jedno ne ponistava drugo.
  void applyFilters() {
    final now = DateTime.now();

    setState(() {
      filteredTrainings = trainings.where((training) {
        final matchesSearch = training["training_name"]
            .toString()
            .toLowerCase()
            .contains(searchQuery.toLowerCase());

        if (!matchesSearch) return false;

        final date = DateTime.parse(training["started_at"]).toLocal();

        switch (selectedFilter) {
          case "This Week":
            final startOfWeek = now.subtract(Duration(days: now.weekday - 1));

            return date.isAfter(startOfWeek.subtract(const Duration(days: 1)));

          case "This Month":
            return date.month == now.month && date.year == now.year;

          case "This Year":
            return date.year == now.year;

          default:
            return true;
        }
      }).toList();
    });
  }

  void onSearchChanged(String query) {
    searchQuery = query;
    applyFilters();
  }

  void onFilterChanged(String filter) {
    selectedFilter = filter;
    applyFilters();
  }

  Future<void> deleteTraining(int trainingId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("token");

      final response = await http.delete(
        Uri.parse("http://10.0.2.2:3000/trainings/$trainingId"),
        headers: {"Authorization": "Bearer $token"},
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        setState(() {
          trainings.removeWhere(
            (training) => training["training_id"] == trainingId,
          );
        });

        applyFilters();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Workout deleted"),
            backgroundColor: Color(0xFF00D26A),
            behavior: SnackBarBehavior.floating,
          ),
        );
      } else {
        _showError("Could not delete workout.");
      }
    } catch (e) {
      if (!mounted) return;

      _showError("Could not delete workout. Check your connection.");
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Color(0xFFD32F2F),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<bool> confirmDelete(String trainingName) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A2238),

        title: const Text(
          "Delete workout?",
          style: TextStyle(color: Colors.white),
        ),

        content: Text(
          "\"$trainingName\" and all its shots will be permanently deleted.",
          style: const TextStyle(color: Colors.white70),
        ),

        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),

          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              "Delete",
              style: TextStyle(color: Colors.redAccent),
            ),
          ),
        ],
      ),
    );

    return confirmed ?? false;
  }

  String formatDate(String dateString) {
    final date = DateTime.parse(dateString).toLocal();

    const months = [
      "Jan",
      "Feb",
      "Mar",
      "Apr",
      "May",
      "Jun",
      "Jul",
      "Aug",
      "Sep",
      "Oct",
      "Nov",
      "Dec",
    ];

    return "${months[date.month - 1]} ${date.day}, ${date.year}";
  }

  String formatTime(String dateString) {
    final date = DateTime.parse(dateString).toLocal();

    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');

    return "$hour:$minute";
  }

  Widget _filterChip(String text) {
    final selected = selectedFilter == text;

    return GestureDetector(
      onTap: () => onFilterChanged(text),
      child: Container(
        height: 34,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF7C5CFF) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            text,
            maxLines: 1,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    final hasTrainings = trainings.isNotEmpty;

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        const SizedBox(height: 80),

        Icon(
          hasTrainings ? Icons.search_off : Icons.sports_basketball,
          color: Colors.white24,
          size: 64,
        ),

        const SizedBox(height: 16),

        Text(
          hasTrainings ? "No workouts match" : "No workouts yet",
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 8),

        Text(
          hasTrainings
              ? "Try a different search or filter."
              : "Finish a workout and it will show up here.",
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.white54, fontSize: 14),
        ),
      ],
    );
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
        iconTheme: const IconThemeData(color: Colors.white),

        title: const Text(
          "All Trainings",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            SizedBox(
              height: 60,
              child: TextField(
                controller: searchController,
                onChanged: onSearchChanged,
                style: const TextStyle(color: Colors.white, fontSize: 16),
                decoration: InputDecoration(
                  hintText: "Search workouts...",
                  hintStyle: const TextStyle(color: Colors.white54),
                  prefixIcon: const Icon(Icons.search, color: Colors.white54),
                  filled: true,
                  fillColor: const Color(0xFF1A2238),

                  contentPadding: const EdgeInsets.symmetric(vertical: 18),

                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 14),

            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: const Color(0xFF151D33),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFF7C5CFF).withValues(alpha: 0.15),
                ),
              ),
              child: Row(
                children: [
                  Expanded(child: _filterChip("All")),
                  Expanded(child: _filterChip("This Week")),
                  Expanded(child: _filterChip("This Month")),
                  Expanded(child: _filterChip("This Year")),
                ],
              ),
            ),

            const SizedBox(height: 13),

            Expanded(
              child: RefreshIndicator(
                color: const Color(0xFF7C5CFF),
                backgroundColor: const Color(0xFF1A2238),
                onRefresh: loadTrainings,
                child: filteredTrainings.isEmpty
                    ? _buildEmptyState()
                    : ListView.builder(
                        physics: const AlwaysScrollableScrollPhysics(),
                        itemCount: filteredTrainings.length,
                        itemBuilder: (context, index) {
                          return _buildTrainingCard(filteredTrainings[index]);
                        },
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTrainingCard(dynamic training) {
    final percentage = int.tryParse(training["percentage"].toString()) ?? 0;

    Color percentageColor;

    if (percentage >= 65) {
      percentageColor = Colors.greenAccent;
    } else if (percentage >= 50) {
      percentageColor = Colors.orangeAccent;
    } else {
      percentageColor = Colors.redAccent;
    }

    return Dismissible(
      key: ValueKey(training["training_id"]),
      direction: DismissDirection.endToStart,

      background: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.only(right: 24),
        alignment: Alignment.centerRight,
        decoration: BoxDecoration(
          color: Color(0xFFD32F2F),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.delete_outline, color: Colors.white),
      ),

      confirmDismiss: (_) => confirmDelete(training["training_name"]),

      onDismissed: (_) => deleteTraining(training["training_id"]),

      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => TrainingDetailsScreen(
                trainingId: training["training_id"],
                trainingName: training["training_name"],
              ),
            ),
          );
        },
        child: Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
          decoration: BoxDecoration(
            color: const Color(0xFF1A2238),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white10),
          ),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: const BoxDecoration(
                  color: Color(0xFF252E48),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.sports_basketball,
                  color: Color(0xFF7C5CFF),
                  size: 28,
                ),
              ),

              const SizedBox(width: 14),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      training["training_name"],
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    Text(
                      "${formatDate(training["started_at"])} • ${formatTime(training["started_at"])}",
                      style: const TextStyle(
                        color: Colors.white54,
                        fontSize: 12,
                      ),
                    ),

                    const SizedBox(height: 9),

                    Row(
                      children: [
                        const Icon(
                          Icons.track_changes,
                          color: Color(0xFF7C5CFF),
                          size: 14,
                        ),

                        const SizedBox(width: 4),

                        Text(
                          "${training["total_shots"]} shots",
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),

                        const SizedBox(width: 25),

                        Container(width: 1, height: 14, color: Colors.white12),

                        const SizedBox(width: 25),

                        Icon(
                          percentage >= 55
                              ? Icons.trending_up
                              : percentage >= 50
                              ? Icons.trending_flat
                              : Icons.trending_down,
                          color: percentageColor,
                          size: 16,
                        ),

                        const SizedBox(width: 6),

                        Text(
                          "$percentage%",
                          style: TextStyle(
                            color: percentageColor,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    onPressed: () {
                      // TODO: Favorite workouts
                    },
                    splashRadius: 20,
                    constraints: const BoxConstraints(),
                    padding: EdgeInsets.zero,
                    icon: const Icon(
                      Icons.star_outline_rounded,
                      color: Colors.white38,
                      size: 22,
                    ),
                  ),

                  const SizedBox(width: 10),

                  Container(width: 1, height: 26, color: Colors.white10),

                  const SizedBox(width: 10),

                  const Icon(
                    Icons.arrow_forward_ios,
                    color: Colors.white38,
                    size: 18,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
