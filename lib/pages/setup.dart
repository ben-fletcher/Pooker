import 'package:flutter/material.dart';
import 'package:pooker_score/models/game_model.dart';
import 'package:pooker_score/models/player.dart';
import 'package:pooker_score/pages/game_settings.dart';
import 'package:pooker_score/services/database_service.dart';
import 'package:pooker_score/theme.dart';
import 'package:provider/provider.dart';

class SetupPage extends StatefulWidget {
  const SetupPage({super.key});

  @override
  State<SetupPage> createState() => _SetupPageState();
}

class _SetupPageState extends State<SetupPage> {
  void _addPlayer(String player, GameModel gameModel) {
    final newPlayer =
        Player(id: gameModel.players.length + 1, name: player, turns: []);
    gameModel.addPlayer(newPlayer);
  }

  void _removePlayer(GameModel gameModel, int index) {
    gameModel.removePlayer(index);
    // Re-index the players
    for (var i = 0; i < gameModel.players.length; i++) {
      gameModel.players[i].id = i + 1;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<GameModel>(builder: (context, gameModel, _) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('New Game', style: TextStyle(fontSize: 24)),
          actions: [
            IconButton(
                onPressed: () {
                  gameModel.orderPlayersAlphabetically();
                },
                icon: Icon(Icons.sort_by_alpha)),
            IconButton(
              icon: const Icon(Icons.shuffle),
              onPressed: () {
                gameModel.shufflePlayers();
              },
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            //crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              Expanded(
                child: Builder(builder: (context) {
                  if (gameModel.players.isEmpty) {
                    return const Center(
                      child: Text('No players added yet'),
                    );
                  }

                  return ReorderableListView.builder(
                    itemCount: gameModel.players.length,
                    onReorder: (oldIndex, newIndex) {
                      if (newIndex > oldIndex) newIndex -= 1;
                      final player = gameModel.players.removeAt(oldIndex);
                      gameModel.players.insert(newIndex, player);
                      // Re-index the players
                      for (var i = 0; i < gameModel.players.length; i++) {
                        gameModel.players[i].id = i + 1;
                      }
                      setState(() {});
                    },
                    itemBuilder: (context, index) {
                      return Card(
                        key: ValueKey(gameModel.players[index].id),
                        child: ListTile(
                          title: Text(gameModel.players[index].name,
                              style: TextStyle(fontSize: 18)),
                          trailing: IconButton(
                            icon: Icon(Icons.remove_circle, color: Colors.red),
                            onPressed: () => _removePlayer(gameModel, index),
                          ),
                        ),
                      );
                    },
                  );
                }),
              ),
              _buildPlayerSelector(gameModel),
              const SizedBox(height: 16),
              Center(
                child: FilledButton.icon(
                  onPressed: gameModel.players.isNotEmpty
                      ? () {
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (_) => GameSettingsPage()));
                        }
                      : null,
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 32, vertical: 16),
                    backgroundColor:
                        gameModel.players.isNotEmpty ? null : Colors.grey,
                    textStyle: TextStyle(fontSize: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  icon: const Icon(Icons.skip_next_sharp, size: 32),
                  label: const Text('Next',
                      style: TextStyle(
                        fontFamily: 'Comic Sans MS',
                        fontWeight: FontWeight.bold,
                      )),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildPlayerSelector(GameModel gameModel) {
    return FutureBuilder(
        future: GameDatabaseService.loadPlayers(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting &&
              snapshot.hasData == false) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          return Expanded(
            child: Card.outlined(
              child: ListView.builder(
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index) {
                  final player = snapshot.data![index];

                  if (gameModel.players
                      .any((element) => element.name == player)) {
                    return const SizedBox.shrink();
                  }

                  return ListTile(
                    title: Text(player, style: TextStyle(fontSize: 20)),
                    trailing: IconButton(
                      onPressed: () {
                        _addPlayer(player, gameModel);
                      },
                      icon: Icon(Icons.add),
                      iconSize: 30,
                    ),
                  );
                },
              ),
            ),
          );
        });
  }
}
