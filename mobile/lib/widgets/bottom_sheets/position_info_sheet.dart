import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../models/preset_position.dart';
import '../../services/session.dart';
import '../court/basketball_court.dart';

/// Prikazuje poziciju na terenu i stvarnu statistiku korisnika za tu zonu.
/// Zone se povezuju preko naziva (zones.zone_name odgovara nazivu pozicije).
class PositionInfoSheet extends StatefulWidget {
  final PresetPosition position;

  const PositionInfoSheet({super.key, required this.position});

  @override
  State<PositionInfoSheet> createState() => _PositionInfoSheetState();
}

class _PositionInfoSheetState extends State<PositionInfoSheet> {
  bool isLoading = true;
  bool hasError = false;

  Map<String, dynamic>? zoneStats;

  @override
  void initState() {
    super.initState();
    loadZoneStats();
  }

  Future<void> loadZoneStats() async {
    setState(() {
      isLoading = true;
      hasError = false;
    });

    try {
      final response = await http.get(
        Uri.parse("${Session.baseUrl}/my-zone-stats"),
        headers: await Session.headers(),
      );

      if (!mounted) return;

      if (response.statusCode != 200) {
        setState(() {
          isLoading = false;
          hasError = true;
        });

        return;
      }

      final zones = jsonDecode(response.body)["zones"] as List;

      Map<String, dynamic>? match;

      for (final zone in zones) {
        if (zone["zone_name"] == widget.position.name) {
          match = Map<String, dynamic>.from(zone);
          break;
        }
      }

      setState(() {
        zoneStats = match;
        isLoading = false;
        hasError = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
        hasError = true;
      });
    }
  }

  Color _percentageColor(int value) {
    if (value >= 65) return const Color(0xFF00D26A);
    if (value >= 50) return Colors.orangeAccent;

    return Colors.redAccent;
  }

  Widget _statRow(String title, String value, {Color? valueColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(color: Colors.white60, fontSize: 14),
        ),
        Text(
          value,
          style: TextStyle(
            color: valueColor ?? Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 15,
          ),
        ),
      ],
    );
  }

  Widget _buildStats() {
    if (isLoading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: Center(
          child: CircularProgressIndicator(color: Color(0xFF7C5CFF)),
        ),
      );
    }

    if (hasError) {
      return Row(
        children: [
          const Icon(Icons.error_outline, color: Colors.redAccent, size: 20),

          const SizedBox(width: 10),

          const Expanded(
            child: Text(
              "Could not load your statistics.",
              style: TextStyle(color: Colors.white70, fontSize: 14),
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
      );
    }

    if (zoneStats == null) {
      return const Text(
        "You have not taken any shots from this position yet.",
        style: TextStyle(color: Colors.white54, fontSize: 14, height: 1.5),
      );
    }

    final percentage = zoneStats!["percentage"] as int;

    return Column(
      children: [
        _statRow(
          "FG%",
          "$percentage%",
          valueColor: _percentageColor(percentage),
        ),

        const SizedBox(height: 14),

        _statRow("Shots", "${zoneStats!["total_shots"]}"),

        const SizedBox(height: 14),

        _statRow("Makes", "${zoneStats!["made_shots"]}"),

        const SizedBox(height: 14),

        _statRow("Misses", "${zoneStats!["missed_shots"]}"),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),

            const SizedBox(height: 24),

            Text(
              widget.position.name,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: const Color(0xFF252E48),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                widget.position.category,
                style: const TextStyle(
                  color: Color(0xFFB99CFF),
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(height: 24),

            const Text(
              "Court Position",
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 12),

            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF10192E),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: const Color(0xFF2A3661)),
              ),
              child: BasketballCourt(
                positions: [widget.position],
                selectedPosition: widget.position,
                interactive: false,
              ),
            ),

            const SizedBox(height: 24),

            const Text(
              "Your Statistics",
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 12),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: const Color(0xFF151D33),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
              ),
              child: _buildStats(),
            ),

            if (widget.position.description.isNotEmpty) ...[
              const SizedBox(height: 24),

              const Text(
                "Description",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 14),

              Text(
                widget.position.description,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 15,
                  height: 1.7,
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
