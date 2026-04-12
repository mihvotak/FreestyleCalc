import 'package:flutter/material.dart';

class EditableBox extends StatelessWidget {
  const EditableBox(this.name, this.value, this.changed, this.isDigits, {super.key});

  final String name;
  final String value;
  final Function(String value) changed;
  final bool isDigits;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
            Text(
              name,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            TextField(
              keyboardType: isDigits ? TextInputType.number : TextInputType.text,
              textAlign: .center,
              onChanged: changed,
              controller: TextEditingController(text: value),
            ),
      ],
    );
  }
}

class ToggleBox extends StatelessWidget {
  ToggleBox(this.name, this.value, this.changed, {super.key});

  final String name;
  final bool value;
  final Function(bool? value) changed;
  final ValueNotifier<bool> _isChecked = ValueNotifier<bool>(false);

  @override
  Widget build(BuildContext context) {
    _isChecked.value = value;
    return Column(
      children: [
        Text(
          name,
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        ValueListenableBuilder<bool>(
          valueListenable: _isChecked,
          builder: (context, value, child) {
            return Checkbox(
              onChanged: (newValue) => { _isChecked.value = newValue!, changed(newValue)},
              value: value,
            );
          },
        ),
      ],
    );
  }
}

class CellWithText extends StatelessWidget {
  const CellWithText({super.key, required this.width, required this.text});
  
  final int width;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: width,
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.inversePrimary,
        ),
        margin: EdgeInsets.all(5),
        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 5),
        child: Text(
          text,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      )
      //width: 40,
    );
  }
}