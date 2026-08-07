import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../widgets/bottom_sheets/template_details_sheet.dart';
import 'template_editor_screen.dart';

class TemplatesScreen extends StatefulWidget {
  const TemplatesScreen({super.key});

  @override
  State<TemplatesScreen> createState() => _TemplatesScreenState();
}

class _TemplatesScreenState extends State<TemplatesScreen> {
  List templates = [];

  bool isLoading = true;
  String? loadError;

  bool showMine = true;

  @override
  void initState() {
    super.initState();
    loadTemplates();
  }

  Future<void> loadTemplates() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("token");

      final response = await http.get(
        Uri.parse("http://10.0.2.2:3000/templates"),
        headers: {"Authorization": "Bearer $token"},
      );

      if (!mounted) return;

      if (response.statusCode != 200) {
        setState(() {
          isLoading = false;
          loadError = "Could not load templates.";
        });

        return;
      }

      setState(() {
        templates = jsonDecode(response.body);
        isLoading = false;
        loadError = null;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
        loadError = "Could not load templates.";
      });
    }
  }

  List get visibleTemplates {
    return templates.where((template) {
      final isMine = template["is_mine"] == true;

      return showMine ? isMine : !isMine;
    }).toList();
  }

  void _showMessage(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError
            ? Colors.red.shade700
            : const Color(0xFF00D26A),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> duplicateTemplate(int templateId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("token");

      final response = await http.post(
        Uri.parse("http://10.0.2.2:3000/templates/$templateId/duplicate"),
        headers: {"Authorization": "Bearer $token"},
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        _showMessage("Template duplicated");

        setState(() {
          showMine = true;
        });

        await loadTemplates();
      } else {
        _showMessage("Could not duplicate template.", isError: true);
      }
    } catch (e) {
      if (!mounted) return;

      _showMessage("Could not duplicate template.", isError: true);
    }
  }

  Future<void> deleteTemplate(int templateId, String templateName) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A2238),

        title: const Text(
          "Delete template?",
          style: TextStyle(color: Colors.white),
        ),

        content: Text(
          "\"$templateName\" will be permanently deleted. Workouts you already finished are not affected.",
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

    if (confirmed != true) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("token");

      final response = await http.delete(
        Uri.parse("http://10.0.2.2:3000/templates/$templateId"),
        headers: {"Authorization": "Bearer $token"},
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        setState(() {
          templates.removeWhere(
            (template) => template["template_id"] == templateId,
          );
        });

        _showMessage("Template deleted");
      } else {
        _showMessage("Could not delete template.", isError: true);
      }
    } catch (e) {
      if (!mounted) return;

      _showMessage("Could not delete template.", isError: true);
    }
  }

  Future<void> openEditor({dynamic template}) async {
    final saved = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => TemplateEditorScreen(template: template),
      ),
    );

    if (saved == true) {
      await loadTemplates();
    }
  }

  Future<void> openTemplate(dynamic template) async {
    final action = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => TemplateDetailsSheet(template: template),
    );

    if (!mounted || action == null) return;

    switch (action) {
      case "edit":
        await openEditor(template: template);
        break;

      case "duplicate":
        await duplicateTemplate(template["template_id"]);
        break;

      case "delete":
        await deleteTemplate(
          template["template_id"],
          template["template_name"],
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1224),

      appBar: AppBar(
        backgroundColor: const Color(0xFF0D1224),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          "Templates",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),

      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFF7C4DFF),
        foregroundColor: Colors.white,
        onPressed: () => openEditor(),
        icon: const Icon(Icons.add),
        label: const Text(
          "New Template",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),

      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF7C5CFF)),
            )
          : Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 0),
              child: Column(
                children: [
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
                        Expanded(child: _buildTab("My Templates", true)),
                        Expanded(child: _buildTab("Public", false)),
                      ],
                    ),
                  ),

                  const SizedBox(height: 14),

                  Expanded(
                    child: RefreshIndicator(
                      color: const Color(0xFF7C5CFF),
                      backgroundColor: const Color(0xFF1A2238),
                      onRefresh: loadTemplates,
                      child: loadError != null
                          ? _buildErrorState()
                          : visibleTemplates.isEmpty
                          ? _buildEmptyState()
                          : ListView.builder(
                              physics: const AlwaysScrollableScrollPhysics(),
                              padding: const EdgeInsets.only(bottom: 90),
                              itemCount: visibleTemplates.length,
                              itemBuilder: (context, index) {
                                return _buildTemplateCard(
                                  visibleTemplates[index],
                                );
                              },
                            ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildTab(String label, bool mine) {
    final selected = showMine == mine;

    return GestureDetector(
      onTap: () {
        setState(() {
          showMine = mine;
        });
      },
      child: Container(
        height: 34,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF7C5CFF) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        const SizedBox(height: 80),

        const Icon(Icons.error_outline, color: Colors.redAccent, size: 56),

        const SizedBox(height: 16),

        Text(
          loadError!,
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.white70, fontSize: 15),
        ),

        const SizedBox(height: 12),

        Center(
          child: TextButton(
            onPressed: loadTemplates,
            child: const Text(
              "Retry",
              style: TextStyle(
                color: Color(0xFF7C5CFF),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        const SizedBox(height: 80),

        Icon(
          showMine ? Icons.description_outlined : Icons.public_off,
          color: Colors.white24,
          size: 64,
        ),

        const SizedBox(height: 16),

        Text(
          showMine ? "No templates yet" : "No public templates",
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 8),

        Text(
          showMine
              ? "Create a template to reuse the same\nworkout again and again."
              : "Templates other players share\npublicly will appear here.",
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.white54,
            fontSize: 14,
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildTemplateCard(dynamic template) {
    final zoneCount = template["zone_count"] ?? 0;
    final isPublic = template["is_public"] == true;
    final isMine = template["is_mine"] == true;

    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () => openTemplate(template),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
                Icons.description_outlined,
                color: Color(0xFF7C5CFF),
                size: 24,
              ),
            ),

            const SizedBox(width: 14),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    template["template_name"],
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  const SizedBox(height: 6),

                  Row(
                    children: [
                      const Icon(
                        Icons.place_outlined,
                        color: Color(0xFF7C5CFF),
                        size: 14,
                      ),

                      const SizedBox(width: 4),

                      Text(
                        "$zoneCount ${zoneCount == 1 ? "zone" : "zones"}",
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),

                      const SizedBox(width: 14),

                      const Icon(
                        Icons.sports_basketball_outlined,
                        color: Color(0xFF7C5CFF),
                        size: 14,
                      ),

                      const SizedBox(width: 4),

                      Text(
                        "${template["total_shots"]} shots",
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),

                  if (!isMine) ...[
                    const SizedBox(height: 6),

                    Text(
                      "by @${template["creator_nickname"] ?? "unknown"}",
                      style: const TextStyle(
                        color: Colors.white38,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ],
              ),
            ),

            if (isMine)
              Icon(
                isPublic ? Icons.public : Icons.lock_outline,
                color: isPublic ? const Color(0xFF00D26A) : Colors.white38,
                size: 18,
              ),

            const SizedBox(width: 10),

            const Icon(
              Icons.arrow_forward_ios,
              color: Colors.white38,
              size: 18,
            ),
          ],
        ),
      ),
    );
  }
}
