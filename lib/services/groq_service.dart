import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/perspective.dart';
import '../core/constants.dart';

class GroqService {
  final String _apiKey;
  final http.Client _client;

  GroqService()
      : _apiKey = dotenv.env['GROQ_API_KEY'] ?? '',
        _client = http.Client();

  Future<List<Perspective>> generatePerspectives({
    required String eventTitle,
    required String eventDescription,
    required PerspectiveType perspectiveType,
    int count = 5,
  }) async {
    final prompt = _buildPrompt(
      eventTitle: eventTitle,
      eventDescription: eventDescription,
      perspectiveType: perspectiveType,
      count: count,
    );

    final response = await _client.post(
      Uri.parse(AppConstants.groqBaseUrl),
      headers: {
        'Authorization': 'Bearer $_apiKey',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'model': AppConstants.groqModel,
        'messages': [
          {
            'role': 'system',
            'content':
                'You are a balanced historian who presents diverse perspectives on historical events. '
                'Always respond with valid JSON only and nothing else. '
                'Your perspectives should be fair, educational, and represent genuine viewpoints.',
          },
          {'role': 'user', 'content': prompt},
        ],
        'max_tokens': AppConstants.maxTokens,
        'temperature': 0.8,
        'response_format': {'type': 'json_object'},
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Groq API error ${response.statusCode}: ${response.body}');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final content = data['choices'][0]['message']['content'] as String;
    final parsed = jsonDecode(content) as Map<String, dynamic>;
    final perspectivesJson = parsed['perspectives'] as List<dynamic>? ?? [];

    return perspectivesJson
        .map((e) => Perspective.fromJson(e as Map<String, dynamic>, perspectiveType))
        .toList();
  }

  String _buildPrompt({
    required String eventTitle,
    required String eventDescription,
    required PerspectiveType perspectiveType,
    required int count,
  }) {
    return '''
Historical Event: "$eventTitle"
Description: $eventDescription

Generate exactly $count distinct perspectives on this event from ${perspectiveType.promptKeyword}.

Return ONLY a JSON object in this exact format:
{
  "perspectives": [
    {
      "type": "${perspectiveType.label}",
      "label": "Name of the country/religion/school/culture",
      "title": "A short, punchy title for this perspective (max 8 words)",
      "content": "A detailed, thoughtful paragraph (150-200 words) explaining how this group viewed or experienced this event, including their motivations, suffering, victories, or interpretations.",
      "emoji": "A single relevant emoji representing this perspective"
    }
  ]
}

Important:
- Each perspective must be genuinely different and represent that group's authentic viewpoint
- Be balanced and educational, not biased
- Include emotional and historical context
- The "label" should be specific (e.g., "Ottoman Empire" not just "Turkey")
''';
  }

  void dispose() {
    _client.close();
  }
}
