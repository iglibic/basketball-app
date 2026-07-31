import 'package:flutter/material.dart';
import '../../models/preset_position.dart';
import '../bottom_sheets/position_info_sheet.dart';

/// Omjer stranica slike terena (assets/court/half_court.png je 1536x1024).
/// Marker se pozicionira unutar ovog omjera pa se poklapa sa slikom.
const double kCourtAspectRatio = 1536 / 1024;

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

  bool _isSelected(PresetPosition position) {
    if (widget.selectedPosition != null) {
      return widget.selectedPosition!.name == position.name;
    }

    return selectedPositionName == position.name;
  }

  void _handleTap(PresetPosition position) {
    if (widget.onPositionTap != null) {
      widget.onPositionTap!(position);
      return;
    }

    setState(() {
      selectedPositionName = position.name;
    });

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF1A2238),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (_) => PositionInfoSheet(position: position),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Center(
        child: AspectRatio(
          aspectRatio: kCourtAspectRatio,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth;
              final height = constraints.maxHeight;

              return Stack(
                clipBehavior: Clip.none,
                children: [
                  Positioned.fill(
                    child: Image.asset(
                      "assets/court/half_court.png",
                      fit: BoxFit.fill,
                    ),
                  ),

                  ...widget.positions.map((position) {
                    final isSelected = _isSelected(position);
                    final size = isSelected ? 36.0 : 28.0;

                    return Positioned(
                      left: position.courtX * width - (size / 2),
                      top: position.courtY * height - (size / 2),
                      child: GestureDetector(
                        onTap: widget.interactive
                            ? () => _handleTap(position)
                            : null,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          width: size,
                          height: size,
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
                          child: Icon(
                            Icons.sports_basketball,
                            color: Colors.white,
                            size: isSelected ? 19 : 15,
                          ),
                        ),
                      ),
                    );
                  }),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
