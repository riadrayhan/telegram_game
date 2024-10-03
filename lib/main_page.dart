import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:timer_button/timer_button.dart';


class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int points=0;

  void increment(){
    setState(() {
      points++;
    });
  }
  void incrementBonus(){
    setState(() {
      points=points+100;
    });
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
                  borderRadius: BorderRadius.vertical(
                      bottom: Radius.circular(40)
                  )
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Text("💰 $points",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 22),),
                  Text(
                    "🦜 ${points ~/ 100}", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22,),
                  ),
                ],
              ),
            ),
            Stack(
              children: [
                Container(
                  height: 300,
                  width: 500,
                  child: Image.asset('assets/tree.png',fit: BoxFit.fill,),
                  color: Colors.greenAccent[100],

                ),
                //=============visible bird start============//
                points>=100?Container(
                  height: 60,
                  width: 60,
                  child: Image.asset('assets/p2.png'),
                  margin: EdgeInsets.only(left: 136,top: 50),
                ):SizedBox.shrink(),

                points>=300?Container(
                  height: 60,
                  width: 60,
                  child: Image.asset('assets/p4.png'),
                  margin: EdgeInsets.only(left: 260,top: 98),
                ):SizedBox.shrink(),

                points>=500?Container(
                  height: 60,
                  width: 60,
                  child: Image.asset('assets/p3.png'),
                  margin: EdgeInsets.only(left: 150,top: 128),
                ):SizedBox.shrink(),

                points>=800?Container(
                  height: 60,
                  width: 60,
                  child: Image.asset('assets/p1.png'),
                  margin: EdgeInsets.only(left: 228,top: 148),
                ):SizedBox.shrink(),

                //=============visible bird end============//
              ],
            ),

            GestureDetector(
              onTap: () {
                increment();
              },
              child: Container(
                height: 200,
                width: 200,
                margin: EdgeInsets.only(top: 15),
                child: Image.asset('assets/parrot.gif',fit: BoxFit.fill,),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(100)),
                    border: Border.all(width: 3,color: Color(0xFF1E5E03),),
                    color: Colors.green
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                TimerButton(
                  label: "Claim Points ",
                  timeOutInSeconds: 100,
                  onPressed: () {
                  incrementBonus();
                  },
                  buttonType: ButtonType.outlinedButton,
                  disabledColor: Colors.deepOrange,
                  color: Colors.green,
                  activeTextStyle: const TextStyle(color: Colors.black87),
                  disabledTextStyle: const TextStyle(color: Colors.pink),
                ),

                IconButton(
                  onPressed: points >= 1000
                      ? () {
                  }
                  : null,
                  icon: Icon(
                    Icons.offline_bolt,
                    size: 60,
                    color: points >= 1000 ? Colors.green : Colors.red,
                  ),
                )

              ],
            ),

          ],
        ),
      ),
    );
  }
}
