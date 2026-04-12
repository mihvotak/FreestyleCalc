import 'package:flutter/material.dart';
import 'package:freestyle_calculator/Data/judge.dart';
import 'package:freestyle_calculator/Data/mark_list.dart';
import 'package:freestyle_calculator/Data/pair_data.dart';

class Competition extends ChangeNotifier{
  String name = "";
  List<Pair> pairs = [];
  List<Judge> judges = [];
  MarksList marksList = MarksList(blocks: []);

  void notifyChanged() {
    notifyListeners();
  }
}