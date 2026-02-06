import 'dart:io';

class QRService {
  static bool get isSupported => Platform.isAndroid || Platform.isIOS;

  static Future<String?> scan() async {
    return null; // Use manual input on desktop
  }
}
