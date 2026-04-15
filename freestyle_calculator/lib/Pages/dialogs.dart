import 'package:flutter/material.dart';

class Dialogs {
  static void showConfirmDialog(BuildContext context, Function callback, String alertTitle, String alertContent) { 
    showDialog<String>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: Text(alertTitle),
        content: Text(alertContent),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(context, 'Нет'),
            child: const Text('Нет'),
          ),
          TextButton(
            onPressed: () {callback(); Navigator.pop(context, 'Да'); },
            child: const Text('Да'),
          ),
        ],
      ),
    );
  }
}