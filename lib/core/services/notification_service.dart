/*
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter/foundation.dart';

/// Service de gestion des notifications locales
/// Permet de programmer des notifications quotidiennes à 9h
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications =
  FlutterLocalNotificationsPlugin();

  /// Initialise le service de notifications
  /// À appeler au démarrage de l'application
  Future<void> initialize() async {
    // Initialiser les fuseaux horaires
    tz.initializeTimeZones();

    // Définir le fuseau horaire local
    // Pour l'Afrique de l'Ouest (Bénin) : Africa/Porto-Novo ou Africa/Lagos
    tz.setLocalLocation(tz.getLocation('Africa/Porto-Novo'));

    // Configuration Android
    const AndroidInitializationSettings androidSettings =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    // Configuration iOS
    const DarwinInitializationSettings iosSettings =
    DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    // Configuration globale
    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    // Initialiser le plugin
    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // Demander les permissions
    await _requestPermissions();

    debugPrint('✅ Service de notifications initialisé');
  }

  /// Demande les permissions de notification
  Future<void> _requestPermissions() async {
    // Permissions Android 13+
    final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
    _notifications.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();

    if (androidImplementation != null) {
      await androidImplementation.requestNotificationsPermission();
      debugPrint('✅ Permissions Android demandées');
    }

    // Permissions iOS
    final DarwinFlutterLocalNotificationsPlugin? iosImplementation =
    _notifications.resolvePlatformSpecificImplementation<
        DarwinFlutterLocalNotificationsPlugin>();

    if (iosImplementation != null) {
      await iosImplementation.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
      debugPrint('✅ Permissions iOS demandées');
    }
  }

  /// Callback quand l'utilisateur tape sur la notification
  void _onNotificationTapped(NotificationResponse response) {
    debugPrint('🔔 Notification tapée: ${response.payload}');
    // Ajouter ici la logique de navigation si nécessaire
  }

  /// Programme une notification quotidienne à 9h00
  Future<void> scheduleDailyNotification() async {
    // Annuler toute notification existante avec cet ID
    await _notifications.cancel(0);

    // Calculer la prochaine occurrence de 9h00
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      9, // 9h00
      0, // 0 minutes
    );

    // Si 9h00 est déjà passé aujourd'hui, programmer pour demain
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    // Détails de la notification pour Android
    const AndroidNotificationDetails androidDetails =
    AndroidNotificationDetails(
      'daily_reminder', // ID du canal
      'Rappels quotidiens', // Nom du canal
      channelDescription: 'Notifications quotidiennes à 9h pour Mony',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
      icon: '@mipmap/ic_launcher',
      sound: RawResourceAndroidNotificationSound('notification'),
      enableVibration: true,
      playSound: true,
    );

    // Détails de la notification pour iOS
    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      sound: 'notification.aiff',
    );

    // Détails combinés
    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    // Programmer la notification quotidienne
    await _notifications.zonedSchedule(
      0, // ID unique de la notification
      'Rappel quotidien ⏰', // Titre
      'Pense à ouvrir l\'application aujourd\'hui', // Message
      scheduledDate,
      notificationDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
      UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time, // Répéter quotidiennement
    );

    debugPrint('✅ Notification programmée pour ${scheduledDate.toString()}');
    debugPrint('📅 Prochaine notification: ${scheduledDate.hour}h${scheduledDate.minute.toString().padLeft(2, '0')}');
  }

  /// Annule toutes les notifications programmées
  Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
    debugPrint('❌ Toutes les notifications annulées');
  }

  /// Affiche une notification immédiate (pour tester)
  Future<void> showTestNotification() async {
    const AndroidNotificationDetails androidDetails =
    AndroidNotificationDetails(
      'test_channel',
      'Test',
      channelDescription: 'Canal de test',
      importance: Importance.high,
      priority: Priority.high,
    );

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: DarwinNotificationDetails(),
    );

    await _notifications.show(
      999,
      'Test ⚡',
      'Notification de test - Le système fonctionne !',
      notificationDetails,
    );

    debugPrint('🧪 Notification de test envoyée');
  }

  /// Vérifie si les notifications sont programmées
  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    final List<PendingNotificationRequest> pending =
    await _notifications.pendingNotificationRequests();

    debugPrint('📋 ${pending.length} notification(s) programmée(s)');
    for (var notif in pending) {
      debugPrint('  - ID: ${notif.id}, Titre: ${notif.title}');
    }

    return pending;
  }
}*/

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter/foundation.dart';

