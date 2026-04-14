
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
                margin: EdgeInsets.symmetric(horizontal: 0),
                child: IntrinsicHeight(
                  child: Row(
                    mainAxisAlignment: .center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      CellWithText(width: 3, text: "№", softWrap: false, overflow: true),
                      CellWithText(width: 4, text: "Кл."),
                      CellWithText(width: 14, text: "Пара"),
                      CellWithText(width: 5, text: "Оц."),
                      CellWithText(width: 3, text: "М", softWrap: false, overflow: true),
                    ], 
                  ),
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
      padding: EdgeInsets.all(0),
      onPressed: () => Navigator.of(context).push(
        CupertinoPageRoute(
          title: "$pair#{pair.startNumber}",
          builder: (context) => PairResultPage(competition, pair),
        ),
      ),
      child: IntrinsicHeight(
        child: Row(
          mainAxisAlignment: .center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            CellWithText(width: 3, text: pair.startNumber.toString(), softWrap: false, overflow: true),
            CellWithText(width: 4, text: pair.classKind.toUserString(), softWrap: false, overflow: true),
            CellWithText(width: 14, text: pair.handlerName),
            CellWithText(width: 5, text: pair.meanSum.toStringAsFixed(2), softWrap: false, overflow: true),
            CellWithText(width: 3, text: pair.place?.toString() ?? "", softWrap: false, overflow: true),
          ],
        ),
      ),
    );
  }
}
