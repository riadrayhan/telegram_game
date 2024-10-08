import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

class Instruction extends StatefulWidget {
  const Instruction({super.key});

  @override
  State<Instruction> createState() => _InstructionState();
}

class _InstructionState extends State<Instruction> {
  String walletAddress = 'Ef_GHcGwnw-bASoxTGQRMNwMQ6w9iCQnTqrv1REDfJ5fCYD2'; // Replace with actual TON wallet address
  final String telegramBotToken = '8145483732:AAFwmO7FRqGScXXybCpRkHU1_HJVpFR_iEE'; // Replace with actual Telegram bot token
  String? chatId; // Auto-fetch chat ID on button click
  double balance = 0.0;

  // Function to connect to TON Wallet (simulated)
  Future<void> _connectTONWallet() async {
    // Simulate connecting to a TON wallet and fetching balance
    final tonWalletApi = 'https://toncenter.com/api/v2/getAddressInformation?address=$walletAddress';

    try {
      final response = await http.get(Uri.parse(tonWalletApi));

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        setState(() {
          balance = data['result']['balance'] / 1000000000; // Convert balance to TON
        });

        print('TON Wallet connected. Balance: $balance TON.');
        _getChatIdAndNotify(); // Notify Telegram
      } else {
        print('Failed to connect to TON Wallet');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  // Fetch chat ID and notify Telegram bot
  Future<void> _getChatIdAndNotify() async {
    final telegramGetUpdatesUrl = 'https://api.telegram.org/bot$telegramBotToken/getUpdates';

    try {
      final response = await http.get(Uri.parse(telegramGetUpdatesUrl));

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);

        if (data['result'].isNotEmpty) {
          setState(() {
            chatId = data['result'][0]['message']['chat']['id'].toString(); // Get chat ID
          });

          print('Chat ID retrieved: $chatId');
          _sendTelegramMessage('Your TON wallet is connected with a balance of $balance TON.');
        } else {
          print('No chat ID found');
        }
      } else {
        print('Failed to get updates from Telegram');
      }
    } catch (e) {
      print('Error getting chat ID: $e');
    }
  }

  // Send a message to Telegram
  Future<void> _sendTelegramMessage(String message) async {
    if (chatId == null) {
      print('Chat ID not available.');
      return;
    }

    final telegramUrl = 'https://api.telegram.org/bot$telegramBotToken/sendMessage';

    try {
      final response = await http.post(
        Uri.parse(telegramUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'chat_id': chatId,
          'text': message,
        }),
      );

      if (response.statusCode == 200) {
        print('Message sent to Telegram');
      } else {
        print('Failed to send message to Telegram: ${response.body}');
      }
    } catch (e) {
      print('Error sending message to Telegram: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('TON Wallet Connection'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text('Connect to TON Wallet'),
            ElevatedButton(
              onPressed: _connectTONWallet,
              child: const Text('Connect Wallet'),
            ),
            const SizedBox(height: 20),
            if (balance > 0) ...[
              const Text('Wallet Balance:'),
              Text(
                '$balance TON',
                style: const TextStyle(fontSize: 24),
              ),
            ]
          ],
        ),
      ),
    );
  }
}