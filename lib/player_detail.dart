import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'match.dart';

class PlayerDetail extends StatefulWidget {
  final PlayerStats player;

  const PlayerDetail({Key? key, required this.player}) : super(key: key);

  @override
  _PlayerDetailState createState() => _PlayerDetailState();
}

class _PlayerDetailState extends State<PlayerDetail> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.player.name);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Player Details"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(labelText: "Name"),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a name';
                  }
                  return null;
                },
              ),
              SizedBox(height: 8),
              Text("Runs: ${widget.player.runs}", style: TextStyle(fontSize: 18)),
              SizedBox(height: 8),
              Text("Balls Faced: ${widget.player.ballsFaced}", style: TextStyle(fontSize: 18)),
              SizedBox(height: 8),
              Text("Balls Delivered: ${widget.player.ballsDelivered}", style: TextStyle(fontSize: 18)),
              SizedBox(height: 8),
              Text("Runs Lost: ${widget.player.runsLost}", style: TextStyle(fontSize: 18)),
              SizedBox(height: 8),
              Text("Wickets: ${widget.player.wickets}", style: TextStyle(fontSize: 18)),
              SizedBox(height: 8),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState?.validate() ?? false) {
                    widget.player.name = _nameController.text;
                    await Provider.of<MatchModel>(context, listen: false).updatePlayer(widget.player);
                    if (context.mounted) Navigator.pop(context, 'update');
                  }
                },
                child: Text("Save"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}