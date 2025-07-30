import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class UpiDeepLinkScreen extends StatefulWidget {
  const UpiDeepLinkScreen({super.key});

  @override
  State<UpiDeepLinkScreen> createState() => _UpiDeepLinkScreenState();
}

class _UpiDeepLinkScreenState extends State<UpiDeepLinkScreen> {
  final _upiAddressController = TextEditingController(text: 'pixiglam@idfcbank');
  final _amountController = TextEditingController(text: '1.00');
  final _receiverNameController = TextEditingController(text: 'PIXIGLAM SOFTWARE PRIVATE LIMITED');
  String? _error;

  Future<void> _launchUpi() async {
    final upiAddress = _upiAddressController.text.trim();
    final amount = _amountController.text.trim();
    final receiverName = _receiverNameController.text.trim();

    if (!_validateUpiAddress(upiAddress)) {
      setState(() {
        _error = 'Invalid UPI ID';
      });
      return;
    }

    final upiUri = Uri.parse(
      'upi://pay?pa=$upiAddress&pn=$receiverName&am=$amount&cu=INR&tn=UPI%20Payment',
    );

    if (await canLaunchUrl(upiUri)) {
      setState(() {
        _error = null;
      });
      await launchUrl(upiUri, mode: LaunchMode.externalApplication);
    } else {
      setState(() {
        _error = 'No UPI app found on this device.';
      });
    }
  }

  bool _validateUpiAddress(String value) {
    return value.contains('@') && value.split('@').length == 2;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('UPI Deep Link Payment')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _upiAddressController,
              decoration: const InputDecoration(
                labelText: 'UPI ID',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _receiverNameController,
              decoration: const InputDecoration(
                labelText: 'Receiver Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'Amount (INR)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _launchUpi,
              child: const Text('Pay via UPI'),
            ),
            if (_error != null) ...[
              const SizedBox(height: 16),
              Text(
                _error!,
                style: const TextStyle(color: Colors.red),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
