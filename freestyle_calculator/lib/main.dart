import 'package:flutter/material.dart';
import 'package:freestyle_calculator/Data/model.dart';
import 'package:freestyle_calculator/Pages/start_page.dart';

void main() {
  final Model model = Model();
  model.loadSaves();
  runApp(MyApp(model));
}

class MyApp extends StatelessWidget {
  const MyApp(this.model, {super.key});

  final Model model;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Freestyle/HTM calculator',
      theme: ThemeData(
        //textTheme: GoogleFonts.robotoTextTheme(),
        //fontFamily: 'TimesNewRoman',
        colorScheme: .fromSeed(seedColor: const Color.fromARGB(255, 4, 192, 213), brightness: Brightness.dark, contrastLevel: .5),
        textTheme: const TextTheme(
          bodyMedium: TextStyle(color: Color.fromARGB(255, 218, 218, 218)), // Standard body text
          displayMedium: TextStyle(color: Color.fromARGB(255, 242, 255, 0), fontSize: 15), // Standard body text
          bodySmall: TextStyle(color: Color.fromARGB(255, 192, 192, 192)), // Standard body text
          headlineSmall: TextStyle(color: Color.fromARGB(255, 152, 152, 152)), // Large headlines
          titleSmall: TextStyle(color: Colors.black), // Large headlines
        ),
        appBarTheme: const AppBarTheme(
          foregroundColor: Color.fromARGB(255, 205, 205, 205), // Changes all text and icon colors
        ),
      ),
      home: SatrtPage(model),
    );
  }
}
