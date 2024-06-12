import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'match.dart';

class ScoreRecording extends StatefulWidget {
  final Match match;

  const ScoreRecording({Key? key, required this.match}) : super(key: key);

  @override
  State<ScoreRecording> createState() => _ScoreRecordingState();
}

class _ScoreRecordingState extends State<ScoreRecording> {
  int currentBatterIndex = 0;
  int nonStrikerIndex = 1;
  int currentBowlerIndex = 0;
  int ballsDelivered = 0;
  int extras = 0;
  bool isGameOver = false; 

  @override
  Widget build(BuildContext context) {
    var match = widget.match;
    return Scaffold(
      appBar: AppBar(
        title: const Text("Score Recording"),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: () async {
              // Save the updated match details
              match.ballsDelivered = ballsDelivered;
              match.extras = extras;
              await Provider.of<MatchModel>(context, listen: false).updateItem(match.id, match);
              Navigator.pop(context); // Navigate back to main page
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Text("BATTING: ${match.team1Name}"),
            Text("BOWLING: ${match.team2Name}"),
            Text("Score: ${match.wickets} / ${match.totalRuns}", style: TextStyle(fontSize: 48)),
            Text("RUN RATE: ${(match.totalRuns / (ballsDelivered / 6)).toStringAsFixed(2)}"),
            Text("OVERS: ${ballsDelivered ~/ 6}.${ballsDelivered % 6}"),
            const Divider(),
            Table(
              border: TableBorder.all(),
              children: [
                TableRow(children: [
                  Text("On-strike Batter", style: TextStyle(fontWeight: FontWeight.bold)),
                  Text("${match.team1Players[currentBatterIndex]}", style: TextStyle(fontWeight: FontWeight.bold)),
                ]),
                TableRow(children: [
                  Text("Off-strike Batter", style: TextStyle(fontWeight: FontWeight.bold)),
                  Text("${match.team1Players[nonStrikerIndex]}", style: TextStyle(fontWeight: FontWeight.bold)),
                ]),
                TableRow(children: [
                  Text("Bowler", style: TextStyle(fontWeight: FontWeight.bold)),
                  Text("${match.team2Players[currentBowlerIndex]}", style: TextStyle(fontWeight: FontWeight.bold)),
                ]),
              ],
            ),
            const Divider(),
            Row(
              children: <Widget>[
                for (var outcome in ["0", "1", "2", "3", "4", "6", "W", "NB", "WD"]) 
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        handleOutcome(outcome);
                      },
                      child: Text(outcome),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void handleOutcome(String outcome) {
    if (isGameOver) return;
    setState(() {
      if (outcome == "W") {
        showWicketDialog();
      } else if (outcome == "NB" || outcome == "WD") {
        widget.match.totalRuns += 1;
        extras += 1;
      } else {
        int runs = int.parse(outcome);
        widget.match.totalRuns += runs;
        if (runs % 2 != 0) {
          swapBatters();
        }
        ballsDelivered += 1;
      }
      
      if (ballsDelivered % 6 == 0 && ballsDelivered != 0) {
        swapBatters();
        currentBowlerIndex = (currentBowlerIndex + 1) % widget.match.team2Players.length;
      }
      
      if (ballsDelivered >= 30 || widget.match.wickets >= 4) {
        showGameOverDialog();
      }

      // Update the match object
      widget.match.ballsDelivered = ballsDelivered;
      widget.match.extras = extras;
    });
  }

  void showWicketDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Wicket"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ElevatedButton(
              onPressed: () => recordWicket("Bowled"),
              child: const Text("Bowled"),
            ),
            ElevatedButton(
              onPressed: () => recordWicket("Caught"),
              child: const Text("Caught"),
            ),
            ElevatedButton(
              onPressed: () => recordWicket("Caught and Bowled"),
              child: const Text("Caught and Bowled"),
            ),
            ElevatedButton(
              onPressed: () => recordWicket("LBW"),
              child: const Text("Leg Before Wicket (LBW)"),
            ),
            ElevatedButton(
              onPressed: () => recordWicket("Run Out"),
              child: const Text("Run Out"),
            ),
            ElevatedButton(
              onPressed: () => recordWicket("Hit Wicket"),
              child: const Text("Hit Wicket"),
            ),
            ElevatedButton(
              onPressed: () => recordWicket("Stumping"),
              child: const Text("Stumping"),
            ),
          ],
        ),
      ),
    );
  }

  void recordWicket(String type) {
    Navigator.pop(context);
    setState(() {
      widget.match.wickets += 1;
      if (widget.match.wickets >= 4) {
        showGameOverDialog();
      } else {
        currentBatterIndex += 1;
      }
    });
  }

  void swapBatters() {
    int temp = currentBatterIndex;
    currentBatterIndex = nonStrikerIndex;
    nonStrikerIndex = temp;
  }

  void showGameOverDialog() {
    setState(() { 
      isGameOver = true; 
    });
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Game Over"),
        content: Text(widget.match.wickets >= 4 ? "All batters are out." : "All overs completed."),
        actions: <Widget>[
          TextButton(
            onPressed: () async {
              // Save the updated match details
              widget.match.ballsDelivered = ballsDelivered;
              widget.match.extras = extras;
              await Provider.of<MatchModel>(context, listen: false).updateItem(widget.match.id, widget.match);
              Navigator.pop(context);
            },
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }
}
