import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'match.dart';

class MatchAdd extends StatefulWidget {
  const MatchAdd({Key? key}) : super(key: key);

  @override
  State<MatchAdd> createState() => _MatchAddState();
}

class _MatchAddState extends State<MatchAdd> {
  final _formKey = GlobalKey<FormState>();
  final team1Controller = TextEditingController();
  final team2Controller = TextEditingController();

  // Add controllers for each player in the teams
  final List<TextEditingController> team1PlayersControllers = List.generate(5, (index) => TextEditingController());
  final List<TextEditingController> team2PlayersControllers = List.generate(5, (index) => TextEditingController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add New Match"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Form(
              key: _formKey,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: <Widget>[
                    TextFormField(
                      decoration: const InputDecoration(labelText: "Team 1"),
                      controller: team1Controller,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter team 1 name';
                        }
                        return null;
                      },
                    ),
                    // Add TextFormFields for each player in team 1
                    for (var i = 0; i < 5; i++)
                      TextFormField(
                        decoration: InputDecoration(labelText: "Team 1 Player ${i + 1}"),
                        controller: team1PlayersControllers[i],
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter player name';
                          }
                          return null;
                        },
                      ),
                    TextFormField(
                      decoration: const InputDecoration(labelText: "Team 2"),
                      controller: team2Controller,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter team 2 name';
                        }
                        return null;
                      },
                    ),
                    // Add TextFormFields for each player in team 2
                    for (var i = 0; i < 5; i++)
                      TextFormField(
                        decoration: InputDecoration(labelText: "Team 2 Player ${i + 1}"),
                        controller: team2PlayersControllers[i],
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter player name';
                          }
                          return null;
                        },
                      ),
                    ElevatedButton.icon(
                      onPressed: () async {
                        if (_formKey.currentState?.validate() ?? false) {
                          Match newMatch = Match(
                            team1Name: team1Controller.text,
                            team2Name: team2Controller.text,
                            team1Players: team1PlayersControllers.map((controller) => controller.text).toList(),
                            team2Players: team2PlayersControllers.map((controller) => controller.text).toList(),
                          );
                    
                          await Provider.of<MatchModel>(context, listen: false).add(newMatch);
                    
                          if (context.mounted) Navigator.pop(context);
                        }
                      },
                      icon: const Icon(Icons.save),
                      label: const Text("Add Match"),
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
