import 'package:freestyle_calculator/Data/judge.dart';
import 'package:freestyle_calculator/Data/mark_list.dart';
import 'package:freestyle_calculator/Data/pair_data.dart';

class Competition {
  List<Pair> pairs = [];
  List<Judge> judges = [];
  MarksList marksList = MarksList(blocks: []);
}