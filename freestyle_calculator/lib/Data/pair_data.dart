import 'package:flutter/widgets.dart';
import 'package:freestyle_calculator/Data/competition.dart';
import 'package:freestyle_calculator/Data/mark_list.dart';

enum ClassKind {
  outOfScoring,
  freNewbies,
  freOpen,
  freVeterans,
  freDebut,
  freProgress,
  freMaster,
  htmNewbies,
  htmOpen,
  htmVeterans,
  htmDebut,
  htmProgress,
  htmMaster;

  static ClassKind parse(String classKindAsString) {
    for (ClassKind element in ClassKind.values) {
      if (element.toString() == classKindAsString) {
          return element;
      }
    }
    return ClassKind.outOfScoring;
  }
  
  String toUserString()
  {
    switch (this){
      case ClassKind.outOfScoring:
        return "В/З";
      case ClassKind.freNewbies:
        return "Ф.Н";
      case ClassKind.freOpen:
        return "Ф.О";
      case ClassKind.freVeterans:
        return "Ф.В";
      case ClassKind.freDebut:
        return "Ф.Д";
      case ClassKind.freProgress:
        return "Ф.П";
      case ClassKind.freMaster:
        return "Ф.М";
      case ClassKind.htmNewbies:
        return "Х.Н";
      case ClassKind.htmOpen:
        return "Х.О";
      case ClassKind.htmVeterans:
        return "Х.В";
      case ClassKind.htmDebut:
        return "Х.Д";
      case ClassKind.htmProgress:
        return "Х.П";
      case ClassKind.htmMaster:
        return "Х.М";
    }
  }
}

class Pair extends ChangeNotifier {
  Pair(this.competition, this.startNumber);
  Pair.fromJson(Map<String, dynamic> json)
    : startNumber = json['startNumber'] as int,
      classKind = ClassKind.parse(json['classKind'] as String),
      handlerName = json['handlerName'] as String,
      dogBreed = json['dogBreed'] as String,
      dogName = json['dogName'] as String,
      judgesMarks = (json['judgesMarks'] as List<Object?>).cast<Map<String,Object?>>().map<JudgeMarks>(JudgeMarks.fromJson).toList();
  Map<String, dynamic> toJson() => {'startNumber' : startNumber, 'classKind': classKind.toString(), 'handlerName': handlerName, 'dogBreed': dogBreed, 'dogName': dogName, 'judgesMarks': judgesMarks.map((judgeMark) => judgeMark.toJson()).toList()};
  
  late Competition competition;

  int startNumber = 0;
  ClassKind classKind = ClassKind.outOfScoring;
  String handlerName = "";
  String dogBreed = "";
  String dogName = "";
  
  List<JudgeMarks> judgesMarks = [];
  double meanSum = 0;
  int? place; 

  void prepareMarks(Competition competition) {
    while (judgesMarks.length > competition.judges.length) { judgesMarks.removeLast(); }
    while (judgesMarks.length < competition.judges.length) { judgesMarks.add(JudgeMarks([])); }
    for (int j = 0; j < competition.judges.length; j++) {
      var judgeMarks = judgesMarks[j];
      while (judgeMarks.blocks.length > competition.marksList.blocks.length) { judgeMarks.blocks.removeLast(); }
      while (judgeMarks.blocks.length < competition.marksList.blocks.length) { judgeMarks.blocks.add(MarksBlock([])); }
      for (int b = 0; b < competition.marksList.blocks.length; b++) {
        var block = judgeMarks.blocks[b];
        while (block.marks.length > competition.marksList.blocks[b].lines.length) { block.marks.removeLast(); }
        while (block.marks.length < competition.marksList.blocks[b].lines.length) { block.marks.add(Mark()); }
        block.updateSum(competition.marksList.blocks[b]);
      }
      judgeMarks.updateSum();
    }
    updateSum();
  }

  void updateSum() {
    meanSum = judgesMarks.isEmpty ? 0 : judgesMarks.fold(0.0, (s, m) => s + m.sum) / judgesMarks.length;
    notifyListeners();
  }

  void setHaldlerName(String value)
  {
    handlerName = value;
    notifyListeners();
  }

  void setDogBreed(String value)
  {
    dogBreed = value;
    notifyListeners();
  }

  void setDogName(String value)
  {
    dogName = value;
    notifyListeners();
  }

  void remove()
  {
    competition.pairs.remove(this);
    for (int i = 0; i < competition.pairs.length; i++) {
      competition.pairs[i].startNumber = i + 1;
    }
  }
}