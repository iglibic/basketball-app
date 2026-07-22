class PresetPosition {
  final String name;
  final String category;
  final String description;

  final double courtX;
  final double courtY;

  int goalShots;

  PresetPosition({
    required this.name,
    required this.category,
    required this.description,
    required this.courtX,
    required this.courtY,
    this.goalShots = 25,
  });
}
