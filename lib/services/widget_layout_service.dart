import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_service.dart';

class WidgetLayoutService {
  static CollectionReference<Map<String, dynamic>> _widgetConfigRef(
    String userId,
  ) => FirebaseService.userDoc(userId).collection('widgetLayout');

  static Future<Map<String, dynamic>?> getLayoutConfig(String userId) async {
    try {
      final doc = await _widgetConfigRef(userId).doc('config').get();
      if (doc.exists && doc.data() != null) {
        return doc.data();
      }
      return null;
    } catch (e) {
      print('Error loading widget layout: $e');
      return null;
    }
  }

  static Future<void> saveLayoutConfig(
    String userId, {
    required List<String> order,
    required Map<String, bool> visibility,
  }) async {
    try {
      await _widgetConfigRef(userId).doc('config').set({
        'order': order,
        'visibility': visibility,
        'updatedAt': Timestamp.now(),
      });
    } catch (e) {
      print('Error saving widget layout: $e');
    }
  }
}
