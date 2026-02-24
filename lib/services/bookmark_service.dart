import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/app_models.dart';
import '../models/perspective.dart';

class BookmarkService extends ChangeNotifier {
  final SupabaseClient _client = Supabase.instance.client;

  String? get _userId => _client.auth.currentUser?.id;

  Future<String?> save({
    required String eventTitle,
    required String eventSubtitle,
    required String eventEmoji,
    required Perspective perspective,
  }) async {
    if (_userId == null) return null;
    final data = {
      'user_id': _userId,
      'event_title': eventTitle,
      'event_subtitle': eventSubtitle,
      'event_emoji': eventEmoji,
      'perspective_label': perspective.label,
      'perspective_title': perspective.title,
      'perspective_content': perspective.content,
      'perspective_emoji': perspective.emoji,
      'perspective_type': perspective.perspectiveType.label,
    };
    final response = await _client.from('bookmarks').insert(data).select('id').single();
    notifyListeners();
    return response['id'] as String?;
  }

  Future<void> remove(String bookmarkId) async {
    await _client.from('bookmarks').delete().eq('id', bookmarkId);
    notifyListeners();
  }

  Future<List<BookmarkedPerspective>> getAll() async {
    if (_userId == null) return [];
    final data = await _client
        .from('bookmarks')
        .select()
        .eq('user_id', _userId!)
        .order('created_at', ascending: false);
    return (data as List).map((json) => BookmarkedPerspective.fromJson(json)).toList();
  }

  Future<String?> getBookmarkId(String eventTitle, String perspectiveLabel) async {
    if (_userId == null) return null;
    final data = await _client
        .from('bookmarks')
        .select('id')
        .eq('user_id', _userId!)
        .eq('event_title', eventTitle)
        .eq('perspective_label', perspectiveLabel)
        .maybeSingle();
    return data?['id'] as String?;
  }
}
