import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share/share.dart';
import 'match.dart';
import 'player_detail.dart';
import 'score_recording.dart';

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

  List<Match> matchHistory = [];
  List<PlayerStats> filteredTeam1Players = [];
  List<PlayerStats> filteredTeam2Players = [];

  bool isTeam1Filtered = false;
  bool isTeam2Filtered = false;

  final List<TextEditingController> team1PlayersControllers =
      List.generate(5, (index) => TextEditingController());
  final List<TextEditingController> team2PlayersControllers =
      List.generate(5, (index) => TextEditingController());

  @override
  void initState() {
    super.initState();
    var match = Provider.of<MatchModel>(context, listen: false).get(widget.id);
    if (match != null) {
      matchHistory.add(match.copy());
      filteredTeam1Players = List.from(match.team1Players);
      filteredTeam2Players = List.from(match.team2Players);
    }
  }

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
      for (int i = 0; i < match.team1Players.length; i++) {
        team1PlayersControllers[i].text = match.team1Players[i].name;
      }
      for (int i = 0; i < match.team2Players.length; i++) {
        team2PlayersControllers[i].text = match.team2Players[i].name;
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
              Padding(
                padding: const EdgeInsets.only(left: 16.0),
                child: Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: team1Controller,
                        style: TextStyle(fontWeight: FontWeight.bold),
                        decoration: InputDecoration(
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(isTeam1Filtered ? Icons.filter_alt_off : Icons.filter_alt),
                      onPressed: () {
                        _toggleFilterPlayers(true);
                      },
                    ),
                  ],
                ),
              ),
              for (var i = 0; i < filteredTeam1Players.length; i++)
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () async {
                          if (match != null &&
                              i < (filteredTeam1Players.length)) {
                            var result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => PlayerDetail(
                                    player: filteredTeam1Players[i]),
                              ),
                            );

                            if (result == 'update') {
                              setState(() {
                                match = Provider.of<MatchModel>(context,
                                        listen: false)
                                    .get(widget.id);
                              });
                            }
                          }
                        },
                        child: AbsorbPointer(
                          child: ListTile(
                            title: Text(filteredTeam1Players[i].name),
                            subtitle: Text(
                                "Runs: ${filteredTeam1Players[i].runs} - Balls: ${filteredTeam1Players[i].ballsFaced}"),
                          ),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.clear),
                      onPressed: () {
                        _deletePlayer(match, i, true);
                      },
                    ),
                  ],
                ),
              const Divider(),
              Padding(
                padding: const EdgeInsets.only(left: 16.0),
                child: Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: team2Controller,
                        style: TextStyle(fontWeight: FontWeight.bold),
                        decoration: InputDecoration(
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(isTeam2Filtered ? Icons.filter_alt_off : Icons.filter_alt),
                      onPressed: () {
                        _toggleFilterPlayers(false);
                      },
                    ),
                  ],
                ),
              ),
              for (var i = 0; i < filteredTeam2Players.length; i++)
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () async {
                          if (match != null &&
                              i < (filteredTeam2Players.length)) {
                            var result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => PlayerDetail(
                                    player: filteredTeam2Players[i]),
                              ),
                            );

                            if (result == 'update') {
                              setState(() {
                                match = Provider.of<MatchModel>(context,
                                        listen: false)
                                    .get(widget.id);
                              });
                            }
                          }
                        },
                        child: AbsorbPointer(
                          child: ListTile(
                            title: Text(filteredTeam2Players[i].name),
                            subtitle: Text(
                                "Lost: ${filteredTeam2Players[i].runsLost} - Wickets: ${filteredTeam2Players[i].wickets} - Balls: ${filteredTeam2Players[i].ballsDelivered}"),
                          ),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.clear),
                      onPressed: () {
                        _deletePlayer(match, i, false);
                      },
                    ),
                  ],
                ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton.icon(
                    onPressed: () async {
                      if (_formKey.currentState?.validate() ?? false) {
                        setState(() {
                          matchHistory.add(match!.copy());
                        });

                        if (adding) {
                          match = Match(
                            team1Name: team1Controller.text,
                            team2Name: team2Controller.text,
                            totalRuns: int.parse(runsController.text),
                            wickets: int.parse(wicketsController.text),
                            ballsDelivered: int.parse(ballsController.text),
                            extras: int.parse(extrasController.text),
                            team1Players: team1PlayersControllers
                                .map((controller) =>
                                    PlayerStats(name: controller.text))
                                .toList(),
                            team2Players: team2PlayersControllers
                                .map((controller) =>
                                    PlayerStats(name: controller.text))
                                .toList(),
                            ballOutcomes: [],
                          );
                          await Provider.of<MatchModel>(context, listen: false)
                              .add(match!);
                        } else {
                          match!.team1Name = team1Controller.text;
                          match!.team2Name = team2Controller.text;
                          match!.totalRuns = int.parse(runsController.text);
                          match!.wickets = int.parse(wicketsController.text);
                          match!.ballsDelivered =
                              int.parse(ballsController.text);
                          match!.extras = int.parse(extrasController.text);

                          for (int i = 0; i < team1PlayersControllers.length; i++) {
                            match!.team1Players[i].name = team1PlayersControllers[i].text;
                          }
                          for (int i = 0; i < team2PlayersControllers.length; i++) {
                            match!.team2Players[i].name = team2PlayersControllers[i].text;
                          }

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
  //implemented by GPT
  void _deletePlayer(Match? match, int index, bool isTeam1) {
    if (match == null) return;
    PlayerStats player =
        isTeam1 ? match.team1Players[index] : match.team2Players[index];

    if (player.runs != 0 ||
        player.ballsFaced != 0 ||
        player.ballsDelivered != 0 ||
        player.runsLost != 0 ||
        player.wickets != 0) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text("Cannot Delete Player"),
          content: Text(
              "This player has recorded statistics and cannot be deleted."),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("OK"),
            ),
          ],
        ),
      );
      return;
    }
    //implemented by GPT
    setState(() {
      if (isTeam1) {
        match.team1Players.removeAt(index);
        filteredTeam1Players.removeAt(index);
        String playerName = "Player ${String.fromCharCode(65 + index)}";
        while (match.team1Players.any((player) => player.name == playerName)) {
          index++;
          playerName = "Player ${String.fromCharCode(65 + index)}";
        }
        match.team1Players.add(PlayerStats(name: playerName));
        filteredTeam1Players.add(PlayerStats(name: playerName));
      } else {
        match.team2Players.removeAt(index);
        filteredTeam2Players.removeAt(index);
        String playerName = "Player ${String.fromCharCode(65 + index)}";
        while (match.team2Players.any((player) => player.name == playerName)) {
          index++;
          playerName = "Player ${String.fromCharCode(65 + index)}";
        }
        match.team2Players.add(PlayerStats(name: playerName));
        filteredTeam2Players.add(PlayerStats(name: playerName));
      }
      matchHistory.add(match.copy());
    });
  }
  //implemented by GPT
  void _toggleFilterPlayers(bool isTeam1) {
    setState(() {
      if (isTeam1) {
        if (isTeam1Filtered) {
          filteredTeam1Players = List.from(matchHistory.last.team1Players);
        } else {
          filteredTeam1Players = matchHistory.last.team1Players
              .where((player) => player.runs != 0 || player.ballsFaced != 0)
              .toList();
        }
        isTeam1Filtered = !isTeam1Filtered;
      } else {
        if (isTeam2Filtered) {
          filteredTeam2Players = List.from(matchHistory.last.team2Players);
        } else {
          filteredTeam2Players = matchHistory.last.team2Players
              .where((player) =>
                  player.ballsDelivered != 0 || player.runsLost != 0)
              .toList();
        }
        isTeam2Filtered = !isTeam2Filtered;
      }
    });
  }
}
