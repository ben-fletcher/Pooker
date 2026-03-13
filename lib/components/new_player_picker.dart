import 'package:flutter/material.dart';
import 'package:pooker_score/helpers/player_helpers.dart';
import 'package:pooker_score/models/game_model.dart';
import 'package:pooker_score/models/player.dart';
import 'package:pooker_score/services/database_service.dart';

class NewPlayerPicker extends StatefulWidget {
  final GameModel gameModel;
  final ScrollController scrollController;

  const NewPlayerPicker(
      {super.key, required this.gameModel, required this.scrollController});

  @override
  State<NewPlayerPicker> createState() => _NewPlayerPickerState();
}

class _NewPlayerPickerState extends State<NewPlayerPicker> {
  List<String> selectedPlayers = [];
  Future<List<String>> _playersFuture = GameDatabaseService.loadPlayers();

  void playerTapped(player) {
    setState(() {
      if (selectedPlayers.contains(player)) {
        selectedPlayers.remove(player);
      } else {
        selectedPlayers.add(player);
      }
    });
  }

  void addPlayers() {
    for (var p in selectedPlayers) {
      widget.gameModel.addPlayer(
          Player(id: widget.gameModel.players.length + 1, name: p, turns: []));
    }

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: FutureBuilder(
          future: _playersFuture,
          builder: (context, snapshot) {
            final players = snapshot.data!
                .where((player) =>
                    !widget.gameModel.players.any((p) => p.name == player))
                .toList();

            return Column(
              spacing: 20,
              children: [
                Text("Add Player",
                    style: Theme.of(context).textTheme.titleLarge!),
                snapshot.hasData
                    ? Expanded(
                        child: ListView.separated(
                            controller: widget.scrollController,
                            itemBuilder: (context, i) {
                              if (i == players.length) {
                                return Container(
                                  padding: EdgeInsets.symmetric(horizontal: 20),
                                  width: double.infinity,
                                  child: FilledButton.tonal(
                                      onPressed: () {
                                        showAddPlayerDialog(context)
                                            .then((value) {
                                          setState(() {
                                            _playersFuture = GameDatabaseService
                                                .loadPlayers();
                                          });
                                        });
                                      },
                                      child: Text("New Player")),
                                );
                              }

                              final selected =
                                  selectedPlayers.contains(players[i]);
                              return Card(
                                elevation: 0,
                                color: selected
                                    ? Theme.of(context)
                                        .colorScheme
                                        .primaryContainer
                                    : null,
                                child: ListTile(
                                  selected: selected,
                                  selectedColor: Theme.of(context)
                                      .colorScheme
                                      .onPrimaryContainer,
                                  title: Text(players[i]),
                                  trailing: IconButton(
                                      icon: Icon(
                                          selected ? Icons.remove : Icons.add),
                                      onPressed: () =>
                                          playerTapped(players[i])),
                                  onTap: () => playerTapped(players[i]),
                                ),
                              );
                            },
                            separatorBuilder: (_, __) => const Divider(),
                            itemCount: players.length + 1),
                      )
                    : const Center(child: CircularProgressIndicator()),
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 30.0, vertical: 10),
                  child: SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: addPlayers,
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 32, vertical: 16),
                        textStyle: TextStyle(
                            fontSize: 22, fontWeight: FontWeight.bold),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      icon: const Icon(Icons.add, size: 32),
                      label: const Text('Add',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          )),
                    ),
                  ),
                ),
              ],
            );
          }),
    );
  }
}
