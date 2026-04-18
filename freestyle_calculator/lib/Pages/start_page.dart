import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:freestyle_calculator/Data/competition.dart';
import 'package:freestyle_calculator/Data/google_api.dart';
import 'package:freestyle_calculator/Data/model.dart';
import 'package:freestyle_calculator/Pages/dialogs.dart';
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
      body: SingleChildScrollView(
        child: ListenableBuilder(
          listenable: model,
          builder: (context, child) =>  Column(
            spacing: 10,
            children: [
              LayoutBuilder(
                builder: (context, constraints) {
                  return Container(
                    margin: EdgeInsets.all(10),
                    color: Theme.of(context).focusColor,
                    constraints: BoxConstraints(
                      minWidth: constraints.maxWidth * 0.5,
                      minHeight: 300,
                    ),
                    child: model.competition != null ? 
                      CompetitionWidget(model, model.competition!) : 
                      Center(
                        child: Column(
                          children: [
                            Text("(пусто)"),
                          ],
                        ),
                      ),
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
              Container(
                margin: EdgeInsets.all(10),
                color: Theme.of(context).focusColor,
                child: Column(
                  children: [
                    Container(
                      padding: EdgeInsets.fromLTRB(40, 0, 0, 0),
                      color: Theme.of(context).hoverColor,
                      child: Row(
                        mainAxisAlignment: .center,
                        children: [
                          Expanded(
                            child: Text("Новый файл", textAlign: .center),
                          ),
                          SquareButton(model.expandNew ? Icons.expand_less : Icons.expand_more, model.changeExpandNew)
                        ],
                      ),
                    ),
                    if (model.expandNew)
                      LineButton("Из шаблона", () { 
                        if (model.competition != null && !model.competition!.saved.value) {
                          Dialogs.showConfirmDialog(context, () => model.createFromTemplate(),
                            'Не сохранено',
                            'Текущий открытый файл не сохранён. При создании нового файла все изменения в текущем будут потеряны. Продолжить?'
                          );
                        }
                        else { model.createFromTemplate(); }
                      }),
                    LineButton( 
                      "Из гуглотаблицы", 
                      () => Navigator.of(context).push(
                        CupertinoPageRoute(
                          builder: (context) => SignInDemo(model),
                        ),
                      )
                    )
                  ],
                ),
              ),
              //LineButton("Ошибка", () => model.setError("Длинный текст ошибки, который не должен вмещаться в одну строку. Длинный текст ошибки, который не должен вмещаться в одну строку.")),
              RecentCompetitionsWidget(model),
            ],
          ),
        ),
      ),
    );
  }
}

class CompetitionWidget extends StatelessWidget {
  CompetitionWidget(this.model, this.competition, {super.key});

  final Model model; 
  final Competition competition;
  final ValueNotifier<bool> editName = ValueNotifier(false);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        color: Theme.of(context).hoverColor,
        child: Column(
          children: [
            ValueListenableBuilder<bool>(
              valueListenable: editName, 
              builder: (context, value, child) => Container(
                padding: EdgeInsets.fromLTRB(40, 0, 0, 0),
                color: Theme.of(context).hoverColor,
                child: Row(
                  mainAxisAlignment: .center,
                  children: [
                    value ? Expanded(
                      child: TextField(
                        controller: TextEditingController(text: competition.name),
                        onChanged: (value) { competition.name = value; competition.saved.value = false;},
                      ),
                    ) :
                    Expanded(
                      child: Text(competition.name, textAlign: .center)
                    ),
                    SquareButton(Icons.edit, () => editName.value = !editName.value)
                  ],
                ),
              ),
            ),
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
            ValueListenableBuilder<bool>(
              valueListenable: competition.saved, 
              builder: (context, value, child) => Container(
                padding: EdgeInsets.fromLTRB(40, 0, 0, 0),
                color: Theme.of(context).hoverColor,
                child: Row(
                  mainAxisAlignment: .center,
                  children: [
                    Expanded(
                      child: value ? 
                      Text("Сохранено", textAlign: .center) :
                      Text("Не сохранено", textAlign: .center),
                    ),
                    SquareButton(Icons.save, () => model.saveCurrent()),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class RecentCompetitionsWidget extends StatelessWidget {
  const RecentCompetitionsWidget(this. model, {super.key});

  final Model model;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: model,
      builder: (context, child) => Container(
          margin: EdgeInsets.all(10),
          color: Theme.of(context).focusColor,
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.fromLTRB(40, 0, 0, 0),
                color: Theme.of(context).hoverColor,
                child: Row(
                  mainAxisAlignment: .center,
                  children: [
                    Expanded(
                      child: Text("Сохранённые файлы", textAlign: .center),
                    ),
                    SquareButton(model.expandRecent ? Icons.expand_less : Icons.expand_more, model.changeExpandRecent)
                  ],
                ),
              ),
              if (model.expandRecent)
              model.saves.notes.isEmpty ? 
              Text("(пусто))", textAlign: .center) : 
              Column(
                children: [
                  for (var note in model.saves.notes)
                    LineButton('${note.name}${model.competition != null && model.competition!.id == note.id ? ' (открыт)' : ''}', () { 
                      if (model.competition != null && !model.competition!.saved.value) {
                        Dialogs.showConfirmDialog(context, 
                          () => model.loadCompetition(note.id),
                          'Не сохранено',
                          'Текущий открытый файл не сохранён. При открытии другого файла все изменения в текущем будут потеряны. Продолжить?'
                        );
                      }
                      else { model.loadCompetition(note.id); }
                    }),
                  LineButton('Удалить все', 
                    () => Dialogs.showConfirmDialog(context, 
                      model.clearRecent,
                      'Удаление всех файлов',
                      'Все сохранённые ранее данные будут удалены. Текущий файл (если открыт) останется в памяти. Увеерны что хотите этого?'
                    )
                  ),
                ],
              ),
            ],
          ),
      ),
    );
  }
}
