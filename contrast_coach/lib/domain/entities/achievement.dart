class Achievement {
  const Achievement({
    required this.id,
    required this.title,
    required this.emoji,
    required this.description,
    this.unlockedAt,
  });

  final String id;
  final String title;
  final String emoji;
  final String description;
  final DateTime? unlockedAt;

  bool get isUnlocked => unlockedAt != null;

  Achievement copyWith({DateTime? unlockedAt}) {
    return Achievement(
      id: id,
      title: title,
      emoji: emoji,
      description: description,
      unlockedAt: unlockedAt ?? this.unlockedAt,
    );
  }
}
