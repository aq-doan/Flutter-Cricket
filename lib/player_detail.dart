import 'package:flutter/material.dart';
import 'match.dart';

class PlayerDetail extends StatelessWidget {
  final PlayerStats player;

  const PlayerDetail({Key? key, required this.player}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Player Details"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Name: ${player.name}", style: TextStyle(fontSize: 20)),
            SizedBox(height: 8),
            Text("Runs: ${player.runs}", style: TextStyle(fontSize: 18)),
            SizedBox(height: 8),
            Text("Balls Faced: ${player.ballsFaced}", style: TextStyle(fontSize: 18)),
            SizedBox(height: 8),
            Text("Balls Delivered: ${player.ballsDelivered}", style: TextStyle(fontSize: 18)),
            SizedBox(height: 8),
            Text("Runs Lost: ${player.runsLost}", style: TextStyle(fontSize: 18)),
            SizedBox(height: 8),
            Text("Wickets: ${player.wickets}", style: TextStyle(fontSize: 18)),
          ],
        ),
      ),
    );
  }
}
