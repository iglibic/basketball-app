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
    debugPrint("Initial: ${selectedPositions.join(", ")}");

    searchController.addListener(() {
      setState(() {});
    });
  }

  final List<PresetPosition> positions = [
    // 3PT
    PresetPosition(
      name: "Left Corner 3",
      category: "3PT",
      description: "Three-point shot from the left corner.",
      courtX: 0.14,
      courtY: 0.88,
    ),

    PresetPosition(
      name: "Right Corner 3",
      category: "3PT",
      description: "",
      courtX: 0.86,
      courtY: 0.88,
    ),

    PresetPosition(
      name: "Left Wing 3",
      category: "3PT",
      description: "",
      courtX: 0.24,
      courtY: 0.58,
    ),

    PresetPosition(
      name: "Right Wing 3",
      category: "3PT",
      description: "",
      courtX: 0.76,
      courtY: 0.58,
    ),

    PresetPosition(
      name: "Top of the Key",
      category: "3PT",
      description: "",
      courtX: 0.50,
      courtY: 0.42,
    ),

    // Mid Range
    PresetPosition(
      name: "Left Elbow",
      category: "Mid",
      description: "",
      courtX: 0.34,
      courtY: 0.34,
    ),

    PresetPosition(
      name: "Right Elbow",
      category: "Mid",
      description: "",
      courtX: 0.66,
      courtY: 0.34,
    ),

    PresetPosition(
      name: "Left Baseline",
      category: "Mid",
      description: "",
      courtX: 0.18,
      courtY: 0.22,
    ),

    PresetPosition(
      name: "Right Baseline",
      category: "Mid",
      description: "",
      courtX: 0.82,
      courtY: 0.22,
    ),

    PresetPosition(
      name: "Nail",
      category: "Mid",
      description: "",
      courtX: 0.50,
      courtY: 0.28,
    ),

    // Paint
    PresetPosition(
      name: "Left Block",
      category: "Paint",
      description: "",
      courtX: 0.40,
      courtY: 0.16,
    ),

    PresetPosition(
      name: "Right Block",
      category: "Paint",
      description: "",
      courtX: 0.60,
      courtY: 0.16,
    ),

    PresetPosition(
      name: "Restricted Area",
      category: "Paint",
      description: "",
      courtX: 0.50,
      courtY: 0.08,
    ),

    // FT
    PresetPosition(
      name: "Free Throw",
      category: "FT",
      description: "",
      courtX: 0.50,
      courtY: 0.22,
    ),

    // Other
    PresetPosition(
      name: "Half Court",
      category: "Other",
      description: "",
      courtX: 0.50,
      courtY: 0.98,
    ),
  ];

  List<PresetPosition> get filteredPositions {
    return positions.where((position) {
      final matchesCategory =
          selectedCategory == "All" || position.category == selectedCategory;

      final matchesSearch = position.name.toLowerCase().contains(
        searchController.text.toLowerCase(),
      );

      return matchesCategory && matchesSearch;
    }).toList();
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

  Widget _buildSortInfo() {
    switch (selectedSort) {
      case "Highest FG%":
        return const Text(
          "FG% • 47%",
          style: TextStyle(color: Colors.white54, fontSize: 12),
        );

      case "Lowest FG%":
        return const Text(
          "FG% • 18%",
          style: TextStyle(color: Colors.white54, fontSize: 12),
        );

      case "Most Shots":
        return const Text(
          "Shots • 542",
          style: TextStyle(color: Colors.white54, fontSize: 12),
        );

      case "Recent":
        return const Text(
          "2 days ago",
          style: TextStyle(color: Colors.white54, fontSize: 12),
        );

      default:
        return const SizedBox.shrink();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF090E1F),

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
                final options = [
                  "Court Order",
                  "Highest FG%",
                  "Lowest FG%",
                  "Most Shots",
                  "Last Used",
                ];

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
                  color: Color(0xFFB026FF),
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

                                        _buildSortInfo(),
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
                  color: const Color(0xFF090E1F),
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
