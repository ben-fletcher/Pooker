import 'package:flutter/material.dart';
import 'package:pooker_score/models/game_model.dart';
import 'package:pooker_score/pages/start.dart';
import 'package:provider/provider.dart';

class FinishPage extends StatelessWidget {
  const FinishPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Game Over'),
        actions: [
          IconButton(
            icon: Icon(Icons.exit_to_app),
            onPressed: () {
              Provider.of<GameModel>(context, listen: false).reset();
              Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => StartPage()), (_) => false);
            },
          ),
        ],
      ),
      body: Consumer<GameModel>(
        builder: (context, gameModel, child) {
          // Sort players by score in descending order
          final players = gameModel.players;
          players.sort((a, b) => b.score.compareTo(a.score));
          final winner = players.isNotEmpty ? players.first : null;
          final secondPlace = players.length > 1 ? players[1] : null;
          final thirdPlace = players.length > 2 ? players[2] : null;

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                const SizedBox(height: 16),
                if (winner != null || secondPlace != null || thirdPlace != null)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      if (secondPlace != null)
                        Column(
                          children: [
                            Icon(
                              Icons.emoji_events,
                              size: 80,
                              color: Colors.grey,
                            ),
                            Text(
                              secondPlace.Name,
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      if (winner != null)
                        Column(
                          children: [
                            Icon(
                              Icons.emoji_events,
                              size: 100,
                              color: Colors.amber,
                            ),
                            Text(
                              winner.Name,
                              style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: Colors.amber,
                              ),
                            ),
                          ],
                        ),
                      if (thirdPlace != null)
                        Column(
                          children: [
                            Icon(
                              Icons.emoji_events,
                              size: 60,
                              color: Colors.brown,
                            ),
                            Text(
                              thirdPlace.Name,
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.brown,
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                const SizedBox(height: 50),
                Divider(),
                const SizedBox(height: 16),
                Expanded(
                  child: ListView.builder(
                    itemCount: players.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        leading: CircleAvatar(
                          child: Text((index + 1).toString()),
                        ),
                        title: Text(players[index].Name),
                        trailing: Text(players[index].score.toString()),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
