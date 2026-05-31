import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:freestyle_calculator/Data/competition.dart';
import 'package:freestyle_calculator/Data/pair_data.dart';
import 'package:freestyle_calculator/Pages/elements.dart';
import 'package:freestyle_calculator/Pages/pair_edit_page.dart';

class PairsPage extends StatelessWidget {
  const PairsPage(this.competition, {super.key});

  final Competition competition;
  
  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: competition,
      builder: (context, child) {
        return Scaffold(
          appBar: AppBar(
            backgroundColor: Theme.of(context).colorScheme.inversePrimary,
            title: Text("Участники"),
          ),
          body: Column(
            children: [
              Container(
                margin: EdgeInsets.all(0),
                alignment: .center,
                child: Text(
                  'всего пар: ${competition.pairs.length}',
                  style: Theme.of(context).textTheme.bodyMedium,
                )
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.only(bottom: 80),
                  child: Column(
                    mainAxisAlignment: .start,
                    children: [
                      for (var pair in competition.pairs)
                        PairLine(competition: competition, pair: pair),
                    ],
                  ),
                ),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: competition.addPair,
            tooltip: 'Добавить участника',
            child: const Icon(Icons.add),
          ),
        );
      }
    );
  }
}

class PairLine extends StatelessWidget {
  const PairLine({super.key, required this.competition, required this.pair});
  
  final Competition competition;
  final Pair pair;

  @override
  Widget build(BuildContext context) {
    return MaterialButton(
      padding: EdgeInsets.all(0),
      onPressed: () => Navigator.of(context).push(
        CupertinoPageRoute(
          title: "$pair#{pair.startNumber}",
          builder: (context) => PairEditPage(competition: competition, pair: pair),
        ),
      ),
      child: ListenableBuilder(
        listenable: pair,
        builder: (context, child) => IntrinsicHeight(
          child: Row(
            mainAxisAlignment: .center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              CellWithText(width: 5, text: pair.startNumber.toString(), softWrap: false, overflow: true),
              CellWithText(width: 7, text: pair.classKind.toUserString(), softWrap: false, overflow: true),
              CellWithText(width: 14, text: pair.handlerName),
              CellWithText(width: 14, text: pair.dogBreed),
              CellWithText(width: 14, text: pair.dogName),
              SquareButton(
                Icons.remove_circle_outline, 
                () { 
                  competition.removePair(pair);
                  competition.saved.value = false;
                }
              ),
            ],
          ),
        ),
      )
    );
  }
}
