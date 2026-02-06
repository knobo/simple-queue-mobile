import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Firebase Service for Push Notifications
/// 
/// Håndterer:
/// - Firebase Cloud Messaging (FCM) for push-varsler
/// - Lokal lagring av FCM-token
/// - Håndtering av innkommende meldinger
class FirebaseService {
  static final FirebaseService _instance = FirebaseService._internal();
  factory FirebaseService() => _instance;
  FirebaseService._internal();

  FirebaseMessaging? _messaging;
  String? _fcmToken;
  
  String? get fcmToken => _fcmToken;

  /// Initialiser Firebase og FCM
  Future<void> initialize() async {
    try {
      if (!_isSupportedPlatform()) {
        debugPrint('FirebaseService: Not supported on this platform');
        return;
      }

      // Initialiser Firebase (krever firebase_options.dart fra flutterfire configure)
      // await Firebase.initializeApp(
      //   options: DefaultFirebaseOptions.currentPlatform,
      // );
      await Firebase.initializeApp();
      _messaging = FirebaseMessaging.instance;
      
      // Be om tillatelse for push-varsler
      await _requestPermission();
      
      // Hent FCM-token
      await _getToken();
      
      // Sett opp listeners for meldinger
      _setupMessageHandlers();
      
      debugPrint('FirebaseService: Initialisert');
    } catch (e) {
      debugPrint('FirebaseService: Feil ved initialisering: $e');
    }
  }

  bool _isSupportedPlatform() {
    try {
      return Platform.isAndroid || Platform.isIOS || Platform.isMacOS;
    } catch (e) {
      return false;
    }
  }

  /// Be om tillatelse for push-notifikasjoner
  Future<void> _requestPermission() async {
    if (_messaging == null) return;
    NotificationSettings settings = await _messaging!.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    debugPrint('FCM tillatelse: ${settings.authorizationStatus}');
  }

  /// Hent FCM-token for denne enheten
  Future<void> _getToken() async {
    if (_messaging == null) return;
    try {
      _fcmToken = await _messaging!.getToken();
      debugPrint('FCM Token: $_fcmToken');
      
      // Lagre token lokalt
      if (_fcmToken != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('fcm_token', _fcmToken!);
      }
      
      // Lytt til token-oppdateringer
      _messaging!.onTokenRefresh.listen((newToken) {
        _fcmToken = newToken;
        debugPrint('FCM Token oppdatert: $newToken');
        // TODO: Send nytt token til backend
      });
    } catch (e) {
      debugPrint('Feil ved henting av FCM-token: $e');
    }
  }

  /// Sett opp handlers for innkommende meldinger
  void _setupMessageHandlers() {
    if (!_isSupportedPlatform()) return;
    
    // Foreground meldinger (app åpen)
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint('FCM melding mottatt (foreground): ${message.notification?.title}');
      _handleMessage(message);
    });

    // Når bruker trykker på notifikasjon (app i bakgrunn)
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint('FCM melding åpnet: ${message.notification?.title}');
      _handleMessageOpened(message);
    });
  }

  /// Håndter innkommende melding
  void _handleMessage(RemoteMessage message) {
    final notification = message.notification;
    final data = message.data;

    // TODO: Vis lokal notifikasjon eller oppdater UI
    // TODO: Håndter ulike typer varsler basert på data['type']
    // f.eks. 'queue_position', 'ticket_called', 'queue_closed'
    
    final type = data['type'] ?? 'unknown';
    debugPrint('FCM meldingstype: $type');

    switch (type) {
      case 'queue_position':
        // Oppdater posisjon i kø
        break;
      case 'ticket_called':
        // Din tur!
        break;
      case 'queue_closed':
        // Køen er stengt
        break;
      case 'ticket_cancelled':
        // Billett kansellert
        break;
      default:
        debugPrint('Ukjent meldingstype: $type');
    }
  }

  /// Håndter når bruker trykker på notifikasjon
  void _handleMessageOpened(RemoteMessage message) {
    final data = message.data;
    
    // TODO: Naviger til riktig skjerm basert på data
    // f.eks. ticket_screen hvis det er en billett-oppdatering
    
    final ticketId = data['ticketId'];
    final queueId = data['queueId'];
    
    debugPrint('Åpnet melding - ticketId: $ticketId, queueId: $queueId');
  }

  /// Abonner på en kø for push-varsler
  Future<void> subscribeToQueue(String queueId) async {
    if (_messaging == null) return;
    await _messaging!.subscribeToTopic('queue_$queueId');
    debugPrint('Abonnert på kø: $queueId');
  }

  /// Avslutt abonnement på kø
  Future<void> unsubscribeFromQueue(String queueId) async {
    if (_messaging == null) return;
    await _messaging!.unsubscribeFromTopic('queue_$queueId');
    debugPrint('Avsluttet abonnement på kø: $queueId');
  }

  /// Abonner på bruker-spesifikke varsler
  Future<void> subscribeToUser(String userId) async {
    if (_messaging == null) return;
    await _messaging!.subscribeToTopic('user_$userId');
    debugPrint('Abonnert på bruker: $userId');
  }

  /// Slett FCM-token (f.eks. ved utlogging)
  Future<void> deleteToken() async {
    if (_messaging == null) return;
    await _messaging!.deleteToken();
    _fcmToken = null;
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('fcm_token');
    
    debugPrint('FCM-token slettet');
  }
}

/// Background message handler (må være top-level funksjon)
/// 
/// KALLES NÅR APPEN ER I BACKGROUND ELLER TERMINATED
/// MERK: Denne må være utenfor klassen og annotert med @pragma('vm:entry-point')
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Hvis du trenger å bruke Firebase i background handler:
  // await Firebase.initializeApp();
  
  debugPrint('FCM melding mottatt (background): ${message.messageId}');
  
  // TODO: Håndter bakgrunnsmeldinger
  // Viktig: Dette kjører i isolert context - ikke bruk UI her
}
