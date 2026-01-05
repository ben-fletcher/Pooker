import 'package:flutter/material.dart';
import 'package:pooker_score/models/game_model.dart';
import 'package:pooker_score/pages/history.dart';
import 'package:pooker_score/pages/players.dart';
import 'package:pooker_score/pages/rules.dart';
import 'package:pooker_score/pages/settings.dart';
import 'package:pooker_score/pages/setup.dart';
import 'package:pooker_score/theme.dart';
import 'package:provider/provider.dart';

class StartPage extends StatelessWidget {
  const StartPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<MaterialTheme>(builder: (context, theme, _) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          actions: [
            IconButton(
              icon: Icon(
                Icons.settings,
                color: Colors.white,
              ),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                      builder: (context) => const SettingsPage()),
                );
              },
            ),
          ],
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Spacer(flex: 4),
              const Text(
                "Welcome to",
                style: TextStyle(
                  fontSize: 24,
                  color: Colors.white,
                  shadows: [
                    Shadow(
                      blurRadius: 10.0,
                      color: Colors.black,
                      offset: Offset(5.0, 5.0),
                    ),
                  ],
                ),
              ),
              Text(
                "Pooker",
                style: Theme.of(context).textTheme.displayLarge?.copyWith(
                  color: Colors.white,
                  fontSize: 72,
                  shadows: [
                    Shadow(
                      blurRadius: 10.0,
                      color: Colors.black,
                      offset: Offset(5.0, 5.0),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 50),
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(horizontal: 30, vertical: 0),
                child: FilledButton.icon(
                  icon: Icon(Icons.play_circle_fill, size: 30),
                  label: Text(
                    "Start New Game",
                    style: TextStyle(fontSize: 22),
                  ),
                  onPressed: () {
                    Provider.of<GameModel>(context, listen: false).reset();
                    Navigator.of(context).push(
                      MaterialPageRoute(
                          builder: (context) => const SetupPage()),
                    );
                  },
                  style: FilledButton.styleFrom(
                    elevation: 6,
                    shadowColor: Theme.of(context).colorScheme.primary,
                    padding: EdgeInsets.symmetric(horizontal: 30, vertical: 14),
                  ),
                  
                ),
              ),
              Spacer(flex: 3,),
              TextButton.icon(
                  icon: Icon(Icons.help_outline, color: Colors.white),
                  label: Text("How to Play", style: TextStyle(color: Colors.white, fontSize: 18)),
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                          builder: (context) => const RulesPage()),
                    );
                  }),
      
              SizedBox(height: 25),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  FilledButton.tonalIcon(
                      icon: Icon(Icons.history),
                      label: Text("History", style: TextStyle(fontSize: 18)),
                      onPressed: () {
                        Provider.of<GameModel>(context, listen: false)
                            .reset();
                        Navigator.of(context).push(
                          MaterialPageRoute(
                              builder: (context) => const HistoryPage()),
                        );
                      }),
                  SizedBox(width: 30),
                  FilledButton.tonalIcon(
                      icon: Icon(Icons.people),
                      label: Text("Players", style: TextStyle(fontSize: 18)),
                      onPressed: () {
                        Provider.of<GameModel>(context, listen: false)
                            .reset();
                        Navigator.of(context).push(
                          MaterialPageRoute(
                              builder: (context) => const PlayerScreen()),
                        );
                      })
                ],
              ),
              SizedBox(height: 30),
            ],
          ),
        ),
      );
    });
  }
}
