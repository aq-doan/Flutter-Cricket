import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share/share.dart';
import 'match.dart';
import 'player_detail.dart';
import 'score_recording.dart';
import 'dart:convert';

class MatchDetails extends StatefulWidget {
  final String? id;

  const MatchDetails({Key? key, this.id}) : super(key: key);

  @override
  State<MatchDetails> createState() => _MatchDetailsState();
}

class _MatchDetailsState extends State<MatchDetails> {
  final _formKey = GlobalKey<FormState>();
  final team1Controller = TextEditingController();
  final team2Controller = TextEditingController();
  final runsController = TextEditingController();
  final wicketsController = TextEditingController();
  final ballsController = TextEditingController();
  final extrasController = TextEditingController();

  // Add controllers for each player in the teams
  final List<TextEditingController> team1PlayersControllers =
      List.generate(5, (index) => TextEditingController());
  final List<TextEditingController> team2PlayersControllers =
      List.generate(5, (index) => TextEditingController());

  @override
  Widget build(BuildContext context) {
    var match = Provider.of<MatchModel>(context, listen: false).get(widget.id);
    var adding = match == null;

    if (match != null) {
      team1Controller.text = match.team1Name;
      team2Controller.text = match.team2Name;
      runsController.text = match.totalRuns.toString();
      wicketsController.text = match.wickets.toString();
      ballsController.text = match.ballsDelivered.toString();
      extrasController.text = match.extras.toString();

      for (int i = 0; i < team1PlayersControllers.length; i++) {
        team1PlayersControllers[i].text =
            match.team1Players[i]?.name ?? "Batter ${i + 1}";
      }
      for (int i = 0; i < team2PlayersControllers.length; i++) {
        team2PlayersControllers[i].text =
            match.team2Players[i]?.name ?? "Bowler ${i + 1}";
      }
    } else {
      for (int i = 0; i < team1PlayersControllers.length; i++) {
        team1PlayersControllers[i].text = "Batter ${i + 1}";
      }
      for (int i = 0; i < team2PlayersControllers.length; i++) {
        team2PlayersControllers[i].text = "Bowler ${i + 1}";
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(adding ? "Add Match" : "Match Details"),
        actions: [
          if (match != null)
            IconButton(
              icon: Icon(Icons.share),
              onPressed: () {
                _shareBallOutcomesAsCSV(match!);
              },
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(8),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              if (!adding) Text("Match ID: ${widget.id}"),
              const SizedBox(height: 16),
              Text(
                "${match?.team1Name} vs ${match?.team2Name}",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              Text(
                "Score: ${match?.wickets} / ${match?.totalRuns}",
                style: TextStyle(fontSize: 24),
              ),
              Text(
                "RUN RATE: ${(match?.totalRuns ?? 0 / ((match?.ballsDelivered ?? 1) / 6)).toStringAsFixed(2)}",
              ),
              Text(
                "OVERS: ${(match?.ballsDelivered ?? 0) ~/ 6}.${(match?.ballsDelivered ?? 0) % 6}",
              ),
              Text("EXTRAS: ${match?.extras}"),
              const Divider(),
              const Text(
                "Ball Outcomes:",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: match?.ballOutcomes
                          .map((outcome) => Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 4.0),
                                child: Chip(
                                  label: Text(
                                      "${outcome.description} (Batter: ${outcome.batter}, Bowler: ${outcome.bowler})"),
                                ),
                              ))
                          .toList() ??
                      [],
                ),
              ),
              const Divider(),
              TextFormField(
                controller: team1Controller,
                decoration: InputDecoration(labelText: "Team 1 Name"),
              ),
              const Text(
                "Team 1 Players",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              for (var i = 0; i < 5; i++)
                TextFormField(
                  controller: team1PlayersControllers[i],
                  decoration: InputDecoration(labelText: "Player ${i + 1}"),
                ),
              const Divider(),
              TextFormField(
                controller: team2Controller,
                decoration: InputDecoration(labelText: "Team 2 Name"),
              ),
              const Text(
                "Team 2 Players",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              for (var i = 0; i < 5; i++)
                TextFormField(
                  controller: team2PlayersControllers[i],
                  decoration: InputDecoration(labelText: "Player ${i + 1}"),
                ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton.icon(
                    onPressed: () async {
                      if (_formKey.currentState?.validate() ?? false) {
                        if (adding) {
                          match = Match(
                            team1Name: team1Controller.text,
                            team2Name: team2Controller.text,
                            team1Players: team1PlayersControllers
                                .map((controller) =>
                                    PlayerStats(name: controller.text))
                                .toList(),
                            team2Players: team2PlayersControllers
                                .map((controller) =>
                                    PlayerStats(name: controller.text))
                                .toList(),
                          );
                        } else {
                          match!.team1Name = team1Controller.text;
                          match!.team2Name = team2Controller.text;
                          match!.totalRuns = int.parse(runsController.text);
                          match!.wickets = int.parse(wicketsController.text);
                          match!.ballsDelivered =
                              int.parse(ballsController.text);
                          match!.extras = int.parse(extrasController.text);

                          match!.team1Players = team1PlayersControllers
                              .map((controller) =>
                                  PlayerStats(name: controller.text))
                              .toList();
                          match!.team2Players = team2PlayersControllers
                              .map((controller) =>
                                  PlayerStats(name: controller.text))
                              .toList();
                        }

                        if (adding) {
                          await Provider.of<MatchModel>(context, listen: false)
                              .add(match!);
                        } else {
                          await Provider.of<MatchModel>(context, listen: false)
                              .updateItem(widget.id!, match!);
                        }

                        if (context.mounted) Navigator.pop(context);
                      }
                    },
                    icon: const Icon(Icons.save),
                    label: const Text("Save Values"),
                  ),
                  if (!adding)
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ScoreRecording(match: match!),
                          ),
                        );
                      },
                      icon: const Icon(Icons.visibility),
                      label: const Text("Score Recording"),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _shareBallOutcomesAsCSV(Match match) {
    final buffer = StringBuffer();
    buffer.writeln('type,runs,description,batter,bowler');
    for (var outcome in match.ballOutcomes) {
      buffer.writeln('${outcome.type},${outcome.runs},${outcome.description},${outcome.batter},${outcome.bowler}');
    }
    Share.share(buffer.toString(), subject: 'Ball Outcomes');
  }
}
