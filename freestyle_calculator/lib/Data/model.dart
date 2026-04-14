import 'dart:convert';
import 'dart:math';

import 'package:shared_preferences/shared_preferences.dart';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:freestyle_calculator/Data/competition.dart';
import 'package:freestyle_calculator/Data/judge.dart';
import 'package:freestyle_calculator/Data/mark_list.dart';
import 'package:freestyle_calculator/Data/pair_data.dart';

class Model extends ChangeNotifier {
  
  late SharedPreferences prefs;
  Competition? competition;
  Saves saves = Saves();
  String? error;

  void setError(String? text) {
    error = text;
    notifyListeners();
  }

  void loadCompetition(String id) {
    try
    {
      final String json = prefs.getString(id) ?? "";
      competition = Competition.fromJson(jsonDecode(json));
      notifyListeners();
    }
    catch(e){
      setError(e.toString());
    }
  }

  void createFromTemplate() {
    String id = (Random().nextInt(1<<31) % 1000000000).toString().padLeft(9, "0");
    String name = "Без имени $id";
    final newCompetition = Competition(id, name);
    competition = newCompetition;
    for (int j = 0; j < 3; j++) {
      var judge = Judge();
      judge.setName("Судья номер $j");
      newCompetition.judges.add(judge);
    }
    for (int i = 0; i < 10; i++) {
      var pair = Pair(newCompetition, i + 1);
      pair.classKind = i % 2 == 0 ? ClassKind.freProgress : ClassKind.htmVeterans; 
      pair.setHaldlerName("Хендлер номер $i");
      pair.setDogBreed("порода $i");
      pair.setDogName("Кличка $i");
      newCompetition.pairs.add(pair);
    }
    readMarksList(newCompetition);
  }

  Future<void> readMarksList(Competition competition) async {
    try{
      final String jsonString = await rootBundle.loadString('assets/marks_list.json');
      final map = jsonDecode(jsonString) as Map<String, dynamic>;
      competition.marksList = MarksList.fromJson(map);
      competition.marksList.updateSum();
      notifyListeners();
    } 
    catch(e){
      setError(e.toString());
      notifyListeners();
    }
  }

  static const String savedIdsKey = 'savedIds';

  void loadSaves() async {
    try {
      prefs = await SharedPreferences.getInstance();
      String? json = prefs.getString(savedIdsKey);
      if (json != null && json != "")
      {
        saves = Saves.fromJson(jsonDecode(json));
        notifyListeners();
      }
     }
    catch(e){
      setError(e.toString());
    }
 }

  void saveCurrent() async {
    try{
      if (competition != null) {
        CompetitionNote? note = saves.notes.firstWhereOrNull((n) => n.id == competition!.id);
        if (note == null) {
          note = CompetitionNote(competition!.id, competition!.name);
          saves.notes.add(note);
        }
        else {
          note.name = competition!.name;
        }
        String savesJson = jsonEncode(saves.toJson());
        await prefs.setString(savedIdsKey, savesJson);
        await prefs.setString(competition!.id, jsonEncode(competition!.toJson()));
        competition!.notifyChanged();
        competition!.saved.value = true;
      }
    }
    catch(e) {
      setError(e.toString());
    }
  }

  void clearRecent() async {
    try{
      await prefs.clear();
      if (competition != null) competition!.saved.value = false;
      saves.setNotes([]);
    }
    catch(e) {
      setError(e.toString());
    }
  }
}

class Saves extends ChangeNotifier {
  Saves();
  Saves.fromJson(Map<String, dynamic> json)
    : notes = (json['notes'] as List<Object?>).cast<Map<String,Object?>>().map<CompetitionNote>(CompetitionNote.fromJson).toList();
  Map<String, dynamic> toJson() => {'notes': notes.map((note) => note.toJson()).toList()};

  List<CompetitionNote> notes = [];

  void setNotes(List<CompetitionNote> notes) {
    this.notes = notes;
    notifyListeners();
  }

}

class CompetitionNote {
  CompetitionNote(this.id, this.name);
  CompetitionNote.fromJson(Map<String, dynamic> json)
    : id = json['id'] as String,
      name = json['name'] as String;
  Map<String, dynamic> toJson() => {'id' : id, 'name': name};
  String id;
  String name;
}