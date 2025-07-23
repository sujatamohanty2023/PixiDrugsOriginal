import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

Future<void> shareFileToWhatsApp({
  required String filePath,
  required String phoneNumber, // e.g. 919876543210 without '+'
  String? message,
}) async {
  try {

    const platform = MethodChannel('whatsapp_share');
    try {
      await platform.invokeMethod('sendFileToNumber', {
        'filePath': filePath,
        'phone': phoneNumber,
        'message':message
      });
    } on PlatformException catch (e) {
      print("Error: ${e.message}");
    }
  } catch (e, stacktrace) {
    debugPrint('Error sharing file to WhatsApp: $e\n$stacktrace');
  }
}
