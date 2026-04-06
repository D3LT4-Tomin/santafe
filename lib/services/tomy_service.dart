import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/chat_message.dart';

class TomyService {
  static const String baseUrl = 'https://tomy-production.up.railway.app';

  static Future<ChatMessage> sendMessage({
    required String userId,
    required String question,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/chat'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'user_id': userId, 'question': question}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(utf8.decode(response.bodyBytes));
      return ChatMessage(
        role: 'assistant',
        content: data['response'],
        timestamp: DateTime.now(),
      );
    } else if (response.statusCode == 404) {
      throw TomyException(
        'Usuario no encontrado. Configura tu perfil financiero primero.',
      );
    } else {
      throw TomyException('Error del servidor: ${response.statusCode}');
    }
  }

  static Future<List<ChatMessage>> getHistory(String userId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/users/$userId/history'),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(utf8.decode(response.bodyBytes));
      final List<dynamic> messages = data['messages'] ?? [];
      return messages.map((m) => ChatMessage.fromJson(m)).toList();
    } else if (response.statusCode == 404) {
      return [];
    } else {
      throw TomyException('Error al obtener historial: ${response.statusCode}');
    }
  }

  static Future<void> clearHistory(String userId) async {
    await http.delete(Uri.parse('$baseUrl/users/$userId/history'));
  }
}

class TomyException implements Exception {
  final String message;
  TomyException(this.message);

  @override
  String toString() => message;
}
