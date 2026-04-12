import 'package:flutter/material.dart';
import 'package:freestyle_calculator/Data/pair_data.dart';
import 'package:freestyle_calculator/Pages/elements.dart';

class PairEditPage extends StatelessWidget {
  const PairEditPage({super.key, required this.pair});

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
        child: Column(
          mainAxisAlignment: .center,
          children: [
            EditableBox('Имя хендлера', pair.handlerName, (value) => pair.setHaldlerName(value), false),
            EditableBox('Порода собаки', pair.dogBreed, (value) => pair.setDogBreed(value), false),
            EditableBox('Кличка собаки', pair.dogName, (value) => pair.setDogName(value), false),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => { pair.remove(), Navigator.of(context).pop() },
        tooltip: 'Remove',
        child: const Icon(Icons.remove_circle_outline),
      ),
    );
  }
}

