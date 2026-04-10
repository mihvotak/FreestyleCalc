import 'package:flutter/material.dart';
import 'package:freestyle_calculator/Data/pair_data.dart';

class PairEditPage extends StatefulWidget {
  const PairEditPage({super.key, required this.pair});

  final Pair pair;

  @override
  State<PairEditPage> createState() => _PairEditPageState();
}

class _PairEditPageState extends State<PairEditPage> {

  void _addPair() {
    setState(() {
      //
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text("${widget.pair.startNumber}"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: .center,
          children: [
            Text(
              'Имя хендлера',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            TextField(
              
            )
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addPair,
        tooltip: 'Increment',
        child: const Icon(Icons.back_hand),
      ),
    );
  }

}