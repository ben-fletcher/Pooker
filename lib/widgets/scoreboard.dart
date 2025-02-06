import 'dart:math';

import 'package:flutter/material.dart';
import 'package:pooker_score/models/game_model.dart';
import 'package:pooker_score/models/turn.dart';
import 'package:provider/provider.dart';

class Scoreboard extends StatelessWidget {
  const Scoreboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<GameModel>(
      builder: (context, gameModel, child) {
        return Container(
          width: double.infinity,
          margin: EdgeInsets.all(16.0),
          padding: EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.5),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.white, width: 2),
          ),
          child: Column(
            children: [
              Text(
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
              SizedBox(height: 10),
              DataTable(
                columnSpacing: 20.0,
                columns: const [
                  DataColumn(
                      label: Text('Player',
                          style: TextStyle(color: Colors.white))),
                  DataColumn(
                      label:
                          Text('Score', style: TextStyle(color: Colors.white))),
                  DataColumn(
                      label:
                          Text('Turns', style: TextStyle(color: Colors.white))),
                ],
                rows: gameModel.players.map((player) {
                  final isActive = gameModel.activePlayer == player;
                  final playerTurns =
                      player.Turns; //.where((t) => t.toString() != '');
                  return DataRow(
                    cells: [
                      DataCell(
                        Container(
                          width: double.infinity,
                          child: Text(player.Name,
                              style: TextStyle(color: Colors.white)),
                        ),
                      ),
                      DataCell(
                        Container(
                          width: double.infinity,
                          child: Text(player.score.toString(),
                              style: TextStyle(color: Colors.white)),
                        ),
                      ),
                      DataCell(
                        Container(
                          width: double.infinity,
                          child: Wrap(
                            spacing: 2.0,
                            runSpacing: 2.0,
                            children: [
                              ...playerTurns.map((turn) {
                                return Container(
                                  margin: EdgeInsets.symmetric(horizontal: 2.0),
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
                                                    BallColour.Red
                                                ? Colors.red
                                                : Colors.black
                                            : Colors.purpleAccent,
                                  ),
                                );
                              })
                            ],
                        ),
                      ),
                      ),
                    ],
                    color: MaterialStateProperty.resolveWith<Color?>(
                      (Set<MaterialState> states) {
                        if (isActive) {
                          return Colors.green.withOpacity(0.3);
                        }
                        return null;
                      },
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        );
      },
    );
  }
}
