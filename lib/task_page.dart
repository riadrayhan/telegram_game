import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TaskPage extends StatefulWidget {
  final Function(int) onMergePoints;

  const TaskPage({Key? key, required this.onMergePoints}) : super(key: key);

  @override
  State<TaskPage> createState() => _TaskPageState();
}

class _TaskPageState extends State<TaskPage> {
  bool _isButtonActive = false;
  Timer? _timer;
  int _claimedPoints = 0;
  bool _hasClaimedToday = false;
  late SharedPreferences _prefs;

  @override
  void initState() {
    super.initState();
    _initSharedPreferences();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _initSharedPreferences() async {
    _prefs = await SharedPreferences.getInstance();
    await _loadClaimedPoints();
    await _loadHasClaimedToday();
    _checkTime(); // Check time immediately after loading data
  }

  Future<void> _loadClaimedPoints() async {
    setState(() {
      _claimedPoints = _prefs.getInt('claimedPoints') ?? 0;
    });
  }

  Future<void> _loadHasClaimedToday() async {
    final lastClaimDate = _prefs.getString('lastClaimDate');
    final today = DateTime.now().toIso8601String().split('T')[0];
    setState(() {
      _hasClaimedToday = lastClaimDate == today;
    });
  }

  void _startTimer() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      _checkTime();
    });
  }

  void _checkTime() {
    final now = DateTime.now();
    final targetTime = DateTime(now.year, now.month, now.day, 0, 3); // Set to 00:03 (12:03 AM)
    final nextDayTargetTime = targetTime.add(Duration(days: 1)); // For handling time between midnight and 00:03

    if ((now.isAfter(targetTime) && now.isBefore(nextDayTargetTime)) || now.isAfter(nextDayTargetTime)) {
      if (!_hasClaimedToday) {
        setState(() {
          _isButtonActive = true;
        });
      }
    } else {
      setState(() {
        _isButtonActive = false;
      });
    }
  }

  Future<void> _claimPoints() async {
    if (_isButtonActive && !_hasClaimedToday) {
      setState(() {
        _claimedPoints += 100;
        _isButtonActive = false;
        _hasClaimedToday = true;
      });

      await _prefs.setInt('claimedPoints', _claimedPoints);
      final today = DateTime.now().toIso8601String().split('T')[0];
      await _prefs.setString('lastClaimDate', today);
    }
  }

  Future<void> _mergePoints() async {
    widget.onMergePoints(_claimedPoints);
    setState(() {
      _claimedPoints = 0;
    });
    await _prefs.setInt('claimedPoints', 0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Claimed Points: $_claimedPoints"),
        backgroundColor: Colors.greenAccent[100],
        centerTitle: true,
      ),
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              "Claim and Earn your Coin",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          const ListTile(
            title: Text(
              "Daily Bonus",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ),
          ListTile(
            title: const Text("Claim Daily Bonus"),
            leading: const Icon(
              Icons.task,
              color: Colors.green,
            ),
            trailing: ElevatedButton(
              onPressed: (_isButtonActive && !_hasClaimedToday) ? _claimPoints : null,
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(
                    (_isButtonActive && !_hasClaimedToday) ? Colors.green : Colors.red),
              ),
              child: Text(
                'Claim Points',
                style: TextStyle(
                  color: (_isButtonActive && !_hasClaimedToday) ? Colors.white : Colors.black,
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _claimedPoints > 0 ? _mergePoints : null,
            child: const Text("Merge Points to Main Page"),
          ),
        ],
      ),
    );
  }
}