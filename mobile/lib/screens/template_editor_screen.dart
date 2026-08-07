import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

/// Kreiranje i uredivanje predloska.
/// Ako je [template] proslijeden, ekran radi u nacinu uredivanja.
class TemplateEditorScreen extends StatefulWidget {
  final dynamic template;

  const TemplateEditorScreen({super.key, this.template});

  @override
  State<TemplateEditorScreen> createState() => _TemplateEditorScreenState();
}

class _TemplateEditorScreenState extends State<TemplateEditorScreen> {
  final nameController = TextEditingController();

  bool isPublic = false;

  List zones = [];

  /// zone_id -> planirani broj sutova
  final Map<int, int> selectedZones = {};

  bool isLoading = true;
  bool isSaving = false;
  String? loadError;

  bool get isEditing => widget.template != null;

  @override
  void initState() {
    super.initState();

    if (isEditing) {
      nameController.text = widget.template["template_name"] ?? "";
      isPublic = widget.template["is_public"] == true;
    }

    loadData();
  }

  @override
  void dispose() {
    nameController.dispose();
    super.dispose();
  }

  Future<void> loadData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("token");

      final headers = {"Authorization": "Bearer $token"};

      final zonesResponse = await http.get(
        Uri.parse("http://10.0.2.2:3000/zones"),
        headers: headers,
      );

      if (!mounted) return;

      if (zonesResponse.statusCode != 200) {
        setState(() {
          isLoading = false;
          loadError = "Could not load zones.";
        });

        return;
      }

      final loadedZones = jsonDecode(zonesResponse.body);

      // Kod uredivanja dohvati postojece zone predloska
      if (isEditing) {
        final templateId = widget.template["template_id"];

        final templateZones = await http.get(
          Uri.parse("http://10.0.2.2:3000/templates/$templateId/zones"),
          headers: headers,
        );

        if (!mounted) return;

        if (templateZones.statusCode == 200) {
          for (final zone in jsonDecode(templateZones.body)) {
            selectedZones[zone["zone_id"]] = zone["planned_shots"];
          }
        }
      }

