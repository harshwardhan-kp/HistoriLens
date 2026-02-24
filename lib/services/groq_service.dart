import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/perspective.dart';
import '../models/event_summary.dart';
import '../models/app_models.dart';
import '../core/constants.dart';

class GroqService {
  final String _apiKey;
  final http.Client _client;

  GroqService()
      : _apiKey = dotenv.env['GROQ_API_KEY'] ?? '',
        _client = http.Client();

  // ─── Perspectives ─────────────────────────────────────────────────────────

  Future<List<Perspective>> generatePerspectives({
    required String eventTitle,
    required String eventDescription,
    required PerspectiveType perspectiveType,
    int count = 5,
  }) async {
    final prompt = _buildPerspectivePrompt(
      eventTitle: eventTitle,
      eventDescription: eventDescription,
      perspectiveType: perspectiveType,
      count: count,
    );

    final data = await _callGroq(
      systemPrompt:
          'You are a balanced historian who presents diverse perspectives on historical events. '
          'Always respond with valid JSON only and nothing else. '
          'Your perspectives should be fair, educational, and represent genuine viewpoints.',
      userPrompt: prompt,
    );

    final content = data['choices'][0]['message']['content'] as String;
    final parsed = jsonDecode(content) as Map<String, dynamic>;
    final perspectivesJson = parsed['perspectives'] as List<dynamic>? ?? [];
    return perspectivesJson
        .map((e) => Perspective.fromJson(e as Map<String, dynamic>, perspectiveType))
        .toList();
  }

  // ─── Event Summary ────────────────────────────────────────────────────────

  Future<EventSummary> generateEventSummary({
    required String eventTitle,
    required String eventDescription,
  }) async {
    final prompt = '''
Historical Event: "$eventTitle"
Description: $eventDescription

Generate a concise educational summary of this event.

Return ONLY a JSON object in this exact format:
{
  "period": "Time period (e.g., 1789-1799)",
  "overview": "2-3 sentence overview of what happened and why it matters (max 80 words)",
  "keyPlayers": ["Person/Group 1", "Person/Group 2", "Person/Group 3"],
  "significance": ["Key consequence 1", "Key consequence 2", "Key consequence 3"],
  "fastFacts": ["Fact 1", "Fact 2", "Fact 3", "Fact 4"]
}
''';

    final data = await _callGroq(
      systemPrompt:
          'You are a historical educator. Respond with valid JSON only. Be concise and factual.',
      userPrompt: prompt,
    );

    final content = data['choices'][0]['message']['content'] as String;
    final parsed = jsonDecode(content) as Map<String, dynamic>;
    return EventSummary.fromJson(parsed);
  }

  // ─── Chat / Deep Dive ─────────────────────────────────────────────────────

  Future<String> chatWithPerspective({
    required String eventTitle,
    required String perspectiveLabel,
    required String perspectiveContent,
    required List<ChatMessage> messages,
  }) async {
    final systemPrompt =
        'You are an expert historian helping a user understand the $perspectiveLabel perspective '
        'on "$eventTitle". Here is the perspective content for context:\n\n'
        '$perspectiveContent\n\n'
        'Answer follow-up questions concisely (2-4 sentences). Be educational and balanced.';

    final groqMessages = [
      {'role': 'system', 'content': systemPrompt},
      ...messages.map((m) => {'role': m.role, 'content': m.content}),
    ];

    final response = await _client.post(
      Uri.parse(AppConstants.groqBaseUrl),
      headers: {
        'Authorization': 'Bearer $_apiKey',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'model': AppConstants.groqModel,
        'messages': groqMessages,
        'max_tokens': 300,
        'temperature': 0.7,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Groq API error ${response.statusCode}');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    return data['choices'][0]['message']['content'] as String;
  }

  // ─── AI Search / Suggestions ──────────────────────────────────────────────

  Future<List<String>> suggestEvents(String query) async {
    if (query.trim().length < 2) return [];

    final prompt =
        'The user typed: "$query"\n\n'
        'Suggest 5 specific historical events, battles, revolutions, inventions, or '
        'historical figures that match this query. Each suggestion should be a proper '
        'historical event title (e.g., "The French Revolution", "Battle of Waterloo", '
        '"Nelson Mandela and Apartheid").\n\n'
        'Return ONLY a JSON object: {"suggestions": ["suggestion1", "suggestion2", ...]}';

    final data = await _callGroq(
      systemPrompt: 'You suggest historical events. Return valid JSON only.',
      userPrompt: prompt,
      maxTokens: 200,
    );

    final content = data['choices'][0]['message']['content'] as String;
    final parsed = jsonDecode(content) as Map<String, dynamic>;
    final suggestions = parsed['suggestions'] as List<dynamic>? ?? [];
    return suggestions.map((s) => s.toString()).toList();
  }

  // ─── Internals ────────────────────────────────────────────────────────────

  Future<Map<String, dynamic>> _callGroq({
    required String systemPrompt,
    required String userPrompt,
    int maxTokens = AppConstants.maxTokens,
  }) async {
    final response = await _client.post(
      Uri.parse(AppConstants.groqBaseUrl),
      headers: {
        'Authorization': 'Bearer $_apiKey',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'model': AppConstants.groqModel,
        'messages': [
          {'role': 'system', 'content': systemPrompt},
          {'role': 'user', 'content': userPrompt},
        ],
        'max_tokens': maxTokens,
        'temperature': 0.8,
        'response_format': {'type': 'json_object'},
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Groq API error ${response.statusCode}: ${response.body}');
    }

    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  String _buildPerspectivePrompt({
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
