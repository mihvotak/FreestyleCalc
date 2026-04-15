import 'package:flutter/material.dart';
import 'package:freestyle_calculator/Data/competition.dart';
import 'package:freestyle_calculator/Data/judge.dart';
import 'package:freestyle_calculator/Pages/elements.dart';

class JudgeEditPage extends StatelessWidget {
  const JudgeEditPage(this.competition, this.judge, this.removeFunction, {super.key});

  final Competition competition;
  final Judge judge;
  final Function(Judge) removeFunction;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text("Судья ${competition.judges.indexOf(judge)}")
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: .center,
          children: [
            EditableBox('ФИО судьи', judge.name, 
              (value) {
                judge.setName(value);
                competition.saved.value = false;
              }, 
              false
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => { removeFunction(judge), Navigator.of(context).pop() },
        tooltip: 'Remove',
        child: const Icon(Icons.remove_circle_outline),
      ),
    );
  }
}
