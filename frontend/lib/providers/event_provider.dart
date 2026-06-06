import 'package:flutter/material.dart';
import '../models/event.dart';
import '../services/api_service.dart';

class EventProvider extends ChangeNotifier {
  List<AppEvent> _events = [];
  bool _loading = false;

  List<AppEvent> get events => _events;
  bool get loading => _loading;

  Future<void> loadEvents() async {
    _loading = true;
    notifyListeners();
    try {
      final data = await apiService.get('/events/') as List;
      _events = data.map((j) => AppEvent.fromJson(j)).toList();
    } catch (_) {} finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<bool> createEvent(Map<String, dynamic> data) async {
    try {
      final res = await apiService.post('/events/', data);
      _events.add(AppEvent.fromJson(res));
      _events.sort((a, b) => a.eventDate.compareTo(b.eventDate));
      notifyListeners();
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<void> deleteEvent(int id) async {
    await apiService.delete('/events/$id');
    _events.removeWhere((e) => e.id == id);
    notifyListeners();
  }

  Future<Map<String, dynamic>?> generateEventOutfit(int eventId) async {
    try {
      return await apiService.post('/events/$eventId/outfit');
    } catch (_) {
      return null;
    }
  }
}
