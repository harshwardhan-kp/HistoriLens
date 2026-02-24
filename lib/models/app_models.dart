class ChatMessage {
  final String role; // 'user' or 'assistant'
  final String content;
  final DateTime timestamp;

  const ChatMessage({
    required this.role,
    required this.content,
    required this.timestamp,
  });
}

class BookmarkedPerspective {
  final String id;
  final String eventTitle;
  final String eventSubtitle;
  final String eventEmoji;
  final String perspectiveLabel;
  final String perspectiveTitle;
  final String perspectiveContent;
  final String perspectiveEmoji;
  final String perspectiveType;
  final DateTime createdAt;

  const BookmarkedPerspective({
    required this.id,
    required this.eventTitle,
    required this.eventSubtitle,
    required this.eventEmoji,
    required this.perspectiveLabel,
    required this.perspectiveTitle,
    required this.perspectiveContent,
    required this.perspectiveEmoji,
    required this.perspectiveType,
    required this.createdAt,
  });

  factory BookmarkedPerspective.fromJson(Map<String, dynamic> json) {
    return BookmarkedPerspective(
      id: json['id'] as String,
      eventTitle: json['event_title'] as String? ?? '',
      eventSubtitle: json['event_subtitle'] as String? ?? '',
      eventEmoji: json['event_emoji'] as String? ?? '📖',
      perspectiveLabel: json['perspective_label'] as String? ?? '',
      perspectiveTitle: json['perspective_title'] as String? ?? '',
      perspectiveContent: json['perspective_content'] as String? ?? '',
      perspectiveEmoji: json['perspective_emoji'] as String? ?? '🌍',
      perspectiveType: json['perspective_type'] as String? ?? '',
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson(String userId) => {
        'user_id': userId,
        'event_title': eventTitle,
        'event_subtitle': eventSubtitle,
        'event_emoji': eventEmoji,
        'perspective_label': perspectiveLabel,
        'perspective_title': perspectiveTitle,
        'perspective_content': perspectiveContent,
        'perspective_emoji': perspectiveEmoji,
        'perspective_type': perspectiveType,
      };
}

class HistoryEntry {
  final String id;
  final String eventTitle;
  final String eventSubtitle;
  final String eventEmoji;
  final DateTime exploredAt;

  const HistoryEntry({
    required this.id,
    required this.eventTitle,
    required this.eventSubtitle,
    required this.eventEmoji,
    required this.exploredAt,
  });

  factory HistoryEntry.fromJson(Map<String, dynamic> json) {
    return HistoryEntry(
      id: json['id'] as String,
      eventTitle: json['event_title'] as String? ?? '',
      eventSubtitle: json['event_subtitle'] as String? ?? '',
      eventEmoji: json['event_emoji'] as String? ?? '📖',
      exploredAt: DateTime.parse(json['explored_at'] as String),
    );
  }
}
