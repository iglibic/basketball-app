import 'package:flutter/material.dart';
import '../../models/preset_position.dart';

class PositionCard extends StatelessWidget {
  final PresetPosition position;
  final VoidCallback? onSettingsPressed;
  final VoidCallback? onDeletePressed;
  final int index;

  const PositionCard({
    super.key,
    required this.position,
    this.onSettingsPressed,
    this.onDeletePressed,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: null,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF1A2238),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFF2A3661)),
        ),
        child: Row(
          children: [
            ReorderableDragStartListener(
              index: index,
              child: const Icon(Icons.reorder, color: Colors.white38),
            ),

            const SizedBox(width: 12),

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

                  const SizedBox(height: 8),

                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF252E48),
                      borderRadius: BorderRadius.circular(8),
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
                ],
              ),
            ),

            IconButton(
              onPressed: onSettingsPressed,
              icon: const Icon(Icons.tune_rounded, color: Colors.white60),
            ),

            IconButton(
              onPressed: onDeletePressed,
              icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
            ),
          ],
        ),
      ),
    );
  }
}
