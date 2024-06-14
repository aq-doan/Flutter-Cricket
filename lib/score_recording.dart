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
  late Match match;
  int currentBatterIndex = 0;
  int nonStrikerIndex = 1;
  int currentBowlerIndex = 0;
  int ballsDelivered = 0;
  int extras = 0;
  bool isGameOver = false;
  List<Match> matchHistory = [];

  @override
  void initState() {
    super.initState();
    match = widget.match.copy();
    ballsDelivered = match.ballsDelivered;
    extras = match.extras;
    matchHistory.add(match.copy());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Score Recording"),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: () async {
              // Save the updated match details
              updateMatchDetails();
              await Provider.of<MatchModel>(context, listen: false).updateItem(match.id, match);
              Navigator.popUntil(context, ModalRoute.withName('/')); // Navigate back to main page
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(8),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Text("BATTING: ${match.team1Name}"),
                Text("BOWLING: ${match.team2Name}"),
                Text("Score: ${match.wickets} / ${match.totalRuns}", style: TextStyle(fontSize: 48)),
                Text("RUN RATE: ${(match.totalRuns / (ballsDelivered / 6)).toStringAsFixed(2)}"),
                Text("OVERS: ${ballsDelivered ~/ 6}.${ballsDelivered % 6}"),
                Text("EXTRAS: ${match.extras}"),
                const Divider(),
                Table(
                  children: [
                    TableRow(children: [
                      Text("On-strike Batter", style: TextStyle(fontWeight: FontWeight.bold)),
                      Text("${match.team1Players[currentBatterIndex].name}", style: TextStyle(fontWeight: FontWeight.bold)),
                      Text("Runs: ${match.team1Players[currentBatterIndex].runs}"),
                      Text("Balls: ${match.team1Players[currentBatterIndex].ballsFaced}"),
                      Text(""), // Added this line
                    ]),
                    TableRow(children: [
                      Text("Off-strike Batter", style: TextStyle(fontWeight: FontWeight.bold)),
                      Text("${match.team1Players[nonStrikerIndex].name}", style: TextStyle(fontWeight: FontWeight.bold)),
                      Text("Runs: ${match.team1Players[nonStrikerIndex].runs}"),
                      Text("Balls: ${match.team1Players[nonStrikerIndex].ballsFaced}"),
                      Text(""), // Added this line
                    ]),
                    TableRow(children: [
                      Text("Bowler", style: TextStyle(fontWeight: FontWeight.bold)),
                      Text("${match.team2Players[currentBowlerIndex].name}", style: TextStyle(fontWeight: FontWeight.bold)),
                      Text("Lost: ${match.team2Players[currentBowlerIndex].runsLost}"),
                      Text("Wickets: ${match.team2Players[currentBowlerIndex].wickets}"),
                      Text("Balls: ${match.team2Players[currentBowlerIndex].ballsDelivered}"),
                    ]),
                  ],
                ),
                const Divider(),
                Text("Ball Outcome:", style: TextStyle(fontWeight: FontWeight.bold)),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: match.ballOutcomes.map((outcome) => Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4.0),
                      child: Chip(
                        label: Text("${outcome.description} (Batter: ${outcome.batter}, Bowler: ${outcome.bowler})"),
                      ),
                    )).toList(),
                  ),
                ),
                const Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    for (var outcome in ["0", "1", "2"])
                      Expanded(
                        child: Container(
                          margin: EdgeInsets.symmetric(horizontal: 4),
                          child: ElevatedButton(
                            onPressed: match.isCompleted ? null : () {
                              handleOutcome(outcome);
                            },
                            child: Center(
                              child: Text(outcome),
                            ),
                            style: ElevatedButton.styleFrom(
                              shape: CircleBorder(),
                              padding: EdgeInsets.all(16),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    for (var outcome in ["3", "4", "6"])
                      Expanded(
                        child: Container(
                          margin: EdgeInsets.symmetric(horizontal: 4),
                          child: ElevatedButton(
                            onPressed: match.isCompleted ? null : () {
                              handleOutcome(outcome);
                            },
                            child: Center(
                              child: Text(outcome),
                            ),
                            style: ElevatedButton.styleFrom(
                              shape: CircleBorder(),
                              padding: EdgeInsets.all(16),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    for (var outcome in ["W", "NB", "WD"])
                      Expanded(
                        child: Container(
                          margin: EdgeInsets.symmetric(horizontal: 4),
                          child: ElevatedButton(
                            onPressed: match.isCompleted ? null : () {
                              handleOutcome(outcome);
                            },
                            child: Center(
                              child: Text(outcome),
                            ),
                            style: ElevatedButton.styleFrom(
                              shape: CircleBorder(),
                              padding: EdgeInsets.all(16),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: resetMatch,
                    child: Text("Reset"),
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(),
                      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: undoLastAction,
                    child: Text("Undo"),
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(),
                      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void handleOutcome(String outcome) {
    if (isGameOver) return;
    setState(() {
      // Save the current state before making changes
      matchHistory.add(match.copy());

      var currentBatter = match.team1Players[currentBatterIndex];
      var currentBowler = match.team2Players[currentBowlerIndex];
      BallOutcome ballOutcome;

      if (outcome == "W") {
        showWicketDialog();
      } else if (outcome == "NB" || outcome == "WD") {
        match.totalRuns += 1;
        extras += 1;
        currentBowler.runsLost += 1;
        ballOutcome = BallOutcome(
          type: "extra",
          description: outcome == "NB" ? "No Ball" : "Wide",
          batter: currentBatter.name,
          bowler: currentBowler.name,
        );
        match.ballOutcomes.add(ballOutcome);
      } else {
        int runs = int.parse(outcome);
        match.totalRuns += runs;
        currentBatter.runs += runs;
        currentBatter.ballsFaced += 1;
        currentBowler.runsLost += runs;
        currentBowler.ballsDelivered += 1;
        ballsDelivered += 1;
        ballOutcome = BallOutcome(
          type: "run",
          runs: runs,
          description: "Run $runs",
          batter: currentBatter.name,
          bowler: currentBowler.name,
        );
        match.ballOutcomes.add(ballOutcome);

        if (ballsDelivered % 6 == 0) {
          // End of over, swap batters and bowler
          swapBatters();
          currentBowlerIndex = (currentBowlerIndex + 1) % match.team2Players.length;
        }

        if (runs % 2 != 0) {
          // Odd runs, swap batters
          swapBatters();
        }

        // End of over, swap batters again
        if (ballsDelivered % 6 == 0) {
          swapBatters();
        }
      }

      if (ballsDelivered >= 30 || match.wickets >= 4) {
        showGameOverDialog();
      }

      // Update the match object
      match.ballsDelivered = ballsDelivered;
      match.extras = extras;
    });
  }

  void resetMatch() {
    setState(() {
      match.reset(); // Assume you have a reset method in Match class
      ballsDelivered = 0;
      extras = 0;
      isGameOver = false;
      currentBatterIndex = 0;
      nonStrikerIndex = 1;
      currentBowlerIndex = 0;
      matchHistory.clear();
      matchHistory.add(match.copy());
    });
  }

  void undoLastAction() {
    if (matchHistory.length > 1) {
      setState(() {
        matchHistory.removeLast();
        match = matchHistory.last.copy();
        ballsDelivered = match.ballsDelivered;
        extras = match.extras;
        // Restore other states if needed
      });
    }
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
      var currentBowler = match.team2Players[currentBowlerIndex];
      currentBowler.wickets += 1;
      match.wickets += 1;
      BallOutcome ballOutcome = BallOutcome(
        type: "wicket",
        description: type,
        batter: match.team1Players[currentBatterIndex].name,
        bowler: currentBowler.name,
      );
      match.ballOutcomes.add(ballOutcome);
      if (match.wickets >= 4) {
        showGameOverDialog();
      } else {
        currentBatterIndex += 1;
        if (currentBatterIndex >= match.team1Players.length) {
          currentBatterIndex = 0;
        }
      }
    });
  }

  void swapBatters() {
    currentBatterIndex = (currentBatterIndex + 1) % match.team1Players.length;
    nonStrikerIndex = (currentBatterIndex + 1) % match.team1Players.length;
  }

  void showGameOverDialog() {
    setState(() {
      isGameOver = true;
    });
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Game Over"),
        content: Text(match.wickets >= 4 ? "All batters are out." : "All overs completed."),
        actions: <Widget>[
          TextButton(
            onPressed: () async {
              updateMatchDetails();
              match.isCompleted = true;
              await Provider.of<MatchModel>(context, listen: false).updateItem(match.id, match);
              Navigator.popUntil(context, ModalRoute.withName('/')); // Navigate back to main page
            },
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  void updateMatchDetails() {
    match.ballsDelivered = ballsDelivered;
    match.extras = extras;
    match.runRate = (match.totalRuns / (ballsDelivered / 6)).toDouble();
    match.overs = "${ballsDelivered ~/ 6}.${ballsDelivered % 6}";
  }
}
