import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'match_details.dart';
import 'match_add.dart';  // Import the new MatchAdd page
import 'match.dart';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();

  var app = await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  print("\n\nConnected to Firebase App ${app.options.projectId}\n\n");

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
        create: (context) => MatchModel(),
        child: MaterialApp(
            title: 'Cricket Scoring App',
            theme: ThemeData(
              primarySwatch: Colors.blue,
            ),
            home: const MyHomePage(title: 'Cricket Scoring App')));
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Consumer<MatchModel>(builder: buildScaffold);
  }

  Scaffold buildScaffold(BuildContext context, MatchModel matchModel, _) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => const MatchAdd())); // Navigate to MatchAdd page
        },
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            if (matchModel.loading)
              const CircularProgressIndicator()
            else
              Expanded(
                child: ListView.builder(
                  itemBuilder: (_, index) {
                    var match = matchModel.items[index];
                    return Dismissible(
                      key: Key(match.id),
                      onDismissed: (direction) {
                        matchModel.delete(match.id);
                      },
                      child: ListTile(
                        title: Text(match.team1Name),
                        subtitle: Text("VS ${match.team2Name}"),
                        onTap: () {
                          Navigator.push(context,
                              MaterialPageRoute(builder: (context) {
                            return MatchDetails(id: match.id);
                          }));
                        },
                      ),
                    );
                  },
                  itemCount: matchModel.items.length,
                ),
              )
          ],
        ),
      ),
    );
  }
}

class FullScreenText extends StatelessWidget {
  final String text;

  const FullScreenText({Key? key, required this.text}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Directionality(
        textDirection: TextDirection.ltr,
        child: Column(children: [Expanded(child: Center(child: Text(text)))]));
  }
}
