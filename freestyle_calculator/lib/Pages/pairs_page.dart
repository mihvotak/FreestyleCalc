import 'package:flutter/material.dart';
import 'package:freestyle_calculator/Data/competition.dart';
import 'package:freestyle_calculator/Data/pair_info.dart';
import 'package:freestyle_calculator/main.dart';

class PairsPage extends StatefulWidget {
  const PairsPage({super.key, required this.title, required this.competition});

  final Competition competition;
  final String title;

  @override
  State<PairsPage> createState() => _PairsPageState();
}

class _PairsPageState extends State<PairsPage> {

  void _incrementCounter() {
    setState(() {
      widget.competition.pairs.add(Pair());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: .center,
          children: [
            Text(
              '${widget.competition.pairs.length} pair(s):',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            Expanded(
              child: Column(
                children: [
                  for (var pair in widget.competition.pairs)
                    PairLine(pair: pair),
                ],
              )
            )
          ],
        ),
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
    return Row(
      children: [
        CellWithText(width: 2, text: pair.haldlerName),
        CellWithText(width: 1, text: pair.dogType),
        CellWithText(width: 1, text: pair.dogName),
      ],
    );
  }
}
