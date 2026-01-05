import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pooker_score/models/game_model.dart';
import 'package:pooker_score/pages/start.dart';
import 'package:pooker_score/services/database_service.dart';
import 'package:pooker_score/theme.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GameDatabaseService.initDatabase();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    TextTheme textTheme =
        createTextTheme(context);

    MaterialTheme theme = MaterialTheme(textTheme);

    return MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (context) => GameModel()),
          Provider(create: (_) => theme)
        ],
        child: MaterialApp(
          title: 'Pooker',
          theme: theme.light(),
          darkTheme: theme.dark(),
          themeMode: ThemeMode.dark,
          home: StartPage(),
          builder: (context, child) => SafeArea(
            top: false,
            child: child!,
          ),
          debugShowCheckedModeBanner: false,
        ));
  }

  TextTheme createTextTheme(
      BuildContext context) {
    TextTheme baseTextTheme = Theme.of(context).textTheme;
    TextTheme bodyTextTheme = GoogleFonts.preahvihearTextTheme(baseTextTheme);

    TextTheme textTheme = bodyTextTheme.copyWith(
      bodyLarge: bodyTextTheme.bodyLarge,
      bodyMedium: bodyTextTheme.bodyMedium,
      bodySmall: bodyTextTheme.bodySmall,
      labelLarge: bodyTextTheme.labelLarge,
      labelMedium: bodyTextTheme.labelMedium,
      labelSmall: bodyTextTheme.labelSmall,
    );
    return textTheme;
  }
}
