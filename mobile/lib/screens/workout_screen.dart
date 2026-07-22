import 'package:flutter/material.dart';

import '../models/preset_position.dart';
import '../widgets/court/basketball_court.dart';

class WorkoutScreen extends StatefulWidget {
  final List<PresetPosition> positions;

  const WorkoutScreen({super.key, required this.positions});

  @override
  State<WorkoutScreen> createState() => _WorkoutScreenState();
}

class _WorkoutScreenState extends State<WorkoutScreen> {
  bool isCourtView = true;
  int currentPosition = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF090E1F),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              _buildHeader(),
              const SizedBox(height: 18),
              _buildToggle(),
              const SizedBox(height: 18),
              Expanded(
                child: isCourtView ? _buildCourtView() : _buildListView(),
              ),
              const SizedBox(height: 18),
              _buildBottomCard(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        IconButton(
          onPressed: () {},
          icon: const Icon(Icons.close, color: Colors.white),
        ),
        const Spacer(),
        Column(
          children: [
            const Text(
              "Workout",
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              "${currentPosition + 1} / ${widget.positions.length}",
              style: const TextStyle(color: Colors.white54),
            ),
          ],
        ),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFF1A2238),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Text(
            "00:00",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  Widget _buildToggle() {
    return Container(
      height: 52,
      decoration: BoxDecoration(
        color: const Color(0xFF1A2238),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () {
                setState(() {
                  isCourtView = true;
                });
              },
              child: Container(
                decoration: BoxDecoration(
                  color: isCourtView
                      ? const Color(0xFF7C5CFF)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Center(
                  child: Text(
                    "COURT",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () {
                setState(() {
                  isCourtView = false;
                });
              },
              child: Container(
                decoration: BoxDecoration(
                  color: !isCourtView
                      ? const Color(0xFF7C5CFF)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Center(
                  child: Text(
                    "LIST",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCourtView() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF10192E),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFF2A3661)),
      ),
      padding: const EdgeInsets.all(12),
      child: BasketballCourt(positions: widget.positions),
    );
  }

  Widget _buildListView() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF10192E),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF2A3661)),
      ),
    );
  }

  Widget _buildBottomCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF10192E),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFF2A3661)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.positions[currentPosition].name,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 6),

          const Text(
            "Target: 25 Attempts",
            style: TextStyle(color: Colors.white54, fontSize: 15),
          ),

          const SizedBox(height: 22),

          const Text(
            "Makes",
            style: TextStyle(
              color: Colors.white70,
              fontWeight: FontWeight.w600,
            ),
          ),

          const SizedBox(height: 10),

          TextField(
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
            decoration: InputDecoration(
              hintText: "0",
              hintStyle: const TextStyle(color: Colors.white24),
              filled: true,
              fillColor: const Color(0xFF1A2238),
              contentPadding: const EdgeInsets.symmetric(vertical: 18),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
            ),
          ),

          const SizedBox(height: 20),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF7C5CFF),
                foregroundColor: Colors.white,
                minimumSize: const Size.fromHeight(56),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Text(
                "NEXT POSITION",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
