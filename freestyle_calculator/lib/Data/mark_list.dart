import 'package:flutter/widgets.dart';

class MarksList extends ChangeNotifier {
  MarksList({required this.blocks});
  MarksList.fromJson(Map<String, dynamic> json)
    : blocks = (json['blocks'] as List<Object?>).cast<Map<String,Object?>>().map<LinesBlock>(LinesBlock.fromJson).toList();

  Map<String, dynamic> toJson() => {'blocks': blocks.map((b) => b.toJson()).toList(),};

  List<LinesBlock> blocks = [];
 
  final ValueNotifier<int> marksCount = ValueNotifier<int>(0);
  final ValueNotifier<double> marksMaxSum = ValueNotifier<double>(0);
  void updateSum() {
    marksCount.value = blocks.fold(0, (a, b) => a + b.lines.length);
    marksMaxSum.value = blocks.fold(0, (a, b) => a + b.marksMaxSum); 
  }
  void addBlock() {
    blocks.add(LinesBlock(name: "", lines: []));
    notifyListeners();
  }
  void removeBlock(LinesBlock block) {
    blocks.remove(block);
    notifyListeners();
  }
}

class LinesBlock extends ChangeNotifier {
  LinesBlock({required this.name, required this.lines});
  LinesBlock.fromJson(Map<String, dynamic> json)
    : name = json['name'] as String,
      lines = (json['lines'] as List<Object?>).cast<Map<String,Object?>>().map<MarkLine>(MarkLine.fromJson).toList();

  Map<String, dynamic> toJson() => {'name': name, 'lines': lines.map((line) => line.toJson()).toList(),};

  String name = "";
  List<MarkLine> lines = [];

  double get marksMaxSum => lines.fold(0, (sum, m) => sum + (m.isPenalty ? 0 : m.maxValue));
  void addLine() {
    lines.add(MarkLine(name: "", maxValue: 0, isPenalty: false));
    notifyListeners();
  }
  void removeLine(MarkLine line) {
    lines.remove(line);
    notifyListeners();
  }
  void setName(String value) {
    name = value;
    notifyListeners();
  }
}

class MarkLine extends ChangeNotifier {
  MarkLine({required this.name, required this.maxValue, required this.isPenalty});
  factory MarkLine.fromJson(Map<String, dynamic> json) {
    return MarkLine(
      name: json['name'] as String,
      maxValue: json['maxValue'] as double,
      isPenalty: json['isPenalty'] as bool,
    );
  }

  Map<String, dynamic> toJson() => {'name': name, 'maxValue': maxValue, 'isPenalty': isPenalty};

  String name;
  bool isPenalty;
  double maxValue;

  void setName(String value) {
    name = value;
    notifyListeners();
  }
  void setMaxValue(double value) {
    maxValue = value;
    notifyListeners();
  }
  void setIsPenalty(bool value) {
    isPenalty = value;
    notifyListeners();
  }
}

class JudgeMarks{
  final List<MarksBlock> blocks = [];
  double sum = 0;
}

class MarksBlock {
  final List<Mark> marks = [];
  double sum = 0;
}

class Mark {
  double? value;
}