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

              Foldout(
                caption: "Новый файл",
                children: [
                  LineButton("Из шаблона", () { 
                    if (model.competition != null && !model.competition!.saved.value) {
                      Dialogs.showConfirmDialog(context, () => model.createFromTemplateAndFill(),
                        'Не сохранено',
                        'Текущий открытый файл не сохранён. При создании нового файла все изменения в текущем будут потеряны. Продолжить?'
                      );
                    }
                    else { model.createFromTemplateAndFill(); }
                  }),
                  LineButton( 
                    "Импорт из гуглотаблицы...", 
                    () => Navigator.of(context).push(
                      CupertinoPageRoute(
                        builder: (context) => SignInDemo(model, true, false, false),
                      ),
                    )
                  ),
                ]
              ),

              if (model.competition != null)
              Foldout(
                caption: "Экспорт в гуглотаблицу",
                children: [
                  if (model.expandExport && model.competition!.sheetId != null && model.competition!.sheetName != null)
                  LineButton( 
                    "В ту же \"${model.competition!.sheetName}\"", 
                    () => Navigator.of(context).push(
                      CupertinoPageRoute(
                        builder: (context) => SignInDemo(model, false, false, true),
                      ),
                    )
                  ),
                  LineButton( 
                    "В новую таблицу", 
                    () => Navigator.of(context).push(
                      CupertinoPageRoute(
                        builder: (context) => SignInDemo(model, false, true, false),
                      ),
                    )
                  ),
                  LineButton( 
                    "В существующую...", 
                    () => Navigator.of(context).push(
                      CupertinoPageRoute(
                        builder: (context) => SignInDemo(model, false, false, false),
                      ),
                    )
                  ),
                ],
              ),
              
              Foldout(
                caption: "Сохранённые файлы",
                children: [
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

            ],
          ),
        ),
      ),
    );
  }
}

class Foldout extends StatefulWidget {
  Foldout({required this.caption, required this.children, this.opened = false, super.key});

  final String caption;
  final List<Widget> children;
  bool opened;

  @override
  State<Foldout> createState() => _FoldoutState();
}

class _FoldoutState extends State<Foldout> {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(10),
      color: Theme.of(context).focusColor,
      child: Column(
        children: [
          MaterialButton(
            onPressed: () {
              setState(() {
                widget.opened = !widget.opened;
              });            },
            child: Container(
              constraints: BoxConstraints.expand(height: 50),
              margin: EdgeInsets.all(1),
              padding: EdgeInsets.fromLTRB(40, 0, 0, 0),
              color: Theme.of(context).hoverColor,
              child: Row(
                mainAxisAlignment: .center,
                children: [
                  Expanded(
                    child: Text(widget.caption, textAlign: .center),
                  ),
                  Icon(widget.opened ? Icons.expand_less : Icons.expand_more)
                ],
              ),
            ),
          ),
          if (widget.opened)
          for (var child in widget.children)
          child,
        ],
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
