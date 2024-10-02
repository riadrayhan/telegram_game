import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  // Your Telegram bot token and Vercel site link
  final String telegramBotToken = '8145483732:AAFwmO7FRqGScXXybCpRkHU1_HJVpFR_iEE';
  final String vercelSiteLink = 'https://telegram-game-24h3.vercel.app'; // Vercel link

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Telegram Game1"),
        centerTitle: true,
        backgroundColor: Colors.orange[100],
      ),
      body: Center(
        child: ColoredBox(
          color: Colors.deepOrangeAccent,
          child: TextButton(
            onPressed: () {
              // Trigger fetching chat ID and sending message when the game starts
              _sendStartGameMessage();
            },
            child: const Text(
              "Let's Start the Game",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ),
      ),
    );
  }

  // Function to fetch chat ID and send a start game message to Telegram via the bot API
  Future<void> _sendStartGameMessage() async {
    final String telegramApiUrl = 'https://api.telegram.org/bot$telegramBotToken/getUpdates';

    try {
      // Fetch updates to get the latest chat ID
      final response = await http.get(Uri.parse(telegramApiUrl));

      if (response.statusCode == 200) {
        // Parse the response to get the chat ID
        final updates = jsonDecode(response.body);

        if (updates['result'].isNotEmpty) {
          // Fetch the chat_id from the latest message
          final chatId = updates['result'].last['message']['chat']['id'].toString();

          // Now send the start game message to the fetched chat ID
          await _sendMessageToTelegram(chatId);
        } else {
          print('No updates found.');
        }
      } else {
        print('Failed to fetch updates. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching updates: $e');
    }
  }

  // Function to send a message with a Web App button to the fetched chat ID
  Future<void> _sendMessageToTelegram(String chatId) async {
    final String telegramApiUrl = 'https://api.telegram.org/bot$telegramBotToken/sendMessage';

    final Map<String, dynamic> messageData = {
      'chat_id': chatId, // Chat ID fetched from the getUpdates API
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
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(messageData),
      );

      if (response.statusCode == 200) {
        print('Message sent successfully!');
      } else {
        print('Failed to send message. Status code: ${response.statusCode}');
        print('Response body: ${response.body}');
      }
    } catch (e) {
      print('Error sending message: $e');
    }
  }
}
