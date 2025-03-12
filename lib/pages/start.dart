import 'package:flutter/material.dart';
import 'package:pooker_score/models/game_model.dart';
import 'package:pooker_score/pages/history.dart';
import 'package:pooker_score/pages/setup.dart';
import 'package:pooker_score/pages/replay.dart';
import 'package:provider/provider.dart';

class StartPage extends StatelessWidget {
  const StartPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/pool_table_background.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
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
                  fontSize: 82,
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
              ElevatedButton.icon(
                icon: Icon(Icons.play_arrow, size: 32),
                label: Text(
                  "Start",
                  style: TextStyle(fontSize: 24),
                ),
                onPressed: () {
                  Provider.of<GameModel>(context, listen: false).reset();
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => const SetupPage()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                ),
              ),
              SizedBox(height: 10),
              FilledButton.tonalIcon(
                  icon: Icon(Icons.history),
                  label: Text("History"),
                  onPressed: () {
                    Provider.of<GameModel>(context, listen: false).reset();
                    Navigator.of(context).push(
                      MaterialPageRoute(
                          builder: (context) => const HistoryPage()),
                    );
                  }),
              SizedBox(height: 10),
              FilledButton.tonalIcon(
                  icon: Icon(Icons.replay),
                  label: Text("Replay"),
                  onPressed: () {
                    Provider.of<GameModel>(context, listen: false).reset();
                    Navigator.of(context).push(
                      MaterialPageRoute(
                          builder: (context) => const ReplayPage()),
                    );
                  }),
            ],
          ),
        ),
      ),
    );
  }
}
