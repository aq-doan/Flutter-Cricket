import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Match {
  late String id;
  String team1Name;
  String team2Name;
  List<String> team1Players;
  List<String> team2Players;
  int totalRuns;
  int wickets;
  int ballsDelivered;
  int extras;

  Match({
    required this.team1Name,
    required this.team2Name,
    this.team1Players = const [],
    this.team2Players = const [],
    this.totalRuns = 0,
    this.wickets = 0,
    this.ballsDelivered = 0,
    this.extras = 0,
  });

  Match.fromJson(Map<String, dynamic> json, this.id)
      : team1Name = json['team1Name'],
        team2Name = json['team2Name'],
        team1Players = List<String>.from(json['team1Players'] ?? []),
        team2Players = List<String>.from(json['team2Players'] ?? []),
        totalRuns = json['totalRuns'],
        wickets = json['wickets'],
        ballsDelivered = json['ballsDelivered'],
        extras = json['extras'];

  Map<String, dynamic> toJson() => {
        'team1Name': team1Name,
        'team2Name': team2Name,
        'team1Players': team1Players,
        'team2Players': team2Players,
        'totalRuns': totalRuns,
        'wickets': wickets,
        'ballsDelivered': ballsDelivered,
        'extras': extras,
      };
}

class MatchModel extends ChangeNotifier {
  final List<Match> items = [];
  CollectionReference matchesCollection =
      FirebaseFirestore.instance.collection('matches');
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

    await matchesCollection.add(item.toJson());
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
