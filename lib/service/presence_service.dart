import 'package:firebase_database/firebase_database.dart';

class PresenceService {
  final DatabaseReference _statusRef;

  PresenceService(String userId)
      : _statusRef = FirebaseDatabase.instance.ref('status/$userId');

  void setOnline() {
    _statusRef.set({
      'state': 'online',
      'last_changed': ServerValue.timestamp,
    });
    _statusRef.onDisconnect().set({
      'state': 'offline',
      'last_changed': ServerValue.timestamp,
    });
  }
}