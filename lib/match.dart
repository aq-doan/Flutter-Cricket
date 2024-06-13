import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
  late String id;
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

  Match({
    required this.team1Name,
    required this.team2Name,
    this.team1Players = const [],
    this.team2Players = const [],
    this.totalRuns = 0,
    this.wickets = 0,
    this.ballsDelivered = 0,
    this.extras = 0,
    this.runRate = 0.0,
    this.overs = "0.0",
    this.isCompleted = false,
  });

  Match.fromJson(Map<String, dynamic> json, this.id)
      : team1Name = json['team1Name'],
        team2Name = json['team2Name'],
        team1Players = (json['team1Players'] as List)
            .map((item) => PlayerStats.fromJson(item))
            .toList(),
        team2Players = (json['team2Players'] as List)
            .map((item) => PlayerStats.fromJson(item))
            .toList(),
        totalRuns = json['totalRuns'],
        wickets = json['wickets'],
        ballsDelivered = json['ballsDelivered'],
        extras = json['extras'],
        runRate = json['runRate'],
        overs = json['overs'],
        isCompleted = json['isCompleted'];

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
      };
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
