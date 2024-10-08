
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:ton_dart/ton_dart.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';



class WalletPage extends StatefulWidget {
  @override
  _WalletPageState createState() => _WalletPageState();
}

class _WalletPageState extends State<WalletPage> {
  // Method to connect to TON wallet using a deep link
  Future<void> _connectToTonWallet() async {
    final String walletUrl = 'ton://transfer/EQD3_your_wallet_address_sample?amount=1000000000&text=FlutterPayment';

    final Uri tonUri = Uri.parse(walletUrl);

    // Check if the TON wallet link can be launched
    if (await canLaunchUrl(tonUri)) {
      await launchUrl(tonUri);
    } else {
      _showErrorDialog("Could not launch the TON Wallet. Please ensure that you have it installed.");
    }
  }

  // Show error dialog
  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Error"),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("OK"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('TON Wallet Connection'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: _connectToTonWallet, // Connect to TON wallet on button press
          child: Text('Connect to TON Wallet'),
        ),
      ),
    );
  }
}