import 'package:flutter/widgets.dart';
import 'package:freestyle_calculator/Data/competition.dart';
import 'package:freestyle_calculator/Data/mark_list.dart';

class Pair extends ChangeNotifier {
  Pair(this.competition, this.startNumber);
  
  final Competition competition;

  int startNumber = 0;
  String handlerName = "";
  String dogName = "";
  String dogBreed = "";

  final List<JudgeMarks> judgesMarks = [];
  double meanSum = 0;

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