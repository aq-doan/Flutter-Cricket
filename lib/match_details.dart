import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'match.dart';

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

  @override
  Widget build(BuildContext context) {
    var match = Provider.of<MatchModel>(context, listen: false).get(widget.id);
    var adding = match == null;
    if (!adding) {
      team1Controller.text = match.team1Name;
      team2Controller.text = match.team2Name;
      runsController.text = match.totalRuns.toString();
      wicketsController.text = match.wickets.toString();
      ballsController.text = match.ballsDelivered.toString();
      extrasController.text = match.extras.toString();
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(adding ? "Add Match" : "Edit Match"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            if (adding == false) Text("Match ID: ${widget.id}"),
            Form(
              key: _formKey,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: <Widget>[
                    TextFormField(
                      decoration: const InputDecoration(labelText: "Team 1"),
                      controller: team1Controller,
                    ),
                    TextFormField(
                      decoration: const InputDecoration(labelText: "Team 2"),
                      controller: team2Controller,
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
                              team1Name: "",
                              team2Name: "",
                            );
                          }

                          match!.team1Name = team1Controller.text;
                          match!.team2Name = team2Controller.text;
                          match!.totalRuns = int.parse(runsController.text);
                          match!.wickets = int.parse(wicketsController.text);
                          match!.ballsDelivered = int.parse(ballsController.text);
                          match!.extras = int.parse(extrasController.text);

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
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
