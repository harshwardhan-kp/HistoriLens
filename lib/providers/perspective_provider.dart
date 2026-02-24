import 'package:flutter/foundation.dart';
import '../models/perspective.dart';
import '../models/historical_event.dart';
import '../services/groq_service.dart';

enum PerspectiveLoadState { idle, loading, loaded, error }

class PerspectiveProvider extends ChangeNotifier {
  final GroqService _groqService = GroqService();

  List<Perspective> _perspectives = [];
  PerspectiveLoadState _state = PerspectiveLoadState.idle;
  String _error = '';
  HistoricalEvent? _currentEvent;
  PerspectiveType _currentType = PerspectiveType.country;

  List<Perspective> get perspectives => _perspectives;
  PerspectiveLoadState get state => _state;
  String get error => _error;
  HistoricalEvent? get currentEvent => _currentEvent;
  PerspectiveType get currentType => _currentType;

  Future<void> loadPerspectives({
    required HistoricalEvent event,
    required PerspectiveType type,
  }) async {
    _currentEvent = event;
    _currentType = type;
    _state = PerspectiveLoadState.loading;
    _perspectives = [];
    _error = '';
    notifyListeners();

    try {
      final results = await _groqService.generatePerspectives(
        eventTitle: event.title,
        eventDescription: event.description,
        perspectiveType: type,
        count: 5,
      );
      _perspectives = results;
      _state = PerspectiveLoadState.loaded;
    } catch (e) {
      _error = e.toString();
      _state = PerspectiveLoadState.error;
    }
    notifyListeners();
  }

  Future<void> changeType(PerspectiveType type) async {
    if (_currentEvent == null) return;
    await loadPerspectives(event: _currentEvent!, type: type);
  }

  @override
  void dispose() {
    _groqService.dispose();
    super.dispose();
  }
}
