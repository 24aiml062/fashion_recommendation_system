import 'package:flutter/material.dart';
import '../models/wardrobe_item.dart';
import '../services/api_service.dart';

class WardrobeProvider extends ChangeNotifier {
  List<WardrobeItem> _items = [];
  bool _loading = false;
  String? _error;

  List<WardrobeItem> get items => _items;
  bool get loading => _loading;
  String? get error => _error;

  List<WardrobeItem> byCategory(String category) =>
      _items.where((i) => i.category == category).toList();

  Future<void> loadWardrobe({String? category, String? search}) async {
    _loading = true;
    notifyListeners();
    try {
      String path = '/wardrobe/?';
      if (category != null) path += 'category=$category&';
      if (search != null) path += 'search=$search&';
      final data = await apiService.get(path) as List;
      _items = data.map((j) => WardrobeItem.fromJson(j)).toList();
      _error = null;
    } on ApiException catch (e) {
      _error = e.message;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<bool> addItem(Map<String, dynamic> itemData) async {
    try {
      final data = await apiService.post('/wardrobe/', itemData);
      _items.add(WardrobeItem.fromJson(data));
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _error = e.message;
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteItem(int id) async {
    try {
      await apiService.delete('/wardrobe/$id');
      _items.removeWhere((i) => i.id == id);
      notifyListeners();
      return true;
    } catch (_) {
      return false;
    }
  }
}
