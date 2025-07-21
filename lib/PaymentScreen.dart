import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_upi_india/flutter_upi_india.dart';

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({super.key});

  @override
  _PaymentScreenState createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  String? _upiAddrError;
  final _upiAddressController = TextEditingController();
  final _amountController = TextEditingController();
  bool _isUpiEditable = false;
  List<ApplicationMeta>? _apps;

  @override
  void initState() {
    super.initState();
    _upiAddressController.text = "pixiglam@idfcbank";
    _amountController.text ='1.00';
    _loadApps();
  }

  Future<void> _loadApps() async {
    _apps = await UpiPay.getInstalledUpiApplications(
      statusType: UpiApplicationDiscoveryAppStatusType.all,
    );
    setState(() {});
  }

  @override
  void dispose() {
    _amountController.dispose();
    _upiAddressController.dispose();
    super.dispose();
  }

  Future<void> _onTap(ApplicationMeta app) async {
    final error = _validateUpiAddress(_upiAddressController.text);
    if (error != null) {
      setState(() {
        _upiAddrError = error;
      });
      return;
    }
    setState(() {
      _upiAddrError = null;
    });

    final transactionRef = Random.secure().nextInt(1 << 32).toString();

    final transaction = await UpiPay.initiateTransaction(
      amount: _amountController.text,
      app: app.upiApplication,
      receiverName: 'PIXIGLAM SOFTWARE PRIVATE LIMITED',
      receiverUpiAddress: _upiAddressController.text,
      transactionRef: transactionRef,
      transactionNote: 'UPI Payment',
    );

    // Show result feedback
    if (mounted) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Transaction Status'),
          content: Text(
            'Status: ${transaction.status}\n'
                'Transaction ID: ${transaction.txnId ?? "N/A"}\n'
                'Approval Ref: ${transaction.approvalRefNo ?? "N/A"}',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('OK'),
            )
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Make UPI Payment")),
      body: Container(
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: ListView(
          children: <Widget>[
            _vpa(),
            if (_upiAddrError != null) _vpaError(),
            _amount(),
            if (Platform.isIOS) _submitButton(),
            Platform.isAndroid ? _androidApps() : _iosApps(),
          ],
        ),
      ),
    );
  }

  Widget _vpa() {
    return Container(
      margin: EdgeInsets.only(top: 32),
      child: Row(
        children: <Widget>[
          Expanded(
            child: TextFormField(
              controller: _upiAddressController,
              enabled: _isUpiEditable,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'address@upi',
                labelText: 'Receiving UPI Address',
              ),
            ),
          ),
          IconButton(
            icon: Icon(_isUpiEditable ? Icons.check : Icons.edit),
            onPressed: () {
              setState(() {
                _isUpiEditable = !_isUpiEditable;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _vpaError() {
    return Padding(
      padding: const EdgeInsets.only(top: 4, left: 12),
      child: Text(
        _upiAddrError!,
        style: TextStyle(color: Colors.red),
      ),
    );
  }

  Widget _amount() {
    return Container(
      margin: EdgeInsets.only(top: 32),
      child: Row(
        children: <Widget>[
          Expanded(
            child: TextField(
              controller: _amountController,
              readOnly: true,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Amount',
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _submitButton() {
    return Container(
      margin: EdgeInsets.only(top: 32),
      child: ElevatedButton(
        onPressed: () {
          if (_apps != null && _apps!.isNotEmpty) {
            _onTap(_apps!.first);
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('No UPI apps available')),
            );
          }
        },
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        ),
        child: Text('Initiate Transaction'),
      ),
    );
  }

  Widget _androidApps() {
    if (_apps == null || _apps!.isEmpty) {
      return Padding(
        padding: EdgeInsets.only(top: 32),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    return Container(
      margin: EdgeInsets.only(top: 32, bottom: 32),
      child: Column(
        children: <Widget>[
          Text(
            'Pay Using',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          SizedBox(height: 12),
          _appsGrid(_apps!),
        ],
      ),
    );
  }

  Widget _iosApps() {
    return Container(
      margin: EdgeInsets.only(top: 32, bottom: 32),
      child: Column(
        children: <Widget>[
          Text(
            'UPI will be invoked automatically by your device.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          SizedBox(height: 24),
          if (_apps != null && _apps!.isNotEmpty)
            _appsGrid(_apps!)
          else
            Text('No UPI apps detected.'),
        ],
      ),
    );
  }

  GridView _appsGrid(List<ApplicationMeta> apps) {
    apps.sort((a, b) => a.upiApplication
        .getAppName()
        .toLowerCase()
        .compareTo(b.upiApplication.getAppName().toLowerCase()));

    return GridView.count(
      crossAxisCount: 4,
      shrinkWrap: true,
      mainAxisSpacing: 4,
      crossAxisSpacing: 4,
      physics: NeverScrollableScrollPhysics(),
      children: apps.map((app) {
        return InkWell(
          onTap: () => _onTap(app),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              app.iconImage(48),
              SizedBox(height: 4),
              Text(
                app.upiApplication.getAppName(),
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  String? _validateUpiAddress(String value) {
    if (value.trim().isEmpty) return 'UPI VPA is required.';
    if (!value.contains('@') || value.split('@').length != 2) {
      return 'Invalid UPI VPA format.';
    }
    return null;
  }
}
