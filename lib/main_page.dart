import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:telegram_game/task_page.dart';
import 'package:timer_button/timer_button.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int points = 0; // Main points variable
  bool _isButtonActive = false; // Initially button is inactive
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _loadPoints(); // Load points from shared preferences
    _checkTime(); // Check time to enable/disable button
  }

  @override
  void dispose() {
    _timer?.cancel(); // Cancel the timer when the widget is disposed
    super.dispose();
  }

  // Load points from SharedPreferences
  Future<void> _loadPoints() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      setState(() {
        points = prefs.getInt('points') ?? 0; // Default to 0 if no value is found
        print("Loaded points: $points"); // Debugging print to ensure points are loaded
      });
    } catch (e) {
      print("Error loading points from SharedPreferences: $e");
    }
  }

  // Save points to SharedPreferences
  Future<void> _savePoints() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setInt('points', points);
      print("Saved points: $points"); // Debugging print to ensure points are saved
    } catch (e) {
      print("Error saving points to SharedPreferences: $e");
    }
  }

  // Check if current time is past target time to enable the button
  void _checkTime() {
    final now = DateTime.now();
    final targetTime = DateTime(now.year, now.month, now.day, 21, 15); // Set time to 21:15

    if (now.isAfter(targetTime)) {
      // If it's already past the target time, activate the button
      setState(() {
        _isButtonActive = true;
      });
    } else {
      // Calculate the remaining time until the target time
      final duration = targetTime.difference(now);

      // Schedule a timer to activate the button at the target time
      _timer = Timer(duration, () {
        setState(() {
          _isButtonActive = true;
        });
      });
    }
  }

  // Increment points by 100 and save to SharedPreferences
  void incrementBonus() {
    setState(() {
      points += 100; // Add 100 points
    });
    _savePoints(); // Save points to shared preferences
  }

  // Increment points by 1 and save to SharedPreferences
  void increment() {
    setState(() {
      points++; // Increment by 1
    });
    _savePoints(); // Save points to shared preferences
  }

  // Merge points from TaskPage
  void _mergePoints(int addedPoints) {
    setState(() {
      points += addedPoints; // Add merged points to the total points
    });
    _savePoints(); // Save merged points to SharedPreferences
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.greenAccent[100],
      body: SafeArea(
        child: Column(
          children: [
            Container(
              height: 70,
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                color: Colors.green,
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(40),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Text(
                    "💰 $points", // Display total points value
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
                  ),
                  Text(
                    "🦜 ${points ~/ 100}", // Display birds based on points
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
                  ),
                ],
              ),
            ),
            Stack(
              children: [
                Container(
                  height: 300,
                  width: 500,
                  child: Image.asset('assets/tree.png', fit: BoxFit.fill),
                  color: Colors.greenAccent[100],
                ),
                points >= 100
                    ? Container(
                  height: 60,
                  width: 60,
                  child: Image.asset('assets/p2.png'),
                  margin: const EdgeInsets.only(left: 136, top: 50),
                )
                    : const SizedBox.shrink(),
                points >= 300
                    ? Container(
                  height: 60,
                  width: 60,
                  child: Image.asset('assets/p4.png'),
                  margin: const EdgeInsets.only(left: 260, top: 98),
                )
                    : const SizedBox.shrink(),
                points >= 500
                    ? Container(
                  height: 60,
                  width: 60,
                  child: Image.asset('assets/p3.png'),
                  margin: const EdgeInsets.only(left: 150, top: 128),
                )
                    : const SizedBox.shrink(),
                points >= 800
                    ? Container(
                  height: 60,
                  width: 60,
                  child: Image.asset('assets/p1.png'),
                  margin: const EdgeInsets.only(left: 228, top: 148),
                )
                    : const SizedBox.shrink(),
              ],
            ),
            GestureDetector(
              onTap: () {
                increment(); // Increment points by 1
              },
              child: Container(
                height: 200,
                width: 200,
                margin: const EdgeInsets.only(top: 15),
                child: Image.asset('assets/parrot.gif', fit: BoxFit.fill),
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.all(Radius.circular(100)),
                  border: Border.all(width: 3, color: const Color(0xFF1E5E03)),
                  color: Colors.green,
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                TimerButton(
                  label: "Claim Points",
                  timeOutInSeconds: 50,
                  onPressed: () {
                    incrementBonus(); // Increment points by 100
                  },
                  buttonType: ButtonType.outlinedButton,
                  disabledColor: Colors.deepOrange,
                  color: Colors.green,
                  activeTextStyle: const TextStyle(color: Colors.black87),
                  disabledTextStyle: const TextStyle(color: Colors.pink),
                ),
                IconButton(
                  onPressed: points >= 1000 ? () {} : null,
                  icon: Icon(
                    Icons.offline_bolt,
                    size: 60,
                    color: points >= 1000 ? Colors.green : Colors.red,
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    // Navigate to TaskPage and pass the _mergePoints function as the callback
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => TaskPage(onMergePoints: _mergePoints),
                      ),
                    );
                  },
                  child: const Text("Go to Task Page"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
