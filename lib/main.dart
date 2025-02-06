import 'package:flutter/material.dart';
import 'package:pooker_score/models/game_model.dart';
import 'package:pooker_score/pages/start.dart';
import 'package:pooker_score/themes.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => GameModel(),
      child: MaterialApp(
        title: 'Pooker',
        theme: LightTheme,
        darkTheme: DarkTheme,
        themeMode: ThemeMode.dark,
        home: StartPage(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
