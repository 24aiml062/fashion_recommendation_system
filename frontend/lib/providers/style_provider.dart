import 'package:flutter/material.dart';
import '../models/style_profile.dart';
import '../services/api_service.dart';

class StyleProvider extends ChangeNotifier {
  StyleProfile? _profile;
  bool _loading = false;
  String? _error;

  StyleProfile? get profile => _profile;
  bool get loading => _loading;
  String? get error => _error;

  Future<void> loadProfile() async {
    _loading = true;
    notifyListeners();
    try {
      final data = await apiService.get('/style/profile');
      _profile = StyleProfile.fromJson(data);
      _error = null;
    } on ApiException catch (e) {
      if (e.statusCode != 404) _error = e.message;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<bool> submitQuiz(Map<String, dynamic> quizData) async {
    _loading = true;
    notifyListeners();
    try {
      final data = await apiService.post('/style/quiz', quizData);
      _profile = StyleProfile.fromJson(data);
      _error = null;
      return true;
    } on ApiException catch (e) {
      _error = e.message;
      return false;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> recordSwipe(String outfitId, String preference, Map<String, dynamic> outfitData) async {
    try {
      await apiService.post('/style/tinder/swipe', {
        'outfit_id': outfitId,
        'preference': preference,
        'outfit_data': outfitData,
      });
    } catch (_) {}
  }

  Future<List<dynamic>> loadTinderOutfits() async {
    try {
      final data = await apiService.get('/style/tinder/outfits') as List;
      return data;
    } catch (_) {
      return [];
    }
  }

  Future<Map<String, dynamic>?> getEvolution() async {
    try {
      return await apiService.get('/style/evolution');
    } catch (_) {
      return null;
    }
  }
}
