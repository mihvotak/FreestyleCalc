
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:freestyle_calculator/Data/competition.dart';
import 'package:freestyle_calculator/Data/pair_data.dart';
import 'package:freestyle_calculator/Pages/elements.dart';
import 'package:freestyle_calculator/Pages/pair_result_page.dart';

class ResultsPage extends StatelessWidget {
  const ResultsPage(this.competition, {super.key});

  final Competition competition;
  
  @override
  Widget build(BuildContext context) {
        return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text("Таблица результатов"),
      ),
      body: ListenableBuilder(
        listenable: competition,
        builder: (context, child) {
          return Column(
            children: [
              Container(
                margin: EdgeInsets.symmetric(horizontal: 10),
                child: Row(
                  mainAxisAlignment: .center,
                  children: [
                    CellWithText(width: 1, text: "№"),
                    CellWithText(width: 2, text: "Класс"),
                    CellWithText(width: 8, text: "Пара"),
                    CellWithText(width: 2, text: "Оценка"),
                    CellWithText(width: 1, text: "М"),
                  ], 
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: .start,
                    children: [
                      for (var pair in competition.pairs)
                        PairLine(competition, pair),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class PairLine extends StatelessWidget {
  const PairLine(this.competition, this.pair, {super.key});
  
  final Competition competition; 
  final Pair pair;

  @override
  Widget build(BuildContext context) {
    return MaterialButton(
      onPressed: () => Navigator.of(context).push(
        CupertinoPageRoute(
          title: "$pair#{pair.startNumber}",
          builder: (context) => PairResultPage(competition, pair),
        ),
      ),
      child: Row(
        children: [
          CellWithText(width: 1, text: pair.startNumber.toString()),
          CellWithText(width: 2, text: pair.classKind.toString()),
          CellWithText(width: 8, text: pair.handlerName),
          CellWithText(width: 2, text: pair.meanSum.toString()),
          CellWithText(width: 1, text: pair.place?.toString() ?? ""),
        ],
      ),
    );
  }
}
