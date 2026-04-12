import 'package:flutter/material.dart';
import 'package:freestyle_calculator/Data/mark_list.dart';
import 'package:freestyle_calculator/Pages/elements.dart';

class MarkLineEditPage extends StatelessWidget {
  const MarkLineEditPage(this.marksList, this.linesBlock, this.markLine, {super.key});

  final MarksList marksList;
  final LinesBlock linesBlock;
  final MarkLine markLine;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text("Блок ${linesBlock.name}")
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: .center,
          spacing: 30,
          children: [
            EditableBox(
              'Блок', 
              linesBlock.name, 
              (value) => linesBlock.setName(value), 
              false
            ),
            EditableBox(
              'Наименование оценки/штрафа', 
              markLine.name, 
              (value) => markLine.setName(value), 
              false
            ),
            EditableBox(
              'Максимальное значение', 
              markLine.maxValue.toString(), 
              (value) => { 
                markLine.setMaxValue(double.parse(value)), 
                marksList.updateSum() }, 
              true
            ),
            ToggleBox(
              'Штраф', 
              markLine.isPenalty, 
              (value) => { 
                markLine.setIsPenalty(value ?? false), 
                marksList.updateSum() 
              }
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => { linesBlock.removeLine(markLine), marksList.updateSum(), Navigator.of(context).pop() },
        tooltip: 'Remove',
        child: const Icon(Icons.remove_circle_outline),
      ),
    );
  }
}