/// Service de gestion des notifications locales
/// Permet de programmer des notifications quotidiennes à 9h
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications =
  FlutterLocalNotificationsPlugin();

  /// Initialise le service de notifications
  // ✅ Flag pour éviter la double initialisation
  bool _isInitialized = false;

  /// À appeler au démarrage de l'application
  Future<void> initialize() async {

    if (_isInitialized) {
      debugPrint('⚠️ Service déjà initialisé, skip');
      return;
    }

    // Initialiser les fuseaux horaires
    tz.initializeTimeZones();

    // Définir le fuseau horaire local
    // Pour l'Afrique de l'Ouest (Bénin) : Africa/Porto-Novo ou Africa/Lagos
    tz.setLocalLocation(tz.getLocation('Africa/Porto-Novo'));

    // Configuration Android
    const AndroidInitializationSettings androidSettings =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    // Configuration iOS
    const DarwinInitializationSettings iosSettings =
    DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    // Configuration globale
    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    // Initialiser le plugin
    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // Demander les permissions
    await _requestPermissions();

    _isInitialized = true;
    debugPrint('✅ Service de notifications initialisé');
  }

  /// Demande les permissions de notification
  Future<void> _requestPermissions() async {
    // Permissions Android 13+
    if (defaultTargetPlatform == TargetPlatform.android) {
      final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
      _notifications.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();

      if (androidImplementation != null) {
        final bool? granted = await androidImplementation.requestNotificationsPermission();
        debugPrint('✅ Permissions Android: ${granted == true ? "accordées" : "refusées"}');
      }
    }

    // Permissions iOS
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      final bool? result = await _notifications
          .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
      debugPrint('✅ Permissions iOS: ${result == true ? "accordées" : "refusées"}');
    }
  }

  /// Callback quand l'utilisateur tape sur la notification
  void _onNotificationTapped(NotificationResponse response) {
    debugPrint('🔔 Notification tapée: ${response.payload}');
    // Ajouter ici la logique de navigation si nécessaire
  }

  /// Programme une notification quotidienne à 9h00
  Future<void> scheduleDailyNotification() async {
    // Annuler toute notification existante avec cet ID
    await _notifications.cancel(0);

    // Calculer la prochaine occurrence de 9h00
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      9, // 9h00
      0, // 0 minutes
    );

    // Si 9h00 est déjà passé aujourd'hui, programmer pour demain
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    // Détails de la notification pour Android
    const AndroidNotificationDetails androidDetails =
    AndroidNotificationDetails(
      'daily_reminder', // ID du canal
      'Rappels quotidiens', // Nom du canal
      channelDescription: 'Notifications quotidiennes à 9h pour Mony',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
      icon: '@mipmap/ic_launcher',
      // Retirez cette ligne si vous n'avez pas de son personnalisé
      // sound: RawResourceAndroidNotificationSound('notification'),
      enableVibration: true,
      playSound: true,
    );

    // Détails de la notification pour iOS
    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      // Retirez cette ligne si vous n'avez pas de son personnalisé
      // sound: 'notification.aiff',
    );

    // Détails combinés
    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    // Programmer la notification quotidienne
    await _notifications.zonedSchedule(
      0, // ID unique de la notification
      'Rappel quotidien ⏰', // Titre
      'Pense à ouvrir l\'application aujourd\'hui', // Message
      scheduledDate,
      notificationDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
      UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time, // Répéter quotidiennement
    );

    debugPrint('✅ Notification programmée pour ${scheduledDate.toString()}');
    debugPrint('📅 Prochaine notification: ${scheduledDate.hour}h${scheduledDate.minute.toString().padLeft(2, '0')}');
  }

  /// Annule toutes les notifications programmées
  Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
    debugPrint('❌ Toutes les notifications annulées');
  }

  /// Affiche une notification immédiate (pour tester)
  Future<void> showTestNotification() async {
    const AndroidNotificationDetails androidDetails =
    AndroidNotificationDetails(
      'test_channel',
      'Test',
      channelDescription: 'Canal de test',
      importance: Importance.high,
      priority: Priority.high,
    );

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: DarwinNotificationDetails(),
    );

    await _notifications.show(
      999,
      'Test ⚡',
      'Notification de test - Le système fonctionne !',
      notificationDetails,
    );

    debugPrint('🧪 Notification de test envoyée');
  }

  /// Vérifie si les notifications sont programmées
  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    final List<PendingNotificationRequest> pending =
    await _notifications.pendingNotificationRequests();

    debugPrint('📋 ${pending.length} notification(s) programmée(s)');
    for (var notif in pending) {
      debugPrint('  - ID: ${notif.id}, Titre: ${notif.title}');
    }

    return pending;
  }
}


