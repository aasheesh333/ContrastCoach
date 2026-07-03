class CoachMessage {
  const CoachMessage({
    required this.id,
    required this.role,
    required this.content,
    required this.createdAt,
  });

  final String id;
  final CoachRole role;
  final String content;
  final DateTime createdAt;
}

enum CoachRole { user, coach }
