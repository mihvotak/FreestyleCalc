import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:freestyle_calculator/Data/competition.dart';
import 'package:freestyle_calculator/Data/judge.dart';
import 'package:freestyle_calculator/Pages/elements.dart';
import 'package:freestyle_calculator/Pages/judge_edit_page.dart';

class JudgesPage extends StatefulWidget {
  const JudgesPage(this.competition, {super.key});

  final Competition competition;
  
  @override
  State<JudgesPage> createState() => _JudgesPageState();
}

class _JudgesPageState extends State<JudgesPage> {

  void _addJudge() {
    setState(() {
      widget.competition.judges.add(Judge());
    });
  }
  void _removeJudge(Judge judge) {
    setState(() {
      widget.competition.judges.remove(judge);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text("Судьи"),
      ),
      body: Column(
        children: [
          Align(
            alignment: .center,
            child: Text(
              'всего судей: ${widget.competition.judges.length}',
              style: Theme.of(context).textTheme.bodyMedium,
            )
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: .start,
                children: [
                  for (var judge in widget.competition.judges)
                    JudgeLine(widget.competition, judge, _removeJudge),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addJudge,
        tooltip: 'Add',
        child: const Icon(Icons.add),
      ),
    );
  }
}

class JudgeLine extends StatelessWidget {
  const JudgeLine(this.competition, this.judge, this.removeFunction, {super.key});
  
  final Competition competition;
  final Judge judge;
  final Function(Judge) removeFunction;

  @override
  Widget build(BuildContext context) {
    return MaterialButton(
      onPressed: () => Navigator.of(context).push(
        CupertinoPageRoute(
          title: "$judge#{judge.startNumber}",
          builder: (context) => JudgeEditPage(competition, judge, removeFunction),
        ),
      ),
      child: Row(
        children: [
          ListenableBuilder(
            listenable: judge,
            builder: (context, child) {
              return CellWithText(width: 2, text: judge.name);
            }
          ),
        ],
      ),
    );
  }
}
