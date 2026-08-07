import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../models/preset_position.dart';
import '../../screens/workout_screen.dart';
import '../../services/session.dart';

/// Prikazuje zone predloska i akcije nad njim.
/// Vraca "edit", "duplicate" ili "delete" roditelju, a workout pokrece sam.
class TemplateDetailsSheet extends StatefulWidget {
  final dynamic template;

  const TemplateDetailsSheet({super.key, required this.template});

  @override
  State<TemplateDetailsSheet> createState() => _TemplateDetailsSheetState();
}

class _TemplateDetailsSheetState extends State<TemplateDetailsSheet> {
  List zones = [];

  bool isLoading = true;
  String? loadError;

  @override
  void initState() {
    super.initState();
    loadZones();
  }

  Future<void> loadZones() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("token");

      final templateId = widget.template["template_id"];

      final response = await http.get(
        Uri.parse("http://10.0.2.2:3000/templates/$templateId/zones"),
        headers: {"Authorization": "Bearer $token"},
      );

      if (!mounted) return;

      if (await Session.handleUnauthorized(context, response)) return;

      if (response.statusCode != 200) {
        setState(() {
          isLoading = false;
          loadError = "Could not load template zones.";
        });

        return;
      }

      setState(() {
        zones = jsonDecode(response.body);
        isLoading = false;
        loadError = null;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
        loadError = "Could not load template zones.";
      });
    }
  }

  /// Zone predloska se pretvaraju u pozicije koje koristi WorkoutScreen.
  /// Koordinate dolaze iz baze (0-100), pa se skaliraju na 0-1.
  List<PresetPosition> _toPositions() {
    return zones.map((zone) {
      return PresetPosition(
        name: zone["zone_name"],
        category: "",
        description: "",
        courtX: (zone["x_position"] as num).toDouble() / 100,
        courtY: (zone["y_position"] as num).toDouble() / 100,
        goalShots: zone["planned_shots"],
      );
    }).toList();
  }

  void _startWorkout() {
    final positions = _toPositions();

    if (positions.isEmpty) return;

    // Navigator se dohvaca prije pop-a jer context lista prestaje vrijediti
    final navigator = Navigator.of(context);

    navigator.pop();

    navigator.push(
      MaterialPageRoute(
        builder: (context) => WorkoutScreen(
          positions: positions,
          workoutName: widget.template["template_name"],
          templateId: widget.template["template_id"],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isMine = widget.template["is_mine"] == true;
    final isPublic = widget.template["is_public"] == true;

    return SafeArea(
      child: Container(
        decoration: const BoxDecoration(
          color: Color(0xFF11172F),
          borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
        ),
        padding: const EdgeInsets.fromLTRB(24, 10, 24, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),

            const SizedBox(height: 18),

            Row(
              children: [
                Expanded(
                  child: Text(
                    widget.template["template_name"],
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                if (isMine)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF252E48),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isPublic ? Icons.public : Icons.lock_outline,
                          color: isPublic
                              ? const Color(0xFF00D26A)
                              : Colors.white54,
                          size: 13,
                        ),

                        const SizedBox(width: 5),

                        Text(
                          isPublic ? "Public" : "Private",
                          style: TextStyle(
                            color: isPublic
                                ? const Color(0xFF00D26A)
                                : Colors.white54,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),

            if (!isMine) ...[
              const SizedBox(height: 4),

              Text(
                "by @${widget.template["creator_nickname"] ?? "unknown"}",
                style: const TextStyle(color: Colors.white38, fontSize: 13),
              ),
            ],

            const SizedBox(height: 18),

            if (isLoading)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 40),
                child: Center(
                  child: CircularProgressIndicator(color: Color(0xFF7C5CFF)),
                ),
              )
            else if (loadError != null)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
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
                        loadError!,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                    ),

                    TextButton(
                      onPressed: loadZones,
                      child: const Text(
                        "Retry",
                        style: TextStyle(color: Color(0xFF7C5CFF)),
                      ),
                    ),
                  ],
                ),
              )
            else ...[
              ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 260),
                child: ListView(
                  shrinkWrap: true,
                  children: zones.map<Widget>(_buildZoneRow).toList(),
                ),
              ),

              const SizedBox(height: 18),

              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton.icon(
                  onPressed: zones.isEmpty ? null : _startWorkout,
                  icon: const Icon(Icons.play_arrow, size: 24),
                  label: const Text(
                    "START WORKOUT",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    elevation: 0,
                    backgroundColor: const Color(0xFF7C4DFF),
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: const Color(0xFF121A33),
                    disabledForegroundColor: const Color(0xFF7B83A5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),
            ],

            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: _buildAction(
                    icon: Icons.copy_all_outlined,
                    label: "Duplicate",
                    color: const Color(0xFF7C5CFF),
                    onTap: () => Navigator.pop(context, "duplicate"),
                  ),
                ),

                if (isMine) ...[
                  const SizedBox(width: 10),

                  Expanded(
                    child: _buildAction(
                      icon: Icons.edit_outlined,
                      label: "Edit",
                      color: const Color(0xFF7C5CFF),
                      onTap: () => Navigator.pop(context, "edit"),
                    ),
                  ),

                  const SizedBox(width: 10),

                  Expanded(
                    child: _buildAction(
                      icon: Icons.delete_outline,
                      label: "Delete",
                      color: Colors.redAccent,
                      onTap: () => Navigator.pop(context, "delete"),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildZoneRow(dynamic zone) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF1A2238),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              zone["zone_name"],
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

          Text(
            "${zone["planned_shots"]} shots",
            style: const TextStyle(
              color: Color(0xFF7C5CFF),
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAction({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFF1A2238),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white10),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 20),

            const SizedBox(height: 6),

            Text(
              label,
              style: TextStyle(color: color, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}
