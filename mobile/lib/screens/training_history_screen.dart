import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class TrainingHistoryScreen extends StatefulWidget {
  const TrainingHistoryScreen({super.key});

  @override
  State<TrainingHistoryScreen> createState() => _TrainingHistoryScreenState();
}

class _TrainingHistoryScreenState extends State<TrainingHistoryScreen> {
  List trainings = [];

  List filteredTrainings = [];
  String selectedFilter = "All";

  final TextEditingController searchController = TextEditingController();

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadTrainings();
  }

  Future<void> loadTrainings() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final token = prefs.getString("token");

      final response = await http.get(
        Uri.parse("http://10.0.2.2:3000/all-trainings"),
        headers: {"Authorization": "Bearer $token"},
      );

      if (response.statusCode == 200) {
        setState(() {
          trainings = jsonDecode(response.body);
          filteredTrainings = trainings;
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

  void filterTrainings(String query) {
    setState(() {
      filteredTrainings = trainings.where((training) {
        return training["training_name"].toString().toLowerCase().contains(
          query.toLowerCase(),
        );
      }).toList();
    });
  }

  void applyFilter(String filter) {
    setState(() {
      selectedFilter = filter;

      final now = DateTime.now();

      filteredTrainings = trainings.where((training) {
        final date = DateTime.parse(training["started_at"]);

        switch (filter) {
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

  String formatDate(String dateString) {
    final date = DateTime.parse(dateString);

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
    final date = DateTime.parse(dateString);

    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');

    return "$hour:$minute";
  }

  Widget _filterChip(String text) {
    final selected = selectedFilter == text;

    return GestureDetector(
      onTap: () => applyFilter(text),
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

        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: const Color(0xFF1A2238),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFF7C5CFF).withValues(alpha: 0.3),
                ),
              ),
              child: const Icon(
                Icons.filter_alt_outlined,
                color: Color(0xFFB026FF),
                size: 24,
              ),
            ),
          ),
        ],
      ),

      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            SizedBox(
              height: 60,
              child: TextField(
                controller: searchController,
                onChanged: filterTrainings,
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
              child: ListView.builder(
                physics: const ClampingScrollPhysics(),
                itemCount: filteredTrainings.length,
                itemBuilder: (context, index) {
                  final training = filteredTrainings[index];

                  final percentage =
                      int.tryParse(training["percentage"].toString()) ?? 0;

                  Color percentageColor;

                  if (percentage >= 65) {
                    percentageColor = Colors.greenAccent;
                  } else if (percentage >= 50) {
                    percentageColor = Colors.orangeAccent;
                  } else {
                    percentageColor = Colors.redAccent;
                  }

                  return Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 11,
                    ),
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

                                  Container(
                                    width: 1,
                                    height: 14,
                                    color: Colors.white12,
                                  ),

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

                        const Icon(
                          Icons.arrow_forward_ios,
                          color: Colors.white38,
                          size: 16,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
