import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class BallOutcome {
  String type; // "run", "dot", "extra", "wicket"
  int runs; // Number of runs, 0 if type is "dot" or "wicket"
  String description; // Detailed description like "Run 3", "Wide", "Caught", etc.
  String batter;
  String bowler;

  BallOutcome({
    required this.type,
    this.runs = 0,
    required this.description,
    required this.batter,
    required this.bowler,
  });

  BallOutcome.fromJson(Map<String, dynamic> json)
      : type = json['type'],
        runs = json['runs'],
        description = json['description'],
        batter = json['batter'],
        bowler = json['bowler'];

  Map<String, dynamic> toJson() => {
        'type': type,
        'runs': runs,
        'description': description,
        'batter': batter,
        'bowler': bowler,
      };
}

class PlayerStats {
  String name;
  int runs;
  int ballsFaced;
  int ballsDelivered;
  int runsLost;
  int wickets;

  PlayerStats({
    required this.name,
    this.runs = 0,
    this.ballsFaced = 0,
    this.ballsDelivered = 0,
    this.runsLost = 0,
    this.wickets = 0,
  });

  PlayerStats.fromJson(Map<String, dynamic> json)
      : name = json['name'],
        runs = json['runs'],
        ballsFaced = json['ballsFaced'],
        ballsDelivered = json['ballsDelivered'],
        runsLost = json['runsLost'],
        wickets = json['wickets'];

  Map<String, dynamic> toJson() => {
        'name': name,
        'runs': runs,
        'ballsFaced': ballsFaced,
        'ballsDelivered': ballsDelivered,
        'runsLost': runsLost,
        'wickets': wickets,
      };
}

class Match {
  String id;
  String team1Name;
  String team2Name;
  List<PlayerStats> team1Players;
  List<PlayerStats> team2Players;
  int totalRuns;
  int wickets;
  int ballsDelivered;
  int extras;
  double runRate;
  String overs;
  bool isCompleted;
  List<BallOutcome> ballOutcomes;

  Match({
    required this.team1Name,
    required this.team2Name,
    List<PlayerStats>? team1Players,
    List<PlayerStats>? team2Players,
    this.totalRuns = 0,
    this.wickets = 0,
    this.ballsDelivered = 0,
    this.extras = 0,
    this.runRate = 0.0,
    this.overs = "0.0",
    this.isCompleted = false,
    List<BallOutcome>? ballOutcomes,
  })  : id = "",
        team1Players = team1Players ?? List.generate(5, (index) => PlayerStats(name: "Batter ${index + 1}")),
        team2Players = team2Players ?? List.generate(5, (index) => PlayerStats(name: "Bowler ${index + 1}")),
        ballOutcomes = ballOutcomes ?? [];

  Match.fromJson(Map<String, dynamic> json, this.id)
      : team1Name = json['team1Name'],
        team2Name = json['team2Name'],
        team1Players = (json['team1Players'] as List?)
                ?.map((item) => PlayerStats.fromJson(item))
                .toList() ??
            List.generate(5, (index) => PlayerStats(name: "Batter ${index + 1}")),
        team2Players = (json['team2Players'] as List?)
                ?.map((item) => PlayerStats.fromJson(item))
                .toList() ??
            List.generate(5, (index) => PlayerStats(name: "Bowler ${index + 1}")),
        totalRuns = json['totalRuns'],
        wickets = json['wickets'],
        ballsDelivered = json['ballsDelivered'],
        extras = json['extras'],
        runRate = json['runRate'],
        overs = json['overs'],
        isCompleted = json['isCompleted'],
        ballOutcomes = (json['ballOutcomes'] as List?)
                ?.map((item) => BallOutcome.fromJson(item))
                .toList() ??
            [];

  Map<String, dynamic> toJson() => {
        'team1Name': team1Name,
        'team2Name': team2Name,
        'team1Players': team1Players.map((player) => player.toJson()).toList(),
        'team2Players': team2Players.map((player) => player.toJson()).toList(),
        'totalRuns': totalRuns,
        'wickets': wickets,
        'ballsDelivered': ballsDelivered,
        'extras': extras,
        'runRate': runRate,
        'overs': overs,
        'isCompleted': isCompleted,
        'ballOutcomes': ballOutcomes.map((outcome) => outcome.toJson()).toList(),
      };

  Match copy() {
    return Match(
      team1Name: team1Name,
      team2Name: team2Name,
      team1Players: team1Players.map((player) => PlayerStats.fromJson(player.toJson())).toList(),
      team2Players: team2Players.map((player) => PlayerStats.fromJson(player.toJson())).toList(),
      totalRuns: totalRuns,
      wickets: wickets,
      ballsDelivered: ballsDelivered,
      extras: extras,
      runRate: runRate,
      overs: overs,
      isCompleted: isCompleted,
      ballOutcomes: ballOutcomes.map((outcome) => BallOutcome.fromJson(outcome.toJson())).toList(),
    )..id = id;
  }

  void reset() {
    totalRuns = 0;
    wickets = 0;
    ballsDelivered = 0;
    extras = 0;
    runRate = 0.0;
    overs = "0.0";
    isCompleted = false;
    ballOutcomes.clear();
    for (var player in team1Players) {
      player.runs = 0;
      player.ballsFaced = 0;
    }
    for (var player in team2Players) {
      player.ballsDelivered = 0;
      player.runsLost = 0;
      player.wickets = 0;
    }
  }
}
class MatchModel extends ChangeNotifier {
  final List<Match> items = [];
  CollectionReference matchesCollection =
      FirebaseFirestore.instance.collection('cricket');
  bool loading = false;

  MatchModel() {
    fetch();
  }

  Future fetch() async {
    items.clear();
    loading = true;
    notifyListeners();

    var querySnapshot = await matchesCollection.orderBy("team1Name").get();
    for (var doc in querySnapshot.docs) {
      var match = Match.fromJson(doc.data()! as Map<String, dynamic>, doc.id);
      items.add(match);
    }

    loading = false;
    update();
  }

  void update() {
    notifyListeners();
  }

  Future add(Match item) async {
    loading = true;
    update();

    DocumentReference docRef = await matchesCollection.add(item.toJson());
    item.id = docRef.id;
    await fetch();
  }

  Future updateItem(String id, Match item) async {
    loading = true;
    update();

    await matchesCollection.doc(id).set(item.toJson());
    await fetch();
  }

  Future updatePlayer(PlayerStats player) async {
    for (var match in items) {
      for (var p in match.team1Players) {
        if (p.name == player.name) {
          p.name = player.name;
          await updateItem(match.id, match);
          return;
        }
      }
      for (var p in match.team2Players) {
        if (p.name == player.name) {
          p.name = player.name;
          await updateItem(match.id, match);
          return;
        }
      }
    }
  }

  Future delete(String id) async {
    loading = true;
    update();

    await matchesCollection.doc(id).delete();
    await fetch();
  }

  Match? get(String? id) {
    if (id == null) return null;
    return items.firstWhere((match) => match.id == id);
  }
}