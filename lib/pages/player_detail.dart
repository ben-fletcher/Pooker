import 'package:flutter/material.dart';
import 'package:pooker_score/services/database_service.dart';

class PlayerDetailScreen extends StatelessWidget {
  final String playerName;

  const PlayerDetailScreen({super.key, required this.playerName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('$playerName\'s Statistics'),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: GameDatabaseService.getPlayerStatistics(playerName),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final stats = snapshot.data!;
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: GridView.count(
              crossAxisCount: MediaQuery.of(context).size.width > 600 ? 4 : 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              children: [
                _buildStatCard('Games Played', stats['gamesPlayed'],
                    Icons.games, Colors.blue),
                _buildStatCard('Games Won', stats['gamesWon'],
                    Icons.emoji_events, Colors.green),
                _buildStatCard('Total Score', stats['totalScore'], Icons.score,
                    Colors.red),
                _buildStatCard('Average Score', stats['averageScore'],
                    Icons.bar_chart, Colors.purple),
                _buildStatCard('Highest Score', stats['highestScore'],
                    Icons.star, Colors.orange),
                _buildStatCard(
                    'Win Rate', stats['winRate'], Icons.percent, Colors.teal),
                // Add more statistics as needed
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatCard(
      String title, dynamic value, IconData icon, Color color) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: color),
            SizedBox(height: 10),
            Text(title,
                style: TextStyle(
                    fontSize: 18, fontWeight: FontWeight.bold, color: color)),
            Text(value.toString(), style: TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }
}
