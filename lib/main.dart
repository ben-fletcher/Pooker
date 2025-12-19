import 'package:flutter/material.dart';
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
        createTextTheme(context, "AR One Sans", "AR One Sans");

    MaterialTheme theme = MaterialTheme(textTheme);

    return MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (context) => GameModel()),
          Provider(create: (_) => theme)
        ],
        child: SafeArea(
          top: false,
          child: MaterialApp(
            title: 'Pooker',
            theme: theme.light(),
            darkTheme: theme.dark(),
            themeMode: ThemeMode.system,
            home: StartPage(),
            debugShowCheckedModeBanner: false,
          ),
        ));
  }

  TextTheme createTextTheme(
      BuildContext context, String bodyFontString, String displayFontString) {
    TextTheme baseTextTheme = Theme.of(context).textTheme;
    TextTheme bodyTextTheme =
        GoogleFonts.getTextTheme(bodyFontString, baseTextTheme);
    TextTheme displayTextTheme =
        GoogleFonts.getTextTheme(displayFontString, baseTextTheme);
    TextTheme textTheme = displayTextTheme.copyWith(
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
