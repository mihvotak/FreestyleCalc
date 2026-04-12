import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:freestyle_calculator/Data/competition.dart';
import 'package:freestyle_calculator/Data/judge.dart';
import 'package:freestyle_calculator/Data/mark_list.dart';
import 'package:freestyle_calculator/Data/pair_data.dart';

class Model extends ChangeNotifier {
  
  Competition? competition;
  String? error;

  void setError(String? text) {
    error = text;
    notifyListeners();
  }

  void createFromTemplate() {
    final newCompetition = Competition();
    competition = newCompetition;
    for (int j = 0; j < 3; j++) {
      var judge = Judge();
      judge.setName("Судья номер $j");
      newCompetition.judges.add(judge);
    }
    for (int i = 0; i < 10; i++) {
      var pair = Pair(newCompetition, i + 1);
      pair.classKind = i % 2 == 0 ? ClassKind.FreProgress : ClassKind.HtmVeterans; 
      pair.setHaldlerName("Хендлер номер $i");
      pair.setDogBreed("порода $i");
      pair.setDogName("Кличка $i");
      newCompetition.pairs.add(pair);
    }
    readMarksList(newCompetition);
  }

  Future<void> readMarksList(Competition competition) async {
    try{
      final String jsonString = await rootBundle.loadString('marks_list.json');
      final map = jsonDecode(jsonString) as Map<String, dynamic>;
      competition.marksList = MarksList.fromJson(map);
      competition.marksList.updateSum();
      notifyListeners();
    } 
    catch(e){
      setError(e.toString());
    }
  }
}