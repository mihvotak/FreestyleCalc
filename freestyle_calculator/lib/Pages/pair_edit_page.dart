import 'package:flutter/material.dart';
import 'package:freestyle_calculator/Data/competition.dart';
import 'package:freestyle_calculator/Data/pair_data.dart';
import 'package:freestyle_calculator/Pages/elements.dart';

class PairEditPage extends StatelessWidget {
  const PairEditPage({super.key, required this.competition, required this.pair});

  final Competition competition;
  final Pair pair;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: ListenableBuilder(
          listenable: pair,
          builder: (context, child) {
            return Text("${pair.startNumber}: ${pair.handlerName}");
          },
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: .center,
            children: [
              Column(
                children: [
                  EditableBox('Cтартовый номер', pair.startNumber.toString(), (value) {pair.setStartNumber(value); competition.saved.value = false;}, false),
                  Text('Класс', style: Theme.of(context).textTheme.headlineSmall),
                  ListenableBuilder(
                    listenable: pair,
                    builder: (context, child) {
                      return DropdownButton<ClassKind>(
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        value: pair.classKind,
                        icon: const Icon(Icons.arrow_downward),
                        elevation: 16,
                        onChanged: (ClassKind? value) {
                            pair.setClassKind(value ?? ClassKind.outOfScoring);
                        },
                        items: ClassKind.values.map<DropdownMenuItem<ClassKind>>((ClassKind value) {
                          return DropdownMenuItem<ClassKind>(value: value, child: Text(value.toUserString()));
                        }).toList(),
                      );
                    }
                  ),
                ],
              ),
              EditableBox('Имя хендлера', pair.handlerName, (value) {pair.setHaldlerName(value); competition.saved.value = false;}, false),
              EditableBox('Порода собаки', pair.dogBreed, (value) {pair.setDogBreed(value); competition.saved.value = false;}, false),
              EditableBox('Кличка собаки', pair.dogName, (value) {pair.setDogName(value); competition.saved.value = false;}, false),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () { 
          competition.removePair(pair);  
          competition.saved.value = false;
          Navigator.of(context).pop(); 
        },
        tooltip: 'Remove',
        child: const Icon(Icons.remove_circle_outline),
      ),
    );
  }
}

