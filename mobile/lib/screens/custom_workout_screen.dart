import 'package:flutter/material.dart';

import 'preset_positions_screen.dart';
import '../models/preset_position.dart';
import '../widgets/cards/position_card.dart';
import '../widgets/bottom_sheets/position_info_sheet.dart';
import '../widgets/court/basketball_court.dart';
import 'workout_screen.dart';

class CustomWorkoutScreen extends StatefulWidget {
  const CustomWorkoutScreen({super.key});

  @override
  State<CustomWorkoutScreen> createState() => _CustomWorkoutScreenState();
}

class _CustomWorkoutScreenState extends State<CustomWorkoutScreen> {
  final TextEditingController workoutNameController = TextEditingController();

  final List<PresetPosition> selectedPresetPositions = [];

  bool isListView = true;
  bool hasUnsavedChanges = false;

  @override
  void initState() {
    super.initState();

    workoutNameController.addListener(() {
      if (!hasUnsavedChanges) {
        setState(() {
          hasUnsavedChanges = true;
        });
      }
    });
  }

  @override
  void dispose() {
    workoutNameController.dispose();
    super.dispose();
  }

  void showAddPositionSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A2238),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),

                const SizedBox(height: 24),

                const Text(
                  "Add Position",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 24),

                ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: Color(0xFF7C4DFF),
                    child: Icon(Icons.place_outlined, color: Colors.white),
                  ),
                  title: const Text(
                    "Preset Position",
                    style: TextStyle(color: Colors.white),
                  ),
                  subtitle: const Text(
                    "Choose from predefined shooting positions.",
                    style: TextStyle(color: Colors.white60),
                  ),
                  trailing: const Icon(
                    Icons.chevron_right,
                    color: Colors.white38,
                  ),
                  onTap: () async {
                    Navigator.pop(context);

                    final result = await Navigator.push<List<PresetPosition>>(
                      context,
                      MaterialPageRoute(
                        builder: (_) => PresetPositionsScreen(
                          initiallySelected: selectedPresetPositions,
                        ),
                      ),
                    );

                    if (result != null) {
                      setState(() {
                        selectedPresetPositions
                          ..clear()
                          ..addAll(result);

                        hasUnsavedChanges = true;
                      });
                    }
                  },
                ),

                const SizedBox(height: 8),

                ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: Color(0xFF7C4DFF),
                    child: Icon(Icons.touch_app_outlined, color: Colors.white),
                  ),
                  title: const Text(
                    "Custom Position",
                    style: TextStyle(color: Colors.white),
                  ),
                  subtitle: const Text(
                    "Place a custom position anywhere on the court.",
                    style: TextStyle(color: Colors.white60),
                  ),
                  trailing: const Icon(
                    Icons.chevron_right,
                    color: Colors.white38,
                  ),
                  onTap: () {
                    Navigator.pop(context);

                    // TODO: CustomCourtScreen
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: const Color(0xFF7C4DFF).withValues(alpha: 0.15),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.assignment_outlined,
            color: Color(0xFF7C4DFF),
            size: 42,
          ),
        ),

        const SizedBox(height: 24),

        const Text(
          "No positions yet",
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 12),

        const Text(
          "Add your first shooting position\nto build your workout.",
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white60, fontSize: 15, height: 1.5),
        ),

        const SizedBox(height: 30),

        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: showAddPositionSheet,
            icon: const Icon(Icons.add),
            label: const Text(
              "Add Position",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            style: ElevatedButton.styleFrom(
              elevation: 0,
              backgroundColor: const Color(0xFF7C4DFF),
              foregroundColor: Colors.white,
              minimumSize: const Size.fromHeight(56),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPositionList() {
    return Column(
      children: [
        Expanded(
          child: ReorderableListView.builder(
            itemCount: selectedPresetPositions.length,
            buildDefaultDragHandles: false,

            proxyDecorator: (child, index, animation) {
              return AnimatedBuilder(
                animation: animation,
                builder: (context, _) {
                  final scale = 1.0 + (animation.value * 0.03);

                  return Transform.scale(
                    scale: scale,
                    child: Material(
                      color: Colors.transparent,
                      elevation: 12,
                      shadowColor: Colors.black54,
                      borderRadius: BorderRadius.circular(16),
                      child: child,
                    ),
                  );
                },
              );
            },

            onReorderItem: (oldIndex, newIndex) {
              setState(() {
                if (newIndex > oldIndex) {
                  newIndex--;
                }

                final item = selectedPresetPositions.removeAt(oldIndex);
                selectedPresetPositions.insert(newIndex, item);

                hasUnsavedChanges = true;
              });
            },

            itemBuilder: (context, index) {
              final position = selectedPresetPositions[index];

              return Padding(
                key: ValueKey(position.name),
                padding: const EdgeInsets.only(bottom: 12),
                child: PositionCard(
                  position: position,
                  index: index,

                  onSettingsPressed: () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: const Color(0xFF1A2238),
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(28),
                        ),
                      ),
                      builder: (_) => PositionInfoSheet(position: position),
                    );
                  },

                  onDeletePressed: () {
                    setState(() {
                      selectedPresetPositions.removeAt(index);
                      hasUnsavedChanges = true;
                    });
                  },
                ),
              );
            },
          ),
        ),

        const SizedBox(height: 16),

        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: showAddPositionSheet,

            icon: const Icon(Icons.add),

            label: const Text(
              "Add Position",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),

            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF7C4DFF),

              side: const BorderSide(color: Color(0xFF7C4DFF)),

              minimumSize: const Size.fromHeight(54),

              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<bool> _confirmDiscardChanges() async {
    if (!hasUnsavedChanges) return true;

    final discard = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A2238),

        title: const Text(
          "Discard changes?",
          style: TextStyle(color: Colors.white),
        ),

        content: const Text(
          "You have unsaved changes.",
          style: TextStyle(color: Colors.white70),
        ),

        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Continue editing"),
          ),

          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              "Discard",
              style: TextStyle(color: Colors.redAccent),
            ),
          ),
        ],
      ),
    );

    return discard ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !hasUnsavedChanges,

      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;

        final shouldPop = await _confirmDiscardChanges();

        if (shouldPop && context.mounted) {
          Navigator.pop(context);
        }
      },

      child: Scaffold(
        backgroundColor: const Color(0xFF090E1F),

        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          title: const Text(
            'Custom Workout',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          iconTheme: const IconThemeData(color: Colors.white),
        ),

        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Workout name (optional)',
                  style: TextStyle(
                    color: Color(0xFF8B94B8),
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                    letterSpacing: 1.2,
                  ),
                ),

                const SizedBox(height: 10),

                TextField(
                  controller: workoutNameController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 18,
                    ),
                    hintText: "e.g. Morning Shooting",
                    hintStyle: const TextStyle(color: Colors.white38),

                    suffixIcon: const Icon(
                      Icons.edit_outlined,
                      color: Color(0xFF7C4DFF),
                    ),

                    filled: true,
                    fillColor: const Color(0xFF1A2238),

                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),

                const SizedBox(height: 22),

                Container(
                  height: 60,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A2238),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final segmentWidth = (constraints.maxWidth - 8) / 2;

                      return Stack(
                        children: [
                          AnimatedPositioned(
                            duration: const Duration(milliseconds: 220),
                            curve: Curves.easeInOut,
                            left: isListView ? 4 : segmentWidth + 4,
                            top: 4,
                            child: Container(
                              width: segmentWidth,
                              height: 52,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(14),
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFF6D3EFF),
                                    Color(0xFF8A4DFF),
                                  ],
                                ),
                              ),
                            ),
                          ),

                          Row(
                            children: [
                              Expanded(
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(18),
                                  onTap: () {
                                    setState(() {
                                      isListView = true;
                                    });
                                  },
                                  child: SizedBox(
                                    height: 60,
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.view_list_rounded,
                                          color: Colors.white,
                                          size: 22,
                                        ),

                                        const SizedBox(width: 8),

                                        const Text(
                                          "LIST",
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w700,
                                            letterSpacing: 0.8,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),

                              Expanded(
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(18),
                                  onTap: () {
                                    setState(() {
                                      isListView = false;
                                    });
                                  },
                                  child: SizedBox(
                                    height: 60,
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.grid_view_rounded,
                                          color: Colors.white,
                                          size: 22,
                                        ),

                                        const SizedBox(width: 8),

                                        const Text(
                                          "COURT",
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w700,
                                            letterSpacing: 0.8,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      );
                    },
                  ),
                ),

                const SizedBox(height: 20),

                Expanded(
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: const Color(0xFF10192E),
                      borderRadius: BorderRadius.circular(20), //border
                      border: Border.all(color: const Color(0xFF2A3661)),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: isListView
                          ? (selectedPresetPositions.isEmpty
                                ? _buildEmptyState()
                                : _buildPositionList())
                          : BasketballCourt(positions: selectedPresetPositions),
                    ),
                  ),
                ),

                const SizedBox(height: 18),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: selectedPresetPositions.isEmpty
                        ? null
                        : () {
                            Navigator.push(
                              context,

                              MaterialPageRoute(
                                builder: (_) => WorkoutScreen(
                                  positions: selectedPresetPositions,
                                  workoutName: workoutNameController.text
                                      .trim(),
                                ),
                              ),
                            );
                          },

                    icon: const Icon(Icons.play_arrow, size: 24),

                    label: const Text(
                      'START WORKOUT',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 17,
                      ),
                    ),

                    style: ElevatedButton.styleFrom(
                      elevation: 0,
                      backgroundColor: const Color(0xFF7C4DFF),
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: const Color(0xFF121A33),
                      disabledForegroundColor: const Color(0xFF7B83A5),
                      minimumSize: const Size.fromHeight(58),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ),

                if (selectedPresetPositions.isEmpty) ...[
                  const SizedBox(height: 10),

                  const Center(
                    child: Text(
                      "Add at least one position to start.",
                      style: TextStyle(color: Colors.white38),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
