import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'message_badge.dart';

class NotificationService {
  static final _notificationsPlugin = FlutterLocalNotificationsPlugin();
  static StreamSubscription<QuerySnapshot>? _subscription;

  /// Inicializa o sistema de notificações para todas as versões de Android
  static Future<void> initialize() async {
    // 1) Configuração Android básica
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');

    // 2) Inicializa o plugin
    await _notificationsPlugin.initialize(
      const InitializationSettings(android: androidInit),
    );

    // 3) Se Android, faça o setup de canais e permissões conforme a API
    if (Platform.isAndroid) {
      final androidImpl =
          _notificationsPlugin.resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();

      // Cria o canal (necessário desde API 26)
      const channel = AndroidNotificationChannel(
        'overbloom_channel',
        'Mensagens OverBloom',
        description: 'Canal para notificações de mensagens',
        importance: Importance.high,
      );
      await androidImpl?.createNotificationChannel(channel);

      await androidImpl?.requestNotificationsPermission();
    }
  }

  static Future<void> listenForMessages(String userId) async {
    await _subscription?.cancel();
    bool initialized = false;

    _subscription = FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('messages')
        .where('recipientUser', isEqualTo: userId)
        .orderBy('sendingDate', descending: true)
        .snapshots()
        .listen((snap) {
      if (!initialized) {
        initialized = true;
        return;
      }
      for (var change in snap.docChanges) {
        if (change.type == DocumentChangeType.added) {
          final data = change.doc.data()!;
          final user = data['senderUser'] as String? ?? 'Alguém';
          final text = data['messageText'] as String? ?? '';
          final img = data['senderUserAvatar'] as String? ?? '';
          _showNotification(user, img, text);
          MessageBadge.hasNewMessage.value = true;
        }
      }
    });
  }

  static Future<void> cancelListening() async {
    await _subscription?.cancel();
    _subscription = null;
  }

  static Future<void> _showNotification(
      String user,
      String imgAssetPath,
      String text,
      ) async {
    // Carrega a imagem de perfil
    final ByteData byteData = await rootBundle.load(imgAssetPath);
    final Uint8List imageBytes = byteData.buffer.asUint8List();

    final androidDetails = AndroidNotificationDetails(
      'overbloom_channel',
      'Mensagens OverBloom',
      channelDescription: 'Canal para notificações de mensagens',
      icon: '@mipmap/ic_launcher',
      largeIcon: ByteArrayAndroidBitmap(imageBytes),
      colorized: true,
      styleInformation: BigTextStyleInformation(
        text,
        htmlFormatBigText: true,
        contentTitle: '<b>$user</b>',
        htmlFormatContentTitle: true,
      ),
      importance: Importance.max,
      priority: Priority.high,
      visibility: NotificationVisibility.public,
      showWhen: true,
    );

    await _notificationsPlugin.show(
      user.hashCode,
      user, // Título da notificação (nome)
      text, // Conteúdo da notificação (mensagem)
      NotificationDetails(android: androidDetails),
    );
  }
}
