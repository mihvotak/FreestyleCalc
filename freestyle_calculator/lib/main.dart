import 'package:flutter/material.dart';
import 'package:freestyle_calculator/Data/competition.dart';
import 'package:freestyle_calculator/Pages/competition_page.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key});

  final Competition _competition = Competition();

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Freestyle/HTM calculator',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: .fromSeed(seedColor: const Color.fromARGB(255, 4, 192, 213), brightness: Brightness.dark, contrastLevel: .5),
        textTheme: const TextTheme(
          bodyMedium: TextStyle(color: Color.fromARGB(255, 218, 218, 218)), // Standard body text
          headlineSmall: TextStyle(color: Color.fromARGB(255, 152, 152, 152)), // Large headlines
          titleSmall: TextStyle(color: Colors.black), // Large headlines
        ),
        appBarTheme: const AppBarTheme(
          foregroundColor: Color.fromARGB(255, 205, 205, 205), // Changes all text and icon colors
        ),
      ),
      home: CompetitionPage(_competition),
    );
  }
}
