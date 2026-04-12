import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:freestyle_calculator/Data/competition.dart';
import 'package:freestyle_calculator/Data/mark_list.dart';
import 'package:freestyle_calculator/Pages/judges_page.dart';
import 'package:freestyle_calculator/Pages/marks_list_page.dart';
import 'package:freestyle_calculator/Pages/pairs_page.dart';
import 'package:flutter/services.dart' show rootBundle;

class CompetitionPage extends StatelessWidget {
  const CompetitionPage(this.competition, {super.key});

  final Competition competition;

  Future<void> readMarksList() async {
    try{
      final String jsonString = await rootBundle.loadString('templates/marks_list.json');
      final map = jsonDecode(jsonString) as Map<String, dynamic>;
      competition.marksList = MarksList.fromJson(map);
    } 
    catch(e){}
  }
  
  @override
  Widget build(BuildContext context) {
    readMarksList();
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text("Соревнования")
      ),
      body: Center(
        child: Column(
          children: [
            LineButton(
              "Участники (${competition.pairs.length})",
              () => Navigator.of(context).push(
                CupertinoPageRoute(
                  title: "",
                  builder: (context) => PairsPage(competition),
                ),
              ),
            ),
            LineButton(
              "Судьи (${competition.judges.length})",
              () => Navigator.of(context).push(
                CupertinoPageRoute(
                  title: "",
                  builder: (context) => JudgesPage(competition),
                ),
              ),
            ),
            LineButton(
              "Оценочный лист (${competition.marksList.marksCount.value})",
              () => Navigator.of(context).push(
                CupertinoPageRoute(
                  title: "",
                  builder: (context) => MarksListPage(competition),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class LineButton extends StatelessWidget {
  const LineButton(this.text, this.onPressed, {super.key});

  final String text;
  final Function() onPressed;
  
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(10),
      child: MaterialButton(
        padding: EdgeInsets.all(20),
        onPressed: onPressed,
        color: Theme.of(context).colorScheme.inversePrimary,
        child: Text(text),
      ),
    );
  }
}
class SquareButton extends StatelessWidget {
  const SquareButton(this.iconData, this.onPressed, {super.key});

  final IconData iconData;
  final Function() onPressed;
  
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      margin: EdgeInsets.all(2),
      child: MaterialButton(
        padding: EdgeInsets.all(10),
        onPressed: onPressed,
        color: Theme.of(context).colorScheme.inversePrimary,
        child: Icon(iconData),
      ),
    );
  }
}