import 'package:flutter/material.dart';
import '../../models/preset_position.dart';
import '../bottom_sheets/position_info_sheet.dart';

class BasketballCourt extends StatefulWidget {
  final List<PresetPosition> positions;
  final PresetPosition? selectedPosition;
  final bool interactive;
  final ValueChanged<PresetPosition>? onPositionTap;

  const BasketballCourt({
    super.key,
    required this.positions,
    this.selectedPosition,
    this.interactive = true,
    this.onPositionTap,
  });

  @override
  State<BasketballCourt> createState() => _BasketballCourtState();
}

class _BasketballCourtState extends State<BasketballCourt> {
  String? selectedPositionName;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          final height = constraints.maxHeight;

          return Stack(
            children: [
              Positioned.fill(
                child: Image.asset(
                  "assets/court/half_court.png",
                  fit: BoxFit.contain,
                ),
              ),

              ...widget.positions.map((position) {
                final isSelected = widget.selectedPosition != null
                    ? widget.selectedPosition!.name == position.name
                    : selectedPositionName == position.name;

                return Positioned(
                  left: position.courtX * width - 14,
                  top: position.courtY * height - 14,
                  child: GestureDetector(
                    onTap: widget.interactive
                        ? () {
                            setState(() {
                              selectedPositionName = position.name;
                            });

                            if (widget.onPositionTap != null) {
                              widget.onPositionTap!(position);
                              return;
                            }

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
                          }
                        : null,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      width: isSelected ? 36 : 28,
                      height: isSelected ? 36 : 28,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? const Color(0xFFFFB300)
                            : const Color(0xFF7C5CFF),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                        boxShadow: [
                          BoxShadow(
                            color:
                                (isSelected
                                        ? const Color(0xFFFFB300)
                                        : const Color(0xFF7C5CFF))
                                    .withValues(alpha: 0.35),
                            blurRadius: isSelected ? 14 : 8,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.sports_basketball,
                        color: Colors.white,
                        size: 15,
                      ),
                    ),
                  ),
                );
              }),
            ],
          );
        },
      ),
    );
  }
}
