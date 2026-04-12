import 'package:flutter/widgets.dart';

class Judge extends ChangeNotifier {
  String name = "";
  void setName(String value) {
    name = value;
    notifyListeners();
  }
}