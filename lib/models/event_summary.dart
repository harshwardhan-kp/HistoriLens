class EventSummary {
  final String period;
  final String overview;
  final List<String> keyPlayers;
  final List<String> significance;
  final List<String> fastFacts;

  const EventSummary({
    required this.period,
    required this.overview,
    required this.keyPlayers,
    required this.significance,
    required this.fastFacts,
  });

  factory EventSummary.fromJson(Map<String, dynamic> json) {
    return EventSummary(
      period: json['period'] as String? ?? '',
      overview: json['overview'] as String? ?? '',
      keyPlayers: List<String>.from(json['keyPlayers'] as List? ?? []),
      significance: List<String>.from(json['significance'] as List? ?? []),
      fastFacts: List<String>.from(json['fastFacts'] as List? ?? []),
    );
  }
}
