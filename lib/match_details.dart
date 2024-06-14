import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'match.dart';
import 'score_recording.dart';
import 'player_detail.dart';

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
  final List<TextEditingController> team1PlayersControllers = List.generate(5, (index) => TextEditingController());
  final List<TextEditingController> team2PlayersControllers = List.generate(5, (index) => TextEditingController());

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
         team1PlayersControllers[i].text = match?.team1Players[i]?.name ?? "Batter ${i + 1}";
      }
      for (int i = 0; i < team2PlayersControllers.length; i++) {
        team2PlayersControllers[i].text = match?.team2Players[i]?.name ?? "Bowler ${i + 1}";
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
        title: Text(adding ? "Add Match" : "Edit Match"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(8),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              if (!adding) Text("Match ID: ${widget.id}"),
              TextFormField(
                decoration: const InputDecoration(labelText: "Team 1"),
                controller: team1Controller,
              ),
              // Add TextFormFields for each player in team 1
              for (var i = 0; i < 5; i++)
                GestureDetector(
                  onTap: () async {
                    if (match != null && i < (match?.team1Players?.length ?? 0)) {
                      var result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PlayerDetail(player: match?.team1Players?[i] ?? PlayerStats(name: "Unknown")),
                        ),
                      );
                
                      if (result == 'update') {
                        setState(() {
                          match = Provider.of<MatchModel>(context, listen: false).get(widget.id);
                        });
                      }
                    }
                  },
                  child: AbsorbPointer(
                    child: TextFormField(
                      decoration: InputDecoration(labelText: "Team 1 Player ${i + 1}"),
                      controller: team1PlayersControllers[i],
                    ),
                  ),
                ),
              TextFormField(
                decoration: const InputDecoration(labelText: "Team 2"),
                controller: team2Controller,
              ),
              // Add TextFormFields for each player in team 2
              for (var i = 0; i < 5; i++)
                GestureDetector(
                  onTap: () async {
                    if (match != null && i < (match?.team2Players?.length ?? 0)) {
                      var result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PlayerDetail(player: match?.team2Players?[i] ?? PlayerStats(name: "Unknown")),
                        ),
                      );
                
                      if (result == 'update') {
                        setState(() {
                          match = Provider.of<MatchModel>(context, listen: false).get(widget.id);
                        });
                      }
                    }
                  },
                  child: AbsorbPointer(
                    child: TextFormField(
                      decoration: InputDecoration(labelText: "Team 2 Player ${i + 1}"),
                      controller: team1PlayersControllers[i],
                    ),
                  ),
                ),
              TextFormField(
                decoration: const InputDecoration(labelText: "Total Runs"),
                controller: runsController,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: "Wickets"),
                controller: wicketsController,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: "Balls Delivered"),
                controller: ballsController,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: "Extras"),
                controller: extrasController,
              ),
              ElevatedButton.icon(
                onPressed: () async {
                  if (_formKey.currentState?.validate() ?? false) {
                    if (adding) {
                      match = Match(
                        team1Name: team1Controller.text,
                        team2Name: team2Controller.text,
                        team1Players: team1PlayersControllers.map((controller) => PlayerStats(name: controller.text)).toList(),
                        team2Players: team2PlayersControllers.map((controller) => PlayerStats(name: controller.text)).toList(),
                      );
                    } else {
                      match!.team1Name = team1Controller.text;
                      match!.team2Name = team2Controller.text;
                      match!.totalRuns = int.parse(runsController.text);
                      match!.wickets = int.parse(wicketsController.text);
                      match!.ballsDelivered = int.parse(ballsController.text);
                      match!.extras = int.parse(extrasController.text);

                      match!.team1Players = team1PlayersControllers.map((controller) => PlayerStats(name: controller.text)).toList();
                      match!.team2Players = team2PlayersControllers.map((controller) => PlayerStats(name: controller.text)).toList();
                    }

                    if (adding) {
                      await Provider.of<MatchModel>(context, listen: false).add(match!);
                    } else {
                      await Provider.of<MatchModel>(context, listen: false).updateItem(widget.id!, match!);
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
                  label: const Text("View Score Recording"),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
