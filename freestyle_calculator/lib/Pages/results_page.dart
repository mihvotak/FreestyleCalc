
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:freestyle_calculator/Data/competition.dart';
import 'package:freestyle_calculator/Data/pair_data.dart';
import 'package:freestyle_calculator/Pages/elements.dart';
import 'package:freestyle_calculator/Pages/pair_result_page.dart';

class ResultsPage extends StatefulWidget {
  const ResultsPage(this.competition, {super.key});

  final Competition competition;

  @override
  State<ResultsPage> createState() => _ResultsPageState();
}

class _ResultsPageState extends State<ResultsPage> {

  void _changeMode(SortMode mode)
  {
    setState(() {
      widget.competition.setSortMode(mode);
    });
  }

  @override
  Widget build(BuildContext context) {
    final competition = widget.competition;
    final List<Pair> pairs = [];
    pairs.addAll(competition.pairs);
    switch (competition.sortMode)
    {
      case .startNumber:
        pairs.sort((a, b) => a.startNumber.compareTo(b.startNumber));
        break;
      case .classKind:
        pairs.sort((a, b) {
          int cmp = a.classKind.index.compareTo(b.classKind.index);
          return cmp != 0 ? cmp : a.startNumber.compareTo(b.startNumber);
          });
        break;
      case .handlerName:
        pairs.sort((a, b) {
          int cmp = a.handlerName.compareTo(b.handlerName);
          return cmp != 0 ? cmp : a.startNumber.compareTo(b.startNumber);
          });
        break;
      case .score:
      case .place:
        pairs.sort((a, b) {
          int cmp = a.classKind.index.compareTo(b.classKind.index);
          return cmp != 0 ? cmp : b.meanSum.compareTo(a.meanSum);
          });
        break;
    }
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text("Таблица результатов"),
      ),
      body: ListenableBuilder(
        listenable: widget.competition,
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
                      HeaderCellWithText(competition, () => _changeMode(.startNumber), 3, "№", competition.sortMode == .startNumber, softWrap: false, overflow: true),
                      HeaderCellWithText(competition, () => _changeMode(.classKind), 4, "Кл.", competition.sortMode == .classKind),
                      HeaderCellWithText(competition, () => _changeMode(.handlerName), 14, "Пара", competition.sortMode == .handlerName),
                      HeaderCellWithText(competition, () => _changeMode(.score), 5, "Оц.", competition.sortMode == .score),
                      HeaderCellWithText(competition, () => _changeMode(.place), 3, "М", competition.sortMode == .place, softWrap: false, overflow: true),
                    ], 
                  ),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: .start,
                    children: [
                      for (var pair in pairs)
                        PairLine(widget.competition, pair),
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

class HeaderCellWithText extends StatelessWidget {
  const HeaderCellWithText(this.competition, this.onPress, this.width, this.text, this.selected, {super.key, this.softWrap = true, this.overflow = false});

  final Competition competition;
  final Function() onPress;
  final int width;
  final String text;
  final bool selected;
  final bool softWrap;
  final bool overflow;
  
  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: width,
      child: MaterialButton(
        padding: EdgeInsets.zero,
        onPressed: onPress,
        child: Stack(
          children: [
            Container(
              constraints: BoxConstraints.expand(),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.inversePrimary,
              ),
              margin: EdgeInsets.all(2),
              padding: EdgeInsets.symmetric(vertical: 10, horizontal: 5),
              child: Text(
                text,
                softWrap: softWrap,
                overflow: overflow ? TextOverflow.visible : TextOverflow.fade,
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: softWrap ? .left : .center,
              ),
            ),

          if (selected)
            Align(
              alignment: Alignment.bottomRight,
              child: Container(
                margin: EdgeInsets.all(2),
                child: Icon(Icons.sort, size: 15),
              ),
            ),
          ],
        ),
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
            CellWithText(width: 5, text: pair.meanSum > 0 ? pair.meanSum.toStringAsFixed(2) : "", softWrap: false, overflow: true, ambiguous: pair.ambiguous),
            CellWithText(width: 3, text: pair.place?.toString() ?? "", softWrap: false, overflow: true, ambiguous: pair.ambiguous),
          ],
        ),
      ),
    );
  }
}
