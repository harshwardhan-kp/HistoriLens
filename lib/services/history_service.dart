import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/app_models.dart';
import '../models/historical_event.dart';

class HistoryService extends ChangeNotifier {
  final SupabaseClient _client = Supabase.instance.client;

  String? get _userId => _client.auth.currentUser?.id;

  Future<void> logEvent(HistoricalEvent event) async {
    if (_userId == null) return;
    // Upsert-style: delete same event if explored in last hour, then insert fresh
    await _client
        .from('history')
        .delete()
        .eq('user_id', _userId!)
        .eq('event_title', event.title)
        .gte('explored_at', DateTime.now().subtract(const Duration(hours: 1)).toIso8601String());

    await _client.from('history').insert({
      'user_id': _userId,
      'event_title': event.title,
      'event_subtitle': event.subtitle,
      'event_emoji': event.emoji,
    });
    notifyListeners();
  }

  Future<List<HistoryEntry>> getRecent({int days = 7}) async {
    if (_userId == null) return [];
    final since = DateTime.now().subtract(Duration(days: days)).toIso8601String();
    final data = await _client
        .from('history')
        .select()
        .eq('user_id', _userId!)
        .gte('explored_at', since)
        .order('explored_at', ascending: false)
        .limit(20);
    return (data as List).map((json) => HistoryEntry.fromJson(json)).toList();
  }

  Future<void> clearAll() async {
    if (_userId == null) return;
    await _client.from('history').delete().eq('user_id', _userId!);
    notifyListeners();
  }
}
