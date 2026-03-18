import 'package:flutter/material.dart';
import 'package:pooker_score/components/podium.dart';
import 'package:pooker_score/helpers/player_helpers.dart';
import 'package:pooker_score/models/game_model.dart';
import 'package:pooker_score/pages/start.dart';
import 'package:provider/provider.dart';
import 'package:confetti/confetti.dart';
import 'dart:math';

class FinishPage extends StatefulWidget {
  const FinishPage({super.key});

  @override
  State<FinishPage> createState() => _FinishPageState();
}

class _FinishPageState extends State<FinishPage> {
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _confettiController =
        ConfettiController(duration: const Duration(seconds: 5));
    _confettiController.play();
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

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
      body: Stack(
        children: [
          Consumer<GameModel>(
            builder: (context, gameModel, child) {
              gameModel.saveGame();

              // Sort players by score in descending order
              final players = getOrderPlayers(gameModel.players);
              final winner = players.isNotEmpty ? players.first : null;
              final secondPlace = players.length > 1 ? players[1] : null;
              final thirdPlace = players.length > 2 ? players[2] : null;

              return RefreshIndicator(
                onRefresh: () async => _confettiController.play(),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 32.0),
                    child: CustomScrollView(
                      slivers: [
                        if (winner != null ||
                            secondPlace != null ||
                            thirdPlace != null)
                          SliverToBoxAdapter(
                            child: Column(
                              children: [
                                Podium(
                                  winner: winner,
                                  secondPlace: secondPlace,
                                  thirdPlace: thirdPlace,
                                ),
                                const SizedBox(height: 50),
                                Divider(),
                              ],
                            ),
                          ),
                        SliverList.builder(
                          itemCount: players.length,
                          itemBuilder: (context, index) {
                            final colors = getPlayerColor(index);
                            return ListTile(
                              leading: CircleAvatar(
                                backgroundColor: colors.$1,
                                foregroundColor: colors.$2,
                                child: Text((index + 1).toString()),
                              ),
                              title: Text(players[index].name),
                              trailing: Text(players[index].score.toString(),
                                  style: TextStyle(fontSize: 20)),
                            );
                          },
                        ),
                        SliverToBoxAdapter(
                          child: Column(
                            children: [
                              const SizedBox(height: 30),
                            ],
                          ),
                        ),
                        SliverGrid.list(
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            mainAxisExtent: 95,
                          ),
                          children: [
                            _buildStatCard(
                                Theme.of(context),
                                'Highest Break',
                                _calculateHighestBreakPlayer(gameModel),
                                Colors.purpleAccent),
                            _buildStatCard(
                                Theme.of(context),
                                'Most Fouls',
                                _calculateMostFoulsPlayer(gameModel),
                                Colors.red),
                          ],
                        )
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirection: pi / 2,
              maxBlastForce: 5,
              minBlastForce: 2,
              emissionFrequency: 0.05,
              numberOfParticles: 20,
              gravity: 0.1,
            ),
          ),
        ],
      ),
    );
  }

  Card _buildStatCard(ThemeData theme, String title,
      (String player, String value) values, Color color) {
    return Card.outlined(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            Text(title,
                style: TextStyle(
                    fontSize: theme.textTheme.bodyLarge!.fontSize,
                    color: color)),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Flexible(
                    fit: FlexFit.loose,
                    child: Text(values.$1,
                        style: theme.textTheme.headlineMedium!
                            .copyWith(overflow: TextOverflow.ellipsis))),
                if (values.$2.isNotEmpty)
                  Text("(${values.$2})",
                      style: theme.textTheme.headlineMedium!
                          .copyWith(overflow: TextOverflow.ellipsis)),
              ],
            )
          ],
        ),
      ),
    );
  }

  (Color?, Color?) getPlayerColor(int index) {
    switch (index) {
      case 0:
        return (Colors.amber, Colors.black);
      case 1:
        return (Colors.grey, Colors.white);
      case 2:
        return (Colors.brown, Colors.white);
      default:
        return (null, null);
    }
  }

  (String, String) _calculateMostFoulsPlayer(GameModel gameModel) {
    final fouls = gameModel.turnHistory.where((p) => p.event.foul == true);
    final playerCounts = <int, int>{};
    for (var f in fouls) {
      playerCounts[f.playerIndex] = (playerCounts[f.playerIndex] ?? 0) + 1;
    }

    var entries = playerCounts.entries.toList();
    entries.sort((a, b) => a.value.compareTo(b.value));

    if (entries.isEmpty) {
      return ('N/A', '');
    }

    return (
      gameModel.players[entries.last.key].name,
      entries.last.value.toString()
    );
  }

  (String, String) _calculateHighestBreakPlayer(GameModel gameModel) {
    int maxShots = 0;
    int maxShotsPlayerIndex = -1;
    int currentShots = 0;

    for (var turn in gameModel.turnHistory) {
      if ((turn.event.potted == false || turn.event.foul == true) &&
          !(turn.event.potted == false && turn.score > 0)) {
        currentShots = 0;
        continue;
      }

      currentShots += turn.score;

      if (currentShots > maxShots) {
        maxShotsPlayerIndex = turn.playerIndex;
        maxShots = currentShots;
      }
    }

    if (maxShotsPlayerIndex == -1) {
      return ('N/A', '');
    }

    return (gameModel.players[maxShotsPlayerIndex].name, maxShots.toString());
  }
}
