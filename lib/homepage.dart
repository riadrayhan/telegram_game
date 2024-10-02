import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  final String telegramBotToken = '8145483732:AAFwmO7FRqGScXXybCpRkHU1_HJVpFR_iEE';
  final String vercelSiteLink = 'https://telegram-game-24h3.vercel.app';
  String? _storedChatId;

  @override
  void initState() {
    super.initState();
    _loadStoredChatId();
  }

  Future<void> _loadStoredChatId() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _storedChatId = prefs.getString('chatId');
    });
  }

  Future<void> _storeChatId(String chatId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('chatId', chatId);
    setState(() {
      _storedChatId = chatId;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Telegram Game"),
        centerTitle: true,
        backgroundColor: Colors.orange[100],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: _sendStartGameMessage,
              child: const Text("Let's Start the Game"),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _resetStoredChatId,
              child: const Text("Reset Stored Chat ID"),
            ),
            if (_storedChatId != null)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text("Stored Chat ID: $_storedChatId"),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _sendStartGameMessage() async {
    if (_storedChatId != null) {
      await _sendMessageToTelegram(_storedChatId!);
    } else {
      await _fetchChatIdAndSendMessage();
    }
  }

  Future<void> _fetchChatIdAndSendMessage() async {
    final String telegramApiUrl = 'https://api.telegram.org/bot$telegramBotToken/getUpdates';

    try {
      final response = await http.get(Uri.parse(telegramApiUrl));

      if (response.statusCode == 200) {
        final updates = jsonDecode(response.body);

        if (updates['result'].isNotEmpty) {
          final chatId = updates['result'].last['message']['chat']['id'].toString();
          await _storeChatId(chatId);
          await _sendMessageToTelegram(chatId);
        } else {
          _showAlert('No updates found. Please send a message to the bot first.');
        }
      } else {
        _showAlert('Failed to fetch updates. Status code: ${response.statusCode}');
      }
    } catch (e) {
      _showAlert('Error fetching updates: $e');
    }
  }

  Future<void> _sendMessageToTelegram(String chatId) async {
    final String telegramApiUrl = 'https://api.telegram.org/bot$telegramBotToken/sendMessage';

    final Map<String, dynamic> messageData = {
      'chat_id': chatId,
      'text': 'The game has started! Click the button below to play the game inside Telegram.',
      'reply_markup': jsonEncode({
        'inline_keyboard': [
          [
            {
              'text': 'Play Game',
              'web_app': {
                'url': vercelSiteLink
              }
            }
          ]
        ]
      })
    };

    try {
      final response = await http.post(
        Uri.parse(telegramApiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(messageData),
      );

      if (response.statusCode == 200) {
        _showAlert('Message sent successfully!');
      } else {
        final errorBody = jsonDecode(response.body);
        if (errorBody['error_code'] == 403 && errorBody['description'].contains('blocked by the user')) {
          _showAlert('The bot was blocked by the user. Please unblock the bot and try again.');
          await _resetStoredChatId();
        } else {
          _showAlert('Failed to send message. Status code: ${response.statusCode}\nError: ${errorBody['description']}');
        }
      }
    } catch (e) {
      _showAlert('Error sending message: $e');
    }
  }

  Future<void> _resetStoredChatId() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('chatId');
    setState(() {
      _storedChatId = null;
    });
    _showAlert('Stored Chat ID has been reset.');
  }

  void _showAlert(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Alert'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}