import 'dart:math';

import 'package:flutter/material.dart';
import 'package:pooker_score/helpers/player_helpers.dart';
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
  Future<List<String>> _playersFuture = GameDatabaseService.loadPlayers();

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
          padding: const EdgeInsets.all(10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.only(left: 10.0, bottom: 5.0),
                child: Text('Current Players (${gameModel.players.length})',
                    style: TextStyle(fontSize: 20)),
              ),
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
                      return _buildPlayerCard(gameModel, index);
                    },
                  );
                }),
              ),
              const Padding(
                padding: EdgeInsets.only(left: 10.0, bottom: 5.0),
                child: Text('Add Players', style: TextStyle(fontSize: 20)),
              ),
              _buildPlayerSelector(gameModel),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
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
                    textStyle:
                        TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  icon: const Icon(Icons.skip_next_sharp, size: 32),
                  label: const Text('Next',
                      style: TextStyle(
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

  Widget _buildPlayerCard(GameModel gameModel, int index) {
    return Card(
      elevation: 5,
      key: ValueKey(gameModel.players[index].id),
      child: Stack(
        children: [
          ListTile(
            leading: CircleAvatar(
              radius: 16,
              child: Icon(Icons.person,
                  color: Theme.of(context).colorScheme.onSurface),
            ),
            title:
                Text(gameModel.players[index].name, style: TextStyle(fontSize: 18)),
            trailing: IconButton(
              icon: Icon(Icons.remove_circle_outline, color: Colors.red),
              onPressed: () => _removePlayer(gameModel, index),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlayerSelector(GameModel gameModel) {
    return FutureBuilder(
        future: _playersFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting &&
              snapshot.hasData == false) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final playersToAdd = snapshot.data!.where((element) =>
              !gameModel.players.any((player) => player.name == element));

          return Expanded(
            child: GridView.builder(
              itemCount: playersToAdd.length + 1,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2, mainAxisExtent: 70),
              itemBuilder: (context, index) {
                if (index == playersToAdd.length) {
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: FilledButton.icon(
                      onPressed: () {
                        showAddPlayerDialog(context).then((value) {
                          setState(() {
                            _playersFuture = GameDatabaseService.loadPlayers();
                          });
                        });
                      },
                      icon: Icon(Icons.add),
                      label: Text('Add Player'),
                    ),
                  );
                }

                final player = playersToAdd.elementAt(index);

                return Card(
                  child: Center(
                    child: ListTile(
                      title: Text(player, style: TextStyle(fontSize: 18)),
                      trailing: IconButton(
                        onPressed: () {
                          _addPlayer(player, gameModel);
                        },
                        icon: Icon(Icons.add),
                        iconSize: 30,
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        });
  }
}
