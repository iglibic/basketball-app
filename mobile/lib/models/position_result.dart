import 'preset_position.dart';

/// Rezultat jedne pozicije unutar treninga.
class PositionResult {
  final PresetPosition position;
  final int makes;
  final int attempts;

  const PositionResult({
    required this.position,
    required this.makes,
    required this.attempts,
  });

  int get missed => attempts - makes;

  int get percentage {
    if (attempts == 0) return 0;

    return ((makes / attempts) * 100).round();
  }
}
