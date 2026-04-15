import 'package:flutter/material.dart';
import 'package:freestyle_calculator/Data/competition.dart';
import 'package:freestyle_calculator/Data/pair_data.dart';

class PairResultPage extends StatelessWidget {
  const PairResultPage(this.competition, this.pair, {super.key});

  final Competition competition;
  final Pair pair;

  @override
  Widget build(BuildContext context) {
    pair.prepareMarks(competition);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Row(
          spacing: 5,
          children: [
            Expanded(
              child: Text("${pair.startNumber}|${pair.classKind.toUserString()}|${pair.handlerName}"),
            ),
            ListenableBuilder(
              listenable: pair,
              builder: (context, child) {
                return Text(pair.meanSum.toStringAsFixed(2));
              },
            ),
            Container(width: 10),
          ],
        ),
      ),
      body: FocusTraversalGroup(
        policy: OrderedTraversalPolicy(),
        child: SingleChildScrollView(
          child: Column(
            children: [
              for (int b = 0; b < competition.marksList.blocks.length; b++)
              Column(
                children: [
                  Container(
                    color: Theme.of(context).highlightColor,
                    child: Row(
                      spacing: 5,
                      children: [
                        Expanded(
                          flex: 8,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Theme.of(context).hoverColor,
                            ),
                            padding: EdgeInsets.symmetric(vertical: 10, horizontal: 5),
                            child: Text(competition.marksList.blocks[b].name),
                          ),
                        ),
                        for (int j = 0; j < competition.judges.length; j++)
                        Expanded(
                          child: ListenableBuilder(
                            listenable: pair.judgesMarks[j].blocks[b],
                            builder: (context, child) {
                              return Text(
                                textAlign: .center,
                                pair.judgesMarks[j].blocks[b].sum.toStringAsFixed(1),
                                style: Theme.of(context).textTheme.bodySmall,
                              );
                            },
                          ),
                        ),
                      ],
                    ), 
                  ),
                  for (int l = 0; l < competition.marksList.blocks[b].lines.length; l++)
                  PairMapksLine(competition, pair, b, l),
                ]
              ),
              Row(
                spacing: 5,
                children: [
                  Expanded(
                    flex: 8,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).hoverColor,
                      ),
                      padding: EdgeInsets.symmetric(vertical: 10, horizontal: 5),
                      child: Text("Сумма"),
                    ),
                  ),
                  for (int j = 0; j < competition.judges.length; j++)
                  Expanded(
                    child: ListenableBuilder(
                      listenable: pair.judgesMarks[j],
                      builder: (context, child) {
                        return Text(
                          textAlign: .center,
                          pair.judgesMarks[j].sum.toStringAsFixed(1),
                          style: Theme.of(context).textTheme.bodySmall,
                        );
                      },
                    ),
                  ),
                ],
              ), 
            ],
          ),
        ),
      ),
    );
  }
}

class PairMapksLine extends StatelessWidget {
  const PairMapksLine(this.competition, this.pair, this.blockIndex, this.lineIndex, {super.key});
  
  final Competition competition;
  final Pair pair;
  final int blockIndex;
  final int lineIndex;

  @override
  Widget build(BuildContext context) {
    return Row(
      spacing: 5,
      children: [
        Expanded(
          flex: 8,
          child: Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.inversePrimary,
            ),
            padding: EdgeInsets.symmetric(vertical: 10, horizontal: 5),
            child: Text(competition.marksList.blocks[blockIndex].lines[lineIndex].name),
          ),
        ),
        for (int i = 0; i < competition.judges.length; i++)
        Expanded(
          child: Container(
            color: Theme.of(context).hoverColor,
            child: FocusTraversalOrder(
              order: NumericFocusOrder(i * 10000 + blockIndex * 100 + lineIndex + 0.0),
              child: TextFormField(
                focusNode: FocusNode(

                ),
                autovalidateMode: AutovalidateMode.onUserInteraction,
                validator: (value) => (value == null || value == "") ? null : (double.tryParse(value) == null) ? 'число' : (double.parse(value) > competition.marksList.blocks[blockIndex].lines[lineIndex].maxValue) ? "> ${competition.marksList.blocks[blockIndex].lines[lineIndex].maxValue}" : (double.parse(value) < 0) ? "< 0" : null,
                decoration: InputDecoration(
                  errorStyle: TextStyle(color: Colors.orangeAccent), // Custom error text color
                  errorBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.red, width: 5)),
                  focusedErrorBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.orange, width: 5)),
                ),
                textInputAction: TextInputAction.next,
                textAlign: .center,
                keyboardType: TextInputType.number,
                controller:TextEditingController(
                  text: pair.judgesMarks[i].blocks[blockIndex].marks[lineIndex].markValue?.toString() ?? ""
                ),
                onChanged: (value) => { 
                  pair.judgesMarks[i].blocks[blockIndex].marks[lineIndex].markValue = double.tryParse(value),
                  pair.judgesMarks[i].blocks[blockIndex].updateSum(competition.marksList.blocks[blockIndex]),
                  pair.judgesMarks[i].updateSum(),
                  pair.updateSum(),
                  competition.updatePlaces(),
                  competition.saved.value = false
                },
              ),
            ),
          ),
        ),
      ],
    );
  }
}
