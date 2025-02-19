import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pooker_score/models/game_result.dart';
import 'package:pooker_score/pages/game_result_page.dart';
import 'package:pooker_score/services/database_service.dart';
import 'package:pooker_score/themes.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  late Future<List<GameResult>> _gameHistoryFuture;
  Map<String, int> _playerWins = {};
  int _totalGamesPlayed = 0;
  double _averageScore = 0.0;

  @override
  void initState() {
    super.initState();
    _loadGameHistory();
  }

  void _loadGameHistory() {
    setState(() {
      _gameHistoryFuture = GameDatabaseService.loadGameHistory();
      _gameHistoryFuture.then((gameHistory) {
        _calculatePlayerWins(gameHistory);
        _calculateTotalGamesPlayed(gameHistory);
        _calculateAverageScore(gameHistory);
      });
    });
  }

  void _calculatePlayerWins(List<GameResult> gameHistory) {
    final wins = <String, int>{};
    for (var game in gameHistory) {
      if (game.players.isNotEmpty) {
        final winner = game.players.reduce((a, b) => a.score > b.score ? a : b);
        wins[winner.name] = (wins[winner.name] ?? 0) + 1;
      }
    }
    setState(() {
      _playerWins = wins;
    });
  }

  void _calculateTotalGamesPlayed(List<GameResult> gameHistory) {
    setState(() {
      _totalGamesPlayed = gameHistory.length;
    });
  }

  void _calculateAverageScore(List<GameResult> gameHistory) {
    int totalScore = 0;
    int totalPlayers = 0;
    for (var game in gameHistory) {
      for (var player in game.players) {
        totalScore += player.score;
        totalPlayers++;
      }
    }
    setState(() {
      _averageScore = totalPlayers > 0 ? totalScore / totalPlayers : 0.0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: LightTheme,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Game History'),
        ),
        body: FutureBuilder<List<GameResult>>(
          future: _gameHistoryFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return const Center(child: Text('Error loading game history'));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text('No game history available'));
            } else {
              final gameHistory = snapshot.data!;
              return Column(
                children: [
                  _buildStatisticsSection(),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6.0),
                    child: const Divider(),
                  ),
                  Expanded(child: buildHistoryList(gameHistory)),
                ],
              );
            }
          },
        ),
      ),
    );
  }

  Widget _buildStatisticsSection() {
    if (_playerWins.isEmpty) {
      return const SizedBox.shrink();
    }

    final mostWinsPlayer =
        _playerWins.entries.reduce((a, b) => a.value > b.value ? a : b);

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
            elevation: 3,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Row(
                    children: [
                      Icon(Icons.emoji_events, color: Colors.amber, size: 32),
                      const SizedBox(width: 8.0),
                      Text(
                        'Player with the most wins:',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4.0),
                  Text(
                    '${mostWinsPlayer.key} with ${mostWinsPlayer.value} wins',
                    style: TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 5.0),
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
            elevation: 3,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Row(
                    children: [
                      Icon(Icons.games, color: Colors.blue, size: 32),
                      const SizedBox(width: 8.0),
                      Text(
                        'Total games played:',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4.0),
                  Text(
                    '$_totalGamesPlayed',
                    style: TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 5.0),
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
            elevation: 3,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Row(
                    children: [
                      Icon(Icons.score, color: Colors.green, size: 32),
                      const SizedBox(width: 8.0),
                      Text(
                        'Average score per game:',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4.0),
                  Text(
                    '${_averageScore.toStringAsFixed(2)}',
                    style: TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ),
          ),
        ],
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
                  style: TextStyle(color: textColor, fontSize: 18),
                );
              }).toList(),
            ),
            onTap: () async {
              final result = await Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => GameResultPage(gameResult: game),
                ),
              );
              if (result == true) {
                _loadGameHistory();
              }
            },
          ),
        );
      },
    );
  }
}
