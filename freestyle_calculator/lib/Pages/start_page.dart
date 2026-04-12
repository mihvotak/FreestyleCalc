import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:freestyle_calculator/Data/competition.dart';
import 'package:freestyle_calculator/Data/model.dart';
import 'package:freestyle_calculator/Pages/elements.dart';
import 'package:freestyle_calculator/Pages/judges_page.dart';
import 'package:freestyle_calculator/Pages/marks_list_page.dart';
import 'package:freestyle_calculator/Pages/pairs_page.dart';
import 'package:freestyle_calculator/Pages/results_page.dart';

class SatrtPage extends StatelessWidget {
  const SatrtPage(this.model, {super.key});

  final Model model;
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text("Соревнования")
      ),
      body: Column(
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              return Container(
                color: Theme.of(context).focusColor,
                constraints: BoxConstraints(
                  minWidth: constraints.maxWidth * 0.5,
                  minHeight: 300,
                ),
                child: ListenableBuilder(
                  listenable: model,
                  builder: (context, child) => 
                  model.competition != null ? 
                  CompetitionWidget(model.competition!) : 
                  Center(
                    child: Column(
                      children: [
                        Text("(пусто)"),
                      ],
                    ),
                  ),
                )
              );
            }
          ),
          ListenableBuilder(
            listenable: model,
            builder: (context, child) => 
            model.error != null ? MaterialButton(
              onPressed: () => model.setError(null),
              child: Container(
              color: const Color.from(alpha: 1, red: 0.431, green: 0.078, blue: 0.055), 
              child: Text(model.error!),
              )
            ) : 
            Container(),
          ),
          LineButton("Создать новый", model.createFromTemplate),
          LineButton("Ошибка", () => model.setError("Длинный текст ошибки, который не должен вмещаться в одну строку. Длинный текст ошибки, который не должен вмещаться в одну строку.")),
        ],
      ),
    );
  }
}

class CompetitionWidget extends StatelessWidget {
  const CompetitionWidget(this.competition, {super.key});

  final Competition competition;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        color: Theme.of(context).hoverColor,
        child: Column(
          children: [
            LineButton(
              "Участники (${competition.pairs.length})",
              () => Navigator.of(context).push(
                CupertinoPageRoute(
                  title: "",
                  builder: (context) => PairsPage(competition),
                ),
              ),
            ),
            LineButton(
              "Судьи (${competition.judges.length})",
              () => Navigator.of(context).push(
                CupertinoPageRoute(
                  builder: (context) => JudgesPage(competition),
                ),
              ),
            ),
            LineButton(
              "Оценочный лист (${competition.marksList.marksCount.value})",
              () => Navigator.of(context).push(
                CupertinoPageRoute(
                  builder: (context) => MarksListPage(competition),
                ),
              ),
            ),
            LineButton(
              "Результаты",
              () => Navigator.of(context).push(
                CupertinoPageRoute(
                  builder: (context) => ResultsPage(competition),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
