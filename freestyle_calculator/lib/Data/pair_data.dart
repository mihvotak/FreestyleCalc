import 'package:flutter/widgets.dart';
import 'package:freestyle_calculator/Data/competition.dart';
import 'package:freestyle_calculator/Data/mark_list.dart';

enum ClassKind {
  OutOfScoring,
  FreNewbies,
  FreOpen,
  FreVeterans,
  FreDebut,
  FreProgress,
  FreMaster,
  HtmNewbies,
  HtmOpen,
  HtmVeterans,
  HtmDebut,
  HtmProgress,
  HtmMaster;
  
  @override
  String toString() => name;
}

class Pair extends ChangeNotifier {
  Pair(this.competition, this.startNumber);
  
  final Competition competition;

  int startNumber = 0;
  ClassKind classKind = ClassKind.OutOfScoring;
  String handlerName = "";
  String dogName = "";
  String dogBreed = "";

  final List<JudgeMarks> judgesMarks = [];
  double meanSum = 0;
  int? place; 

  void prepareMarks(Competition competition) {
    while (judgesMarks.length > competition.judges.length) { judgesMarks.removeLast(); }
    while (judgesMarks.length < competition.judges.length) { judgesMarks.add(JudgeMarks()); }
    for (int j = 0; j < competition.judges.length; j++) {
      var judgeMarks = judgesMarks[j];
      while (judgeMarks.blocks.length > competition.marksList.blocks.length) { judgeMarks.blocks.removeLast(); }
      while (judgeMarks.blocks.length < competition.marksList.blocks.length) { judgeMarks.blocks.add(MarksBlock()); }
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