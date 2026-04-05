import 'package:flutter/foundation.dart';
import '../models/chat_message.dart';
import '../services/tomy_service.dart';

class TomyProvider extends ChangeNotifier {
  final String userId;
  final List<ChatMessage> _messages = [];
  bool _isLoading = false;
  String? _error;

  TomyProvider({required this.userId});

  List<ChatMessage> get messages => List.unmodifiable(_messages);
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadHistory() async {
    try {
      final history = await TomyService.getHistory(userId);
      _messages.clear();
      _messages.addAll(history);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    _messages.add(
      ChatMessage(role: 'user', content: text, timestamp: DateTime.now()),
    );
    notifyListeners();

    try {
      final response = await TomyService.sendMessage(
        userId: userId,
        question: text,
      );
      _messages.add(response);
    } catch (e) {
      _error = e.toString();
      _messages.add(
        ChatMessage(
          role: 'assistant',
          content: 'Lo siento, tuve un problema al responder. $e',
          timestamp: DateTime.now(),
        ),
      );
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> clearChat() async {
    try {
      await TomyService.clearHistory(userId);
      _messages.clear();
      _error = null;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }
}
