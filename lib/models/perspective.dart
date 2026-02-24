enum PerspectiveType {
  country,
  religion,
  schoolOfThought,
  cultural,
}

extension PerspectiveTypeExtension on PerspectiveType {
  String get label {
    switch (this) {
      case PerspectiveType.country:
        return 'Country';
      case PerspectiveType.religion:
        return 'Religion';
      case PerspectiveType.schoolOfThought:
        return 'School of Thought';
      case PerspectiveType.cultural:
        return 'Cultural';
    }
  }

  String get emoji {
    switch (this) {
      case PerspectiveType.country:
        return '🌍';
      case PerspectiveType.religion:
        return '🕊️';
      case PerspectiveType.schoolOfThought:
        return '🎓';
      case PerspectiveType.cultural:
        return '🏛️';
    }
  }

  String get promptKeyword {
    switch (this) {
      case PerspectiveType.country:
        return 'different countries or civilizations (e.g., British, French, Ottoman, Chinese, Indian, American, African)';
      case PerspectiveType.religion:
        return 'different religions and faith traditions (e.g., Christianity, Islam, Judaism, Hinduism, Buddhism, Sikhism)';
      case PerspectiveType.schoolOfThought:
        return 'different intellectual or philosophical schools of thought (e.g., Marxist, Liberal, Realist, Postcolonial, Feminist, Conservative)';
      case PerspectiveType.cultural:
        return 'different cultural or ethnic communities (e.g., Indigenous, Diasporic, Urban, Rural, various ethnic groups)';
    }
  }
}

class Perspective {
  final String type;
  final String label;
  final String title;
  final String content;
  final String emoji;
  final PerspectiveType perspectiveType;

  const Perspective({
    required this.type,
    required this.label,
    required this.title,
    required this.content,
    required this.emoji,
    required this.perspectiveType,
  });

  factory Perspective.fromJson(Map<String, dynamic> json, PerspectiveType pType) {
    return Perspective(
      type: json['type'] as String? ?? pType.label,
      label: json['label'] as String? ?? 'Unknown',
      title: json['title'] as String? ?? 'Perspective',
      content: json['content'] as String? ?? '',
      emoji: json['emoji'] as String? ?? pType.emoji,
      perspectiveType: pType,
    );
  }
}
