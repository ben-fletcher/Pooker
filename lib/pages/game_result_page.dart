import 'package:flutter/material.dart';
import 'package:pooker_score/models/game_result.dart';
import 'package:pooker_score/pages/player_detail.dart';
import 'package:pooker_score/services/database_service.dart';
import 'package:intl/intl.dart';
import 'package:pooker_score/components/podium.dart';

class GameResultPage extends StatelessWidget {
  final GameResult gameResult;

  const GameResultPage({super.key, required this.gameResult});

  @override
  Widget build(BuildContext context) {
    final sortedPlayers = List.from(gameResult.players)
      ..sort((a, b) => b.score.compareTo(a.score));
    final winner = sortedPlayers.isNotEmpty ? sortedPlayers[0] : null;
    final secondPlace = sortedPlayers.length > 1 ? sortedPlayers[1] : null;
    final thirdPlace = sortedPlayers.length > 2 ? sortedPlayers[2] : null;

    return Scaffold(
      appBar: AppBar(
        title: Text(DateFormat.yMMMMd().add_Hm().format(gameResult.date)),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            color: Colors.red,
            onPressed: () async {
              await GameDatabaseService.deleteGameResult(gameResult.id!);
              if (context.mounted) {
                Navigator.of(context).pop(true);
              }
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Podium(
                winner: winner,
                secondPlace: secondPlace,
                thirdPlace: thirdPlace),
            const SizedBox(height: 16.0),
            Expanded(
              child: ListView.builder(
                itemCount: sortedPlayers.length,
                itemBuilder: (context, index) {
                  var playerColor = getPlayerColor(index);
                  var foregroundColor = playerColor != null
                      ? playerColor.computeLuminance() > 0.5
                          ? Colors.black
                          : Colors.white
                      : null;
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: playerColor,
                      foregroundColor: foregroundColor,
                      child: Text((index + 1).toString()),
                    ),
                    title: Text(sortedPlayers[index].name),
                    trailing: Text(sortedPlayers[index].score.toString()),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => PlayerDetailScreen(
                            playerName: sortedPlayers[index].name,
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color? getPlayerColor(int index) {
    switch (index) {
      case 0:
        return Colors.amber;
      case 1:
        return Colors.grey;
      case 2:
        return Colors.brown;
      default:
        return null;
    }
  }
}
