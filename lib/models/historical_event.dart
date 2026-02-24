class HistoricalEvent {
  final String title;
  final String subtitle;
  final String emoji;
  final String category;
  final String description;

  const HistoricalEvent({
    required this.title,
    required this.subtitle,
    required this.emoji,
    required this.category,
    required this.description,
  });

  factory HistoricalEvent.fromMap(Map<String, dynamic> map) {
    return HistoricalEvent(
      title: map['title'] as String,
      subtitle: map['subtitle'] as String,
      emoji: map['emoji'] as String,
      category: map['category'] as String,
      description: map['description'] as String,
    );
  }
}
