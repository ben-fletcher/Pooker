import 'package:flutter/material.dart';
import 'package:pooker_score/models/game_model.dart';
import 'package:pooker_score/pages/history.dart';
import 'package:pooker_score/pages/players.dart';
import 'package:pooker_score/pages/settings.dart';
import 'package:pooker_score/pages/setup.dart';
import 'package:pooker_score/theme.dart';
import 'package:provider/provider.dart';

class StartPage extends StatelessWidget {
  const StartPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<MaterialTheme>(builder: (context, theme, _) {
      return Theme(
        data: theme.lightHighContrast(),
        child: Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/pool_table_background.jpg'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Scaffold(
              backgroundColor: Colors.transparent,
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
                    Spacer(),
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
                    SizedBox(height: 20),
                    FilledButton.icon(
                      icon: Icon(Icons.play_arrow, size: 32),
                      label: Text(
                        "Start",
                        style: TextStyle(fontSize: 24),
                      ),
                      onPressed: () {
                        Provider.of<GameModel>(context, listen: false).reset();
                        Navigator.of(context).push(
                          MaterialPageRoute(
                              builder: (context) => const SetupPage()),
                        );
                      },
                      style: FilledButton.styleFrom(
                        backgroundColor: Colors.green.shade700,
                        padding:
                            EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                      ),
                    ),
                    Spacer(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        FilledButton.tonalIcon(
                            icon: Icon(Icons.history),
                            label: Text("History"),
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
                            label: Text("Players"),
                            onPressed: () {
                              Provider.of<GameModel>(context, listen: false)
                                  .reset();
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                    builder: (context) => const PlayerScreen()),
                              );
                            }),
                      ],
                    ),
                    SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    });
  }
}