      setState(() {
        zones = loadedZones;
        isLoading = false;
        loadError = null;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
        loadError = "Could not load zones.";
      });
    }
  }

  int get totalShots {
    return selectedZones.values.fold(0, (total, shots) => total + shots);
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red.shade700,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> saveTemplate() async {
    if (isSaving) return;

    final name = nameController.text.trim();

    if (name.isEmpty) {
      _showError("Enter a template name.");
      return;
    }

    if (selectedZones.isEmpty) {
      _showError("Select at least one zone.");
      return;
    }

    setState(() => isSaving = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("token");

      final body = jsonEncode({
        "template_name": name,
        "is_public": isPublic,
        "zones": selectedZones.entries
            .map(
              (entry) => {
                "zone_id": entry.key,
                "planned_shots": entry.value,
              },
            )
            .toList(),
      });

      final headers = {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      };

      final response = isEditing
          ? await http.put(
              Uri.parse(
                "http://10.0.2.2:3000/templates/${widget.template["template_id"]}",
              ),
              headers: headers,
              body: body,
            )
          : await http.post(
              Uri.parse("http://10.0.2.2:3000/templates"),
              headers: headers,
              body: body,
            );

      if (!mounted) return;

      if (response.statusCode != 200) {
        setState(() => isSaving = false);

        _showError(
          response.body.isNotEmpty
              ? response.body
              : "Could not save template.",
        );

        return;
      }

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;

      setState(() => isSaving = false);

      _showError("Could not save template. Check your connection.");
    }
  }

  void _toggleZone(int zoneId) {
    setState(() {
      if (selectedZones.containsKey(zoneId)) {
        selectedZones.remove(zoneId);
      } else {
        selectedZones[zoneId] = 10;
      }
    });
  }

  void _setPlannedShots(int zoneId, String value) {
    final parsed = int.tryParse(value) ?? 0;

    setState(() {
      selectedZones[zoneId] = parsed;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1224),

      appBar: AppBar(
        backgroundColor: const Color(0xFF0D1224),
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          isEditing ? "Edit Template" : "New Template",
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF7C5CFF)),
            )
          : loadError != null
          ? _buildErrorState()
          : Column(
              children: [
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                    children: [
                      const Text(
                        "Template name",
                        style: TextStyle(
                          color: Color(0xFF8B94B8),
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                          letterSpacing: 1.2,
                        ),
                      ),

                      const SizedBox(height: 10),

                      TextField(
                        controller: nameController,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: "e.g. Corner Threes",
                          hintStyle: const TextStyle(color: Colors.white38),
                          filled: true,
                          fillColor: const Color(0xFF1A2238),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 18,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),

                      const SizedBox(height: 18),

                      _buildVisibilityTile(),

                      const SizedBox(height: 24),

                      Row(
                        children: [
                          const Text(
                            "Zones",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          const Spacer(),

                          Text(
                            "${selectedZones.length} selected • $totalShots shots",
                            style: const TextStyle(
                              color: Colors.white54,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      ...zones.map(_buildZoneRow),
                    ],
                  ),
                ),

                _buildSaveBar(),
              ],
            ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, color: Colors.redAccent, size: 56),

            const SizedBox(height: 16),

            Text(
              loadError!,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white70, fontSize: 15),
            ),

            const SizedBox(height: 12),

            TextButton(
              onPressed: () {
                setState(() {
                  isLoading = true;
                  loadError = null;
                });

                loadData();
              },
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
      ),
    );
  }

  Widget _buildVisibilityTile() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A2238),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Public template",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  isPublic
                      ? "Other players can find and copy this template."
                      : "Only you can see this template.",
                  style: const TextStyle(
                    color: Colors.white54,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 12),

          Switch(
            value: isPublic,
            onChanged: (value) {
              setState(() {
                isPublic = value;
              });
            },
            activeThumbColor: const Color(0xFF7C5CFF),
          ),
        ],
      ),
    );
  }

  Widget _buildZoneRow(dynamic zone) {
    final zoneId = zone["zone_id"] as int;
    final selected = selectedZones.containsKey(zoneId);

    final plannedShots = selectedZones[zoneId] ?? 0;
    final isInvalid = selected && plannedShots <= 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: selected ? const Color(0xFF2B2255) : const Color(0xFF1A2238),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isInvalid
              ? Colors.redAccent
              : selected
              ? const Color(0xFF7C5CFF)
              : Colors.white10,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: InkWell(
              onTap: () => _toggleZone(zoneId),
              child: Row(
                children: [
                  Icon(
                    selected
                        ? Icons.check_circle_rounded
                        : Icons.radio_button_unchecked,
                    color: selected
                        ? const Color(0xFF7C5CFF)
                        : Colors.white24,
                    size: 22,
                  ),

                  const SizedBox(width: 12),

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
                ],
              ),
            ),
          ),

          if (selected)
            SizedBox(
              width: 74,
              child: TextField(
                key: ValueKey("shots_$zoneId"),
                controller: TextEditingController(text: "$plannedShots")
                  ..selection = TextSelection.collapsed(
                    offset: "$plannedShots".length,
                  ),
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                maxLength: 3,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                onChanged: (value) => _setPlannedShots(zoneId, value),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
                decoration: InputDecoration(
                  counterText: "",
                  isDense: true,
                  filled: true,
                  fillColor: const Color(0xFF141C31),
                  contentPadding: const EdgeInsets.symmetric(vertical: 10),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSaveBar() {
    final hasInvalidZone = selectedZones.values.any((shots) => shots <= 0);

    return Container(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
      decoration: const BoxDecoration(
        color: Color(0xFF0D1224),
        border: Border(top: BorderSide(color: Color(0xFF1F2937))),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (hasInvalidZone) ...[
            const Row(
              children: [
                Icon(Icons.error_outline, color: Colors.redAccent, size: 18),

                SizedBox(width: 8),

                Expanded(
                  child: Text(
                    "Every selected zone needs at least 1 shot.",
                    style: TextStyle(color: Colors.redAccent, fontSize: 13),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),
          ],

          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: (isSaving || hasInvalidZone) ? null : saveTemplate,
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
              child: isSaving
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : Text(
                      isEditing ? "SAVE CHANGES" : "CREATE TEMPLATE",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
