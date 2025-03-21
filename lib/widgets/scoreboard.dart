import 'package:flutter/material.dart';
import 'package:pooker_score/models/game_model.dart';
import 'package:pooker_score/models/turn.dart';
import 'package:provider/provider.dart';

class Scoreboard extends StatelessWidget {
  const Scoreboard({super.key});

  @override
  Widget build(BuildContext context) {
    final ScrollController scrollController = ScrollController();

    return Consumer<GameModel>(
      builder: (context, gameModel, child) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          final activePlayerIndex =
              gameModel.players.indexOf(gameModel.activePlayer);
          if (activePlayerIndex != -1) {
            final targetOffset = activePlayerIndex *
                70.0; // Assuming each row has a height of 70.0
            if (targetOffset <=
                scrollController.position.maxScrollExtent + 35) {
              scrollController.animateTo(
                targetOffset,
                duration: Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              );
            }
          }
        });

        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: Card(
            elevation: 8,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(25),
            ),
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Text(
                      'Scoreboard',
                      style: TextStyle(
                        fontSize: 24,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        shadows: [
                          Shadow(
                            blurRadius: 10.0,
                            color: Colors.black,
                            offset: Offset(5.0, 5.0),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Remaining Balls: ${gameModel.remainingBalls}',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 10),
                  Expanded(
                    child: SingleChildScrollView(
                      controller: scrollController,
                      child: DataTable(
                        columnSpacing: 20.0,
                        dataRowMaxHeight: 70.0,
                        columns: const [
                          DataColumn(
                              label: Text('Player',
                                  style: TextStyle(color: Colors.white))),
                          DataColumn(
                              label: Text('Score',
                                  style: TextStyle(color: Colors.white))),
                          DataColumn(
                              label: Text('Turns',
                                  style: TextStyle(color: Colors.white))),
                        ],
                        rows: gameModel.players.map((player) {
                          final isActive = gameModel.activePlayer == player;
                          final playerTurns = player.turns;
                          return DataRow(
                            cells: [
                              DataCell(
                                Text(player.name,
                                    style: TextStyle(color: Colors.white)),
                              ),
                              DataCell(
                                Text(player.score.toString(),
                                    style: TextStyle(color: Colors.white)),
                              ),
                              DataCell(
                                Wrap(
                                  spacing: 2.0,
                                  runSpacing: 2.0,
                                  children: [
                                    ...playerTurns.map((turn) {
                                      return Container(
                                        margin: EdgeInsets.symmetric(
                                            horizontal: 2.0),
                                        child: Icon(
                                          turn.event.foul == true
                                              ? Icons.close
                                              : turn.event.potted
                                                  ? Icons.circle
                                                  : Icons.chevron_right_rounded,
                                          size: 16.0,
                                          color: turn.event.foul != null &&
                                                  turn.event.foul!
                                              ? Colors.yellow
                                              : turn.event.potted
                                                  ? turn.event.colour ==
                                                          BallColour.red
                                                      ? Colors.red
                                                      : Colors.black
                                                  : Colors.purpleAccent,
                                        ),
                                      );
                                    })
                                  ],
                                ),
                              ),
                            ],
                            color: WidgetStateProperty.resolveWith<Color?>(
                              (Set<WidgetState> states) {
                                if (isActive) {
                                  return Colors.green.withValues(alpha: 0.3);
                                }
                                return null;
                              },
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
