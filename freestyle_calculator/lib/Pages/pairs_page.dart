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

  void _incrementCounter() {
    setState(() {
      widget.competition.pairs.add(Pair(widget.competition, widget.competition.pairs.length + 1));
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
          Align(
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
                    PairLine(pair: pair),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}

class PairLine extends StatelessWidget {
  const PairLine({super.key, required this.pair});
  
  final Pair pair;

  @override
  Widget build(BuildContext context) {
    return MaterialButton(
      onPressed: () => Navigator.of(context).push(
        CupertinoPageRoute(
          title: "$pair#{pair.startNumber}",
          builder: (context) => PairEditPage(pair: pair),
        ),
      ),
      child: Row(
        children: [
          Text("${pair.startNumber}"),
          CellWithText(width: 2, text: pair.handlerName),
          CellWithText(width: 1, text: pair.dogBreed),
          CellWithText(width: 1, text: pair.dogName),
        ],
      ),
    );
  }
}
