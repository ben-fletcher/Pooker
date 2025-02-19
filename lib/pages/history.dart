import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pooker_score/models/game_result.dart';
import 'package:pooker_score/services/database_service.dart';

class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Game History'),
      ),
      body: FutureBuilder<List<GameResult>>(
        future: GameDatabaseService.loadGameHistory(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(child: Text('Error loading game history'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No game history available'));
          } else {
            final gameHistory = snapshot.data!;
            return buildHistoryList(gameHistory);
          }
        },
      ),
    );
  }

  ListView buildHistoryList(List<GameResult> gameHistory) {
    return ListView.builder(
      itemCount: gameHistory.length,
      itemBuilder: (context, index) {
        final game = gameHistory[index];
        final sortedPlayers = List.from(game.players)
          ..sort((a, b) => b.score.compareTo(a.score));
        return Card(
          margin: const EdgeInsets.all(8.0),
          child: ListTile(
            title: Text(
                'Game on ${DateFormat.yMMMMd().add_Hm().format(game.date)}'),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: sortedPlayers.asMap().entries.map((entry) {
                final player = entry.value;
                final position = entry.key + 1;
                Color textColor;
                switch (position) {
                  case 1:
                    textColor = Colors.amber;
                    break;
                  case 2:
                    textColor = Colors.grey;
                    break;
                  case 3:
                    textColor = Colors.brown;
                    break;
                  default:
                    textColor = Colors.black;
                }
                return Text(
                  '$position. ${player.name}: ${player.score}',
                  style: TextStyle(color: textColor),
                );
              }).toList(),
            ),
          ),
        );
      },
    );
  }
}
