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
      body: SafeArea(
        child: FutureBuilder(
            future: players,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting &&
                  snapshot.hasData == false) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }

              return Card(
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: snapshot.data!.length,
                  separatorBuilder: (_, __) => const Divider(),
                  itemBuilder: (context, index) {
                    final player = snapshot.data![index];
                    return ListTile(
                      title: Text(player,
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: FutureBuilder(
                          future:
                              GameDatabaseService.getPlayerStatistics(player),
                          builder: (context, asyncSnapshot) {
                            return Wrap(
                              spacing: 8,
                              children: [
                                Chip(
                                    label: Text(
                                      "Games: ${asyncSnapshot.data?['gamesPlayed']}",
                                      style: TextStyle(fontSize: 12),
                                    ),
                                    side: BorderSide(
                                        color: Colors.blue.shade800,
                                        width: 0.3),
                                    visualDensity: VisualDensity.compact,
                                    padding: EdgeInsets.all(0)),
                                Chip(
                                    label: Text(
                                        "High Score: ${asyncSnapshot.data?['highestScore']}",
                                        style: TextStyle(fontSize: 12)),
                                    side: BorderSide(
                                        color: Colors.amber, width: 0.3),
                                    visualDensity: VisualDensity.compact,
                                    padding: EdgeInsets.all(0)),
                              ],
                            );
                          }),
                      leading: Icon(Icons.person),
                      onTap: () async {
                        final reload = await Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => PlayerDetailScreen(
                              playerName: player,
                            ),
                          ),
                        );
                        if (reload == true) {
                          setState(() {
                            players = GameDatabaseService.loadPlayers();
                          });
                        }
                      },
                    );
                  },
                ),
              );
            }),
      ),
      floatingActionButton: FloatingActionButton.extended(
          label: Text("Add Player"),
          icon: Icon(Icons.add),
          isExtended: false,
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
