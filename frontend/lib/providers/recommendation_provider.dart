import 'package:flutter/material.dart';
import '../models/outfit_recommendation.dart';
import '../services/api_service.dart';

class RecommendationProvider extends ChangeNotifier {
  OutfitRecommendation? _current;
  bool _loading = false;
  String? _error;
  Map<String, dynamic>? _weather;

  OutfitRecommendation? get current => _current;
  bool get loading => _loading;
  String? get error => _error;
  Map<String, dynamic>? get weather => _weather;

  Future<bool> getRecommendation({String occasion = 'casual', String? location}) async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      final body = {'occasion': occasion};
      if (location != null) body['location'] = location;
      final data = await apiService.post('/recommendations/', body);
      _current = OutfitRecommendation.fromJson(data);
      return true;
    } on ApiException catch (e) {
      _error = e.message;
      return false;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> loadWeather(String city) async {
    try {
      _weather = await apiService.get('/weather/?city=$city');
      notifyListeners();
    } catch (_) {}
  }
}
