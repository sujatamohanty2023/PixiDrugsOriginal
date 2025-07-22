import 'dart:io';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';

Future<void> shareFileToWhatsApp({
  required String filePath,
  required String phoneNumber, // e.g. 919876543210 without '+'
  String? message,
}) async {
  try {
    // Compose WhatsApp chat URL with encoded message
    final encodedMessage = Uri.encodeComponent(message ?? '');
    final whatsappUrl = "https://wa.me/$phoneNumber?text=$encodedMessage";

    // Launch WhatsApp chat with the message
    if (await canLaunchUrl(Uri.parse(whatsappUrl))) {
      await launchUrl(Uri.parse(whatsappUrl), mode: LaunchMode.externalApplication);
    } else {
      debugPrint('Could not launch WhatsApp URL');
      return;
    }

    // Wait for user to open WhatsApp chat before sharing file
    await Future.delayed(const Duration(seconds: 2));

    // Share the PDF file via system share dialog
    await Share.shareXFiles(
      [XFile(filePath)],
      text: message,
    );
  } catch (e, stacktrace) {
    debugPrint('Error sharing file to WhatsApp: $e\n$stacktrace');
  }
}
