import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/payment_settings_model.dart';

class PaymentSettingsService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static const String _collection = 'settings';
  static const String _docId = 'payment';

  DocumentReference<Map<String, dynamic>> get _docRef =>
      _firestore.collection(_collection).doc(_docId);

  Stream<PaymentSettingsModel> watchSettings() {
    return _docRef.snapshots().map((snapshot) {
      final data = snapshot.data();
      if (data == null) return PaymentSettingsModel.defaults();
      return PaymentSettingsModel.fromMap(data);
    });
  }

  Future<PaymentSettingsModel> getSettings() async {
    final snapshot = await _docRef.get();
    final data = snapshot.data();
    if (data == null) return PaymentSettingsModel.defaults();
    return PaymentSettingsModel.fromMap(data);
  }

  Future<void> saveSettings(PaymentSettingsModel settings) async {
    await _docRef.set(
      settings.copyWith(updatedAt: DateTime.now()).toMap(),
      SetOptions(merge: true),
    );
  }
}
