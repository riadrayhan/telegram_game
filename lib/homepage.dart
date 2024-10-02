import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  // Your Telegram bot token and Render site link
  final String telegramBotToken = '<YOUR_TELEGRAM_BOT_TOKEN>';
  final String renderSiteLink = '<YOUR_RENDER_SITE_LINK>'; // The link provided by Render after deploying the app
  final String chatId = '<YOUR_CHAT_ID>'; // Replace with chat ID or dynamically get it if necessary

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Telegram Game"),
        centerTitle: true,
        backgroundColor: Colors.orange[100],
      ),
      body: Center(
        child: ColoredBox(
          color: Colors.deepOrangeAccent,
          child: TextButton(
            onPressed: () {
              // Trigger Telegram bot message when the game starts
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

  // Function to send a start game message to Telegram via the bot API
  Future<void> _sendStartGameMessage() async {
    final String telegramApiUrl = 'https://api.telegram.org/bot$telegramBotToken/sendMessage';

    // Sending a message via the bot to notify the user the game has started
    final response = await http.post(
      Uri.parse(telegramApiUrl),
      body: {
        'chat_id': chatId, // Chat ID where the message will be sent
        'text': 'The game has started! Visit $renderSiteLink to play the game.',
      },
    );

    if (response.statusCode == 200) {
      print('Message sent successfully!');
    } else {
      print('Failed to send message. Status code: ${response.statusCode}');
    }
  }
}
