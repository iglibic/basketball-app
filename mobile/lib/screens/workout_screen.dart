import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/position_result.dart';
import '../models/preset_position.dart';
import '../widgets/court/basketball_court.dart';
import 'training_summary_screen.dart';

class WorkoutScreen extends StatefulWidget {
  final List<PresetPosition> positions;
  final String workoutName;

  const WorkoutScreen({
    super.key,
    required this.positions,
    this.workoutName = "",
  });

  @override
  State<WorkoutScreen> createState() => _WorkoutScreenState();
}

class _WorkoutScreenState extends State<WorkoutScreen> {
  bool isCourtView = true;
  int currentPosition = 0;

  final List<TextEditingController> _makesControllers = [];
  final List<TextEditingController> _attemptControllers = [];

  late DateTime _startTime;
  Timer? _timer;
  Duration _elapsed = Duration.zero;

  @override
  void initState() {
    super.initState();

    _startTime = DateTime.now();

    for (int i = 0; i < widget.positions.length; i++) {
      _makesControllers.add(TextEditingController());
      _attemptControllers.add(TextEditingController());
    }

    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;

      setState(() {
        _elapsed = DateTime.now().difference(_startTime);
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();

    for (final controller in _makesControllers) {
      controller.dispose();
    }
    for (final controller in _attemptControllers) {
      controller.dispose();
    }

    super.dispose();
  }

  int _makesAt(int index) {
    return int.tryParse(_makesControllers[index].text.trim()) ?? 0;
  }

  int _attemptsAt(int index) {
    return int.tryParse(_attemptControllers[index].text.trim()) ?? 0;
  }

  /// Makes ne smije biti veci od attempts (isto pravilo kao CHECK u bazi).
  bool _isInvalidAt(int index) {
    return _makesAt(index) > _attemptsAt(index);
  }

  bool get hasInvalidPosition {
    for (int i = 0; i < widget.positions.length; i++) {
      if (_isInvalidAt(i)) return true;
    }

    return false;
  }

  bool get hasAnyShots {
    for (int i = 0; i < widget.positions.length; i++) {
      if (_attemptsAt(i) > 0) return true;
    }

    return false;
  }

  int get totalMakes {
    int total = 0;

    for (int i = 0; i < widget.positions.length; i++) {
      total += _makesAt(i);
    }

    return total;
  }

  int get totalAttempts {
    int total = 0;

    for (int i = 0; i < widget.positions.length; i++) {
      total += _attemptsAt(i);
    }

    return total;
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes.toString().padLeft(2, '0');
    final seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');

    return "$minutes:$seconds";
  }

  Future<bool> _confirmExit() async {
    if (!hasAnyShots) return true;

    final discard = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A2238),

        title: const Text(
          "Discard workout?",
          style: TextStyle(color: Colors.white),
        ),

        content: const Text(
          "Your entered shots will be lost.",
          style: TextStyle(color: Colors.white70),
        ),

        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Keep training"),
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

  void _finishWorkout() {
    final results = <PositionResult>[];

    for (int i = 0; i < widget.positions.length; i++) {
      results.add(
        PositionResult(
          position: widget.positions[i],
          makes: _makesAt(i),
          attempts: _attemptsAt(i),
        ),
      );
    }

    final totalShots = totalAttempts;
    final madeShots = totalMakes;

    final percentage = totalShots == 0
        ? 0
        : ((madeShots / totalShots) * 100).round();

    _timer?.cancel();

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => TrainingSummaryScreen(
          totalShots: totalShots,
          madeShots: madeShots,
          missedShots: totalShots - madeShots,
          percentage: percentage,
          results: results,
          duration: DateTime.now().difference(_startTime),
          workoutName: widget.workoutName,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,

      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;

        final shouldPop = await _confirmExit();

        if (shouldPop && context.mounted) {
          Navigator.pop(context);
        }
      },

      child: Scaffold(
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

                // Scroll sprjecava overflow kada se otvori tipkovnica.
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        SizedBox(
                          height: 260,
                          child: isCourtView
                              ? _buildCourtView()
                              : _buildListView(),
                        ),

                        const SizedBox(height: 18),

                        _buildBottomCard(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        IconButton(
          tooltip: "Close workout",
          onPressed: () async {
            final shouldPop = await _confirmExit();

            if (shouldPop && mounted) {
              Navigator.pop(context);
            }
          },
          icon: const Icon(Icons.close, color: Colors.white),
        ),

        const Spacer(),

        Column(
          children: [
            Text(
              widget.workoutName.isEmpty ? "Workout" : widget.workoutName,
              style: const TextStyle(
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
          child: Text(
            _formatDuration(_elapsed),
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
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
          Expanded(child: _buildToggleItem("COURT", true)),
          Expanded(child: _buildToggleItem("LIST", false)),
        ],
      ),
    );
  }

  Widget _buildToggleItem(String label, bool courtView) {
    final selected = isCourtView == courtView;

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () {
        setState(() {
          isCourtView = courtView;
        });
      },
      child: Container(
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF7C5CFF) : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Center(
          child: Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
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
      child: BasketballCourt(
        positions: widget.positions,
        selectedPosition: widget.positions[currentPosition],
        onPositionTap: (position) {
          setState(() {
            currentPosition = widget.positions.indexOf(position);
          });
        },
      ),
    );
  }

  Widget _buildListView() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF10192E),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF2A3661)),
      ),
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: widget.positions.length,
        itemBuilder: (context, index) {
          final position = widget.positions[index];

          final makes = _makesAt(index);
          final attempts = _attemptsAt(index);
          final isSelected = index == currentPosition;
          final isInvalid = _isInvalidAt(index);

          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () {
                setState(() {
                  currentPosition = index;
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color(0xFF2B2255)
                      : const Color(0xFF1A2238),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isInvalid
                        ? Colors.redAccent
                        : isSelected
                        ? const Color(0xFF7C5CFF)
                        : Colors.white10,
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        position.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),

                    Text(
                      "$makes/$attempts",
                      style: TextStyle(
                        color: isInvalid
                            ? Colors.redAccent
                            : const Color(0xFF7C5CFF),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBottomCard() {
    final makes = _makesAt(currentPosition);
    final attempts = _attemptsAt(currentPosition);

    final isInvalid = _isInvalidAt(currentPosition);

    final double fg = attempts == 0 ? 0 : (makes / attempts) * 100;

    final isLastPosition = currentPosition == widget.positions.length - 1;

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

          const SizedBox(height: 24),

          _buildCounterField(
            label: "Makes",
            controller: _makesControllers[currentPosition],
            hasError: isInvalid,
          ),

          const SizedBox(height: 20),

          _buildCounterField(
            label: "Attempts",
            controller: _attemptControllers[currentPosition],
            hasError: isInvalid,
          ),

          if (isInvalid) ...[
            const SizedBox(height: 12),

            Row(
              children: [
                const Icon(
                  Icons.error_outline,
                  color: Colors.redAccent,
                  size: 18,
                ),

                const SizedBox(width: 8),

                const Expanded(
                  child: Text(
                    "Makes cannot be greater than attempts.",
                    style: TextStyle(color: Colors.redAccent, fontSize: 13),
                  ),
                ),
              ],
            ),
          ],

          const SizedBox(height: 20),

          Center(
            child: Text(
              "FG%: ${fg.toStringAsFixed(1)}%",
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          const SizedBox(height: 24),

          Row(
            children: [
              if (currentPosition > 0) ...[
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      setState(() {
                        currentPosition--;
                      });
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF7C5CFF),
                      side: const BorderSide(color: Color(0xFF7C5CFF)),
                      minimumSize: const Size.fromHeight(56),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text(
                      "BACK",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 12),
              ],

              Expanded(
                flex: 2,
                child: ElevatedButton(
                  onPressed: isInvalid
                      ? null
                      : () {
                          if (!isLastPosition) {
                            setState(() {
                              currentPosition++;
                            });
                            return;
                          }

                          _finishWorkout();
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF7C5CFF),
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: const Color(0xFF1A2238),
                    disabledForegroundColor: Colors.white38,
                    minimumSize: const Size.fromHeight(56),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(
                    isLastPosition ? "FINISH WORKOUT" : "NEXT POSITION",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ],
          ),

          if (isLastPosition && !hasAnyShots) ...[
            const SizedBox(height: 12),

            const Center(
              child: Text(
                "Enter at least one attempt to finish.",
                style: TextStyle(color: Colors.white38, fontSize: 13),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCounterField({
    required String label,
    required TextEditingController controller,
    required bool hasError,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontWeight: FontWeight.w600,
          ),
        ),

        const SizedBox(height: 10),

        TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          textAlign: TextAlign.center,
          maxLength: 4,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          onChanged: (_) => setState(() {}),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
          decoration: InputDecoration(
            counterText: "",
            hintText: "0",
            hintStyle: const TextStyle(color: Colors.white24),
            filled: true,
            fillColor: const Color(0xFF1A2238),
            contentPadding: const EdgeInsets.symmetric(vertical: 18),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: hasError
                  ? const BorderSide(color: Colors.redAccent)
                  : BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                color: hasError ? Colors.redAccent : const Color(0xFF7C5CFF),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
