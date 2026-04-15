import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:freestyle_calculator/Data/competition.dart';
import 'package:freestyle_calculator/Data/pair_data.dart';
import 'package:freestyle_calculator/Pages/elements.dart';
import 'package:freestyle_calculator/Pages/pair_edit_page.dart';

class PairsPage extends StatefulWidget {
  const PairsPage(this.competition, {super.key});

  final Competition competition;
  
  @override
  State<PairsPage> createState() => _PairsPageState();
}

class _PairsPageState extends State<PairsPage> {

  void _addPair() {
    setState(() {
      widget.competition.pairs.add(Pair(widget.competition.pairs.length + 1));
      widget.competition.saved.value = false;
    });
  }

  @override
  Widget build(BuildContext context) {
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
              'всего пар: ${widget.competition.pairs.length}',
              style: Theme.of(context).textTheme.bodyMedium,
            )
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: .start,
                children: [
                  for (var pair in widget.competition.pairs)
                    PairLine(competition: widget.competition, pair: pair),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addPair,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
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
            ],
          ),
        ),
      )
    );
  }
}
