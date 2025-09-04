import 'package:flutter/material.dart';
import 'package:pooker_score/helpers/player_helpers.dart';
import 'package:pooker_score/pages/player_detail.dart';
import 'package:pooker_score/services/database_service.dart';

class PlayerScreen extends StatefulWidget {
  const PlayerScreen({super.key});

  @override
  State<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen> {
  Future<List<String>> players = GameDatabaseService.loadPlayers();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Players'),
      ),
      body: Column(
        children: [
          FutureBuilder(
              future: players,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting &&
                    snapshot.hasData == false) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                return Expanded(
                  child: ListView.builder(
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      final player = snapshot.data![index];
                      return ListTile(
                        title: Text(player),
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => PlayerDetailScreen(
                                playerName: player,
                              ),
                            ),
                          );
                        },
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                                onPressed: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) => PlayerDetailScreen(
                                        playerName: player,
                                      ),
                                    ),
                                  );
                                },
                                icon: Icon(Icons.bar_chart_rounded)),
                            IconButton(
                                onPressed: () async {
                                  // Confirm the deletion
                                  bool? confirm = await showDialog<bool>(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: Text('Delete Player'),
                                      content: Text('Are you sure you want to delete this player?'),
                                      actions: [
                                        TextButton(
                                          onPressed: () => Navigator.of(context).pop(false),
                                          child: Text('Cancel'),
                                        ),
                                        TextButton(
                                          onPressed: () => Navigator.of(context).pop(true),
                                          style: TextButton.styleFrom(
                                            foregroundColor: Theme.of(context).colorScheme.error,
                                          ),
                                          child: const Text('Delete'),
                                        ),
                                      ],
                                    ),
                                  );
                                  if (confirm == true) {
                                    GameDatabaseService.deletePlayer(player);
                                    setState(() {
                                      players = GameDatabaseService.loadPlayers();
                                    });
                                  }
                                },
                                icon: Icon(
                                  Icons.delete_outline_rounded,
                                  color: Theme.of(context).colorScheme.error,
                                )),
                          ],
                        ),
                      );
                    },
                  ),
                );
              })
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
          label: Text("Add Player"),
          icon: Icon(Icons.add),
          onPressed: () {
            showAddPlayerDialog(context).then((value) {
              setState(() {
                players = GameDatabaseService.loadPlayers();
              });
            });
          }),
    );
  }
}
