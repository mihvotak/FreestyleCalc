import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:freestyle_calculator/Data/competition.dart';
import 'package:freestyle_calculator/Data/mark_list.dart';
import 'package:freestyle_calculator/Pages/elements.dart';
import 'package:freestyle_calculator/Pages/mark_line_edit_page.dart';

class MarksListPage extends StatelessWidget {
  const MarksListPage(this.competition, {super.key});

  final Competition competition;
  MarksList get marksList => competition.marksList;

  @override
  Widget build(BuildContext context) {
    marksList.updateSum();
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text("Оценочный лист"),
      ),
      body: ListenableBuilder(
        listenable: marksList,
        builder: (context, child) {
          return Column(
            children: [
              Align(
                alignment: .center,
                child: Row(
                  mainAxisAlignment: .center,
                  children: [
                    ValueListenableBuilder<int>(
                      valueListenable: marksList.marksCount,
                      builder: (context, value, child) {
                        return Text(
                          'всего строк: ${marksList.marksCount.value}, ',
                          style: Theme.of(context).textTheme.bodyMedium,
                        );
                      },
                    ),
                    ValueListenableBuilder<double>(
                      valueListenable: marksList.marksMaxSum,
                      builder: (context, value, child) {
                        return Text(
                          'сумма: ${marksList.marksMaxSum.value}',
                          style: Theme.of(context).textTheme.bodyMedium,
                        );
                      },
                    ),
                  ], 
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    spacing: 20,
                    mainAxisAlignment: .start,
                    children: [
                      for (var block in marksList.blocks)
                        LinesBlockWidget(competition, marksList, block),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          marksList.addBlock;
          competition.saved.value = false;
        },
        tooltip: 'Добавить группу',
        child: const Icon(Icons.add),
      ),
    );
  }
}

class LinesBlockWidget extends StatelessWidget {
  const LinesBlockWidget(this.competition, this.marksList, this.linesBlock, {super.key});
  
  final Competition competition;
  final MarksList marksList;
  final LinesBlock linesBlock;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: linesBlock,
      builder: (context, child) {
        return Column(
          children: [
            Container(
              color: Theme.of(context).hoverColor,
              margin: EdgeInsets.symmetric(horizontal: 5, vertical: 0),
              padding: EdgeInsets.symmetric(horizontal: 5, vertical: 0),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      "#${(marksList.blocks.indexOf(linesBlock) + 1)}: ${linesBlock.name}",
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ),
                  SquareButton(
                    Icons.add, 
                    () { 
                      linesBlock.addLine();
                      marksList.updateSum();
                      competition.saved.value = false;
                    }
                  ),
                  SquareButton(
                    Icons.remove_circle_outline, 
                    () {
                      marksList.removeBlock(linesBlock);
                      competition.saved.value = false;
                    }
                  ),
                ],
              ),
            ),
            for (var markLine in linesBlock.lines)
              MarkLineWidget(competition, marksList, linesBlock, markLine),
          ],
        );
      }
    );
  }
}


class MarkLineWidget extends StatelessWidget {
  const MarkLineWidget(this.competition, this.marksList, this.linesBlock, this.markLine, {super.key});
  
  final Competition competition;
  final MarksList marksList;
  final LinesBlock linesBlock;
  final MarkLine markLine;

  @override
  Widget build(BuildContext context) {
    return MaterialButton(
      onPressed: () => Navigator.of(context).push(
        CupertinoPageRoute(
          title: "$markLine#{pair.startNumber}",
          builder: (context) => MarkLineEditPage(competition, marksList, linesBlock, markLine),
        ),
      ),
      child: ListenableBuilder(
        listenable: markLine,
        builder: (context, child) {
          return Row(
            children: [
              CellWithText(width: 10, text: markLine.name),
              CellWithText(width: 2, text: markLine.maxValue.toString()),
              CellWithText(width: 1, text: markLine.isPenalty ? "-" : "+"),
            ],
          );
        },
      ),
    );
  }
}
