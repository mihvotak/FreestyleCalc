import 'package:flutter/material.dart';
import 'package:freestyle_calculator/Data/judge.dart';
import 'package:freestyle_calculator/Data/mark_list.dart';
import 'package:freestyle_calculator/Data/pair_data.dart';

enum SortMode { startNumber, classKind, handlerName, score, place }

class Competition extends ChangeNotifier{
  Competition(this.id, this.name);
  Competition.fromJson(Map<String, dynamic> json)
    : id = json['id'] as String,
      name = json['name'] as String,
      pairs = (json['pairs'] as List<Object?>).cast<Map<String,Object?>>().map<Pair>(Pair.fromJson).toList(),
      judges = (json['judges'] as List<Object?>).cast<Map<String,Object?>>().map<Judge>(Judge.fromJson).toList(),
      marksList = MarksList.fromJson(json['marksList'] as Map<String, dynamic>);
  Map<String, dynamic> toJson() => {'id' : id, 'name': name, 'pairs': pairs.map((pair) => pair.toJson()).toList(), 'judges': judges.map((judge) => judge.toJson()).toList(), 'marksList': marksList.toJson()};
  
  String id;
  String name;
  List<Pair> pairs = [];
  List<Judge> judges = [];
  MarksList marksList = MarksList(blocks: []);
  final ValueNotifier<bool> saved = ValueNotifier(false);
  SortMode sortMode = SortMode.startNumber;

  void setSortMode(SortMode sortMode)
  {
    this.sortMode = sortMode;
    notifyChanged();
  }

  void updatePlaces()
  {
    final Map<ClassKind, List<Pair>> dict = {};
    for (var pair in pairs) {
      if (!dict.containsKey(pair.classKind)) dict[pair.classKind] = [];
      dict[pair.classKind]!.add(pair);
    }
    for (var entry in dict.entries) {
      entry.value.sort((a, b) => b.meanSum.compareTo(a.meanSum));
      for (var (index, pair) in entry.value.indexed) {
        pair.place = pair.meanSum > 0 ? index + 1 : null;
        pair.ambiguous = pair.meanSum > 0 && ((index > 0 && entry.value[index - 1].meanSum == entry.value[index].meanSum) 
        || (index < entry.value.length - 1 && entry.value[index + 1].meanSum == entry.value[index].meanSum));
      }
    }
    notifyChanged();
  }

  void notifyChanged() {
    notifyListeners();
  }

  void removePair(Pair pair)
  {
    pairs.remove(pair);
    for (int i = 0; i < pairs.length; i++) {
      pairs[i].startNumber = i + 1;
    }
  }
}