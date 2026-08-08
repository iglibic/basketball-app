import 'package:flutter/material.dart';

import '../models/preset_position.dart';
import '../widgets/bottom_sheets/position_info_sheet.dart';

class PresetPositionsScreen extends StatefulWidget {
  final List<PresetPosition> initiallySelected;

  const PresetPositionsScreen({super.key, required this.initiallySelected});

  @override
  State<PresetPositionsScreen> createState() => _PresetPositionsScreenState();
}

class _PresetPositionsScreenState extends State<PresetPositionsScreen> {
  final searchController = TextEditingController();

  String selectedCategory = "All";
  String selectedSort = "Court Order";

  final Set<String> selectedPositions = {};

  @override
  void initState() {
    super.initState();

    selectedPositions.addAll(widget.initiallySelected.map((e) => e.name));

    searchController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  /// courtX / courtY su frakcije (0..1) slike terena assets/court/half_court.png.
  /// Slika je landscape (3:2), kos je gore na sredini, a centarska linija dolje.
  final List<PresetPosition> positions = [
    // 3PT
    PresetPosition(
      name: "Left Corner 3",
      category: "3PT",
      description: "Three-point shot from the left corner, along the baseline.",
      courtX: 0.15,
      courtY: 0.11,
    ),

    PresetPosition(
      name: "Right Corner 3",
      category: "3PT",
      description: "Three-point shot from the right corner, along the baseline.",
      courtX: 0.85,
      courtY: 0.11,
    ),

    PresetPosition(
      name: "Left Wing 3",
      category: "3PT",
      description: "Three-point shot from the left wing, above the break.",
      courtX: 0.23,
      courtY: 0.52,
    ),

    PresetPosition(
      name: "Right Wing 3",
      category: "3PT",
      description: "Three-point shot from the right wing, above the break.",
      courtX: 0.77,
      courtY: 0.52,
    ),

    PresetPosition(
      name: "Top of the Key",
      category: "3PT",
      description: "Three-point shot straight on, at the top of the arc.",
      courtX: 0.50,
      courtY: 0.74,
    ),

    // Mid Range
    PresetPosition(
      name: "Left Elbow",
      category: "Mid",
      description: "Midrange shot from the left corner of the free throw line.",
      courtX: 0.36,
      courtY: 0.51,
    ),

    PresetPosition(
      name: "Right Elbow",
      category: "Mid",
      description: "Midrange shot from the right corner of the free throw line.",
      courtX: 0.64,
      courtY: 0.51,
    ),

    PresetPosition(
      name: "Left Baseline",
      category: "Mid",
      description: "Midrange shot from the left baseline, outside the paint.",
      courtX: 0.24,
      courtY: 0.13,
    ),

    PresetPosition(
      name: "Right Baseline",
      category: "Mid",
      description: "Midrange shot from the right baseline, outside the paint.",
      courtX: 0.76,
      courtY: 0.13,
    ),

    PresetPosition(
      name: "Nail",
      category: "Mid",
      description: "Midrange shot from just behind the free throw line.",
      courtX: 0.50,
      courtY: 0.63,
    ),

    // Paint
    PresetPosition(
      name: "Left Block",
      category: "Paint",
      description: "Close range shot from the left low post block.",
      courtX: 0.385,
      courtY: 0.21,
    ),

    PresetPosition(
      name: "Right Block",
      category: "Paint",
      description: "Close range shot from the right low post block.",
      courtX: 0.615,
      courtY: 0.21,
    ),

    PresetPosition(
      name: "Restricted Area",
      category: "Paint",
      description: "Finish at the rim, inside the restricted area.",
      courtX: 0.50,
      courtY: 0.17,
    ),

    // FT
    PresetPosition(
      name: "Free Throw",
      category: "FT",
      description: "Free throw from the line.",
      courtX: 0.50,
      courtY: 0.53,
    ),

    // Other
    PresetPosition(
      name: "Half Court",
      category: "Other",
      description: "Long range shot from around the half court line.",
      courtX: 0.50,
      courtY: 0.91,
    ),
  ];

  List<PresetPosition> get filteredPositions {
    final filtered = positions.where((position) {
      final matchesCategory =
          selectedCategory == "All" || position.category == selectedCategory;

      final matchesSearch = position.name.toLowerCase().contains(
        searchController.text.toLowerCase(),
      );

      return matchesCategory && matchesSearch;
    }).toList();

    if (selectedSort == "Name (A-Z)") {
      filtered.sort((a, b) => a.name.compareTo(b.name));
    }

    if (selectedSort == "Category") {
      filtered.sort((a, b) => a.category.compareTo(b.category));
    }

    return filtered;
  }

  Widget _categoryChip(String text) {
    final selected = selectedCategory == text;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedCategory = text;
        });
      },
      child: Container(
        height: 34,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF7C5CFF) : Colors.transparent,
          borderRadius: BorderRadius.circular(18),
        ),
        child: FittedBox(
          child: Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1224),

      appBar: AppBar(
        backgroundColor: Colors.transparent,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "Preset Positions",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Colors.white),

        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 24),
            child: PopupMenuButton<String>(
              position: PopupMenuPosition.under,
              offset: const Offset(0, 2),
              tooltip: "Sort",
              color: const Color(0xFF1A2238),

              onSelected: (value) {
                setState(() {
                  selectedSort = value;
                });
              },

              itemBuilder: (context) {
                // Ponudeno je samo ono sto se stvarno moze poredati
                // s podacima koje ovaj ekran ima.
                final options = ["Court Order", "Name (A-Z)", "Category"];

                return options.map((option) {
                  return PopupMenuItem<String>(
                    value: option,
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            option,
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),

                        if (selectedSort == option)
                          const Icon(
                            Icons.check,
                            color: Color(0xFF7C5CFF),
                            size: 20,
                          ),
                      ],
                    ),
                  );
                }).toList();
              },

              child: Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: const Color(0xFF1A2238),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFF7C5CFF).withValues(alpha: 0.30),
                  ),
                ),
                child: const Icon(
                  Icons.swap_vert_rounded,
                  color: Color(0xFF7C5CFF),
                  size: 24,
                ),
              ),
            ),
          ),
        ],
      ),

      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              TextField(
                controller: searchController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: "Search position...",
                  hintStyle: const TextStyle(color: Colors.white38),

                  prefixIcon: const Icon(Icons.search, color: Colors.white54),

                  filled: true,
                  fillColor: const Color(0xFF1A2238),

                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),

              const SizedBox(height: 18),

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
                    Expanded(child: _categoryChip("All")),
                    Expanded(child: _categoryChip("3PT")),
                    Expanded(child: _categoryChip("Mid")),
                    Expanded(child: _categoryChip("Paint")),
                    Expanded(child: _categoryChip("FT")),
                    Expanded(child: _categoryChip("Other")),
                  ],
                ),
              ),

              const SizedBox(height: 14),

              Expanded(
                child: ListView.builder(
                  itemCount: filteredPositions.length,
                  itemBuilder: (context, index) {
                    final position = filteredPositions[index];

                    final selected = selectedPositions.contains(position.name);

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(18),
                        onTap: () {
                          setState(() {
                            if (selected) {
                              selectedPositions.remove(position.name);
                            } else {
                              selectedPositions.add(position.name);
                            }
                          });
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 11,
                          ),
                          decoration: BoxDecoration(
                            color: selected
                                ? const Color(0xFF2B2255)
                                : const Color(0xFF1A2238),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: selected
                                  ? const Color(0xFF7C5CFF)
                                  : Colors.white10,
                            ),
                          ),

                          child: Row(
                            children: [
                              Container(
                                width: 42,
                                height: 42,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF252E48),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: const Icon(
                                  Icons.sports_basketball,
                                  color: Color(0xFF7C5CFF),
                                  size: 28,
                                ),
                              ),

                              const SizedBox(width: 16),

                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      position.name,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 16,
                                      ),
                                    ),

                                    const SizedBox(height: 6),

                                    Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 5,
                                          ),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFF252E48),
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                          child: Text(
                                            position.category,
                                            style: const TextStyle(
                                              color: Color(0xFFB99CFF),
                                              fontSize: 11,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),

                                        const Spacer(),
                                      ],
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(width: 10),

                              IconButton(
                                splashRadius: 20,
                                onPressed: () {
                                  showModalBottomSheet(
                                    context: context,
                                    isScrollControlled: true,
                                    backgroundColor: const Color(0xFF1A2238),
                                    shape: const RoundedRectangleBorder(
                                      borderRadius: BorderRadius.vertical(
                                        top: Radius.circular(28),
                                      ),
                                    ),
                                    builder: (_) =>
                                        PositionInfoSheet(position: position),
                                  );
                                },
                                icon: const Icon(
                                  Icons.info_outline,
                                  color: Colors.white38,
                                ),
                              ),

                              const SizedBox(width: 6),

                              AnimatedSwitcher(
                                duration: const Duration(milliseconds: 180),
                                child: selected
                                    ? const Icon(
                                        Icons.check_circle_rounded,
                                        key: ValueKey(1),
                                        color: Color(0xFF7C5CFF),
                                        size: 24,
                                      )
                                    : const Icon(
                                        Icons.radio_button_unchecked,
                                        key: ValueKey(2),
                                        color: Colors.white24,
                                        size: 24,
                                      ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

              Container(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF0D1224),
                  border: Border(
                    top: BorderSide(
                      color: Colors.white.withValues(alpha: 0.06),
                    ),
                  ),
                ),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: selectedPositions.isEmpty
                        ? null
                        : () {
                            final selected = positions.where((position) {
                              return selectedPositions.contains(position.name);
                            }).toList();

                            Navigator.pop(context, selected);
                          },

                    style: ElevatedButton.styleFrom(
                      elevation: 0,
                      backgroundColor: const Color(0xFF7C5CFF),
                      disabledBackgroundColor: const Color(0xFF1A2238),
                      disabledForegroundColor: Colors.white38,
                      minimumSize: const Size.fromHeight(62),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),

                    child: Text(
                      selectedPositions.isEmpty
                          ? "Select positions"
                          : "Continue (${selectedPositions.length})",
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
