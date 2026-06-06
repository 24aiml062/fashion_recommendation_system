import 'package:flutter/material.dart';
import '../services/api_service.dart';

class ChatMessage {
  final String role;
  final String content;
  final DateTime createdAt;

  ChatMessage({required this.role, required this.content, required this.createdAt});

  factory ChatMessage.fromJson(Map<String, dynamic> j) => ChatMessage(
        role: j['role'],
        content: j['content'],
        createdAt: DateTime.parse(j['created_at']),
      );
}

class ChatProvider extends ChangeNotifier {
  final List<ChatMessage> _messages = [];
  bool _loading = false;
  String? _error;

  List<ChatMessage> get messages => List.unmodifiable(_messages);
  bool get loading => _loading;
  String? get error => _error;

  Future<void> loadHistory() async {
    try {
      final data = await apiService.get('/chat/history') as List;
      _messages.clear();
      _messages.addAll(data.map((j) => ChatMessage.fromJson(j)));
      notifyListeners();
    } catch (_) {}
  }

  Future<bool> sendMessage(String content) async {
    _loading = true;
    _error = null;
    _messages.add(ChatMessage(role: 'user', content: content, createdAt: DateTime.now()));
    notifyListeners();

    try {
      final data = await apiService.post('/chat/', {'content': content});
      _messages.add(ChatMessage.fromJson(data['assistant_message']));
      return true;
    } on ApiException catch (e) {
      _error = e.message;
      return false;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> clearHistory() async {
    await apiService.delete('/chat/history');
    _messages.clear();
    notifyListeners();
  }
}
