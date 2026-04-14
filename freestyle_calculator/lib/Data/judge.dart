import 'package:flutter/widgets.dart';

class Judge extends ChangeNotifier {
  Judge();
  Judge.fromJson(Map<String, dynamic> json)
    : name = json['name'] as String;
  Map<String, dynamic> toJson() => {'name': name};
  
  String name = "";

  void setName(String value) {
    name = value;
    notifyListeners();
  }
}