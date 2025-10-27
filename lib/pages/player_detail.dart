import 'package:flutter/material.dart';
import 'package:pooker_score/services/database_service.dart';
import 'package:pooker_score/models/game_result.dart';
import 'package:intl/intl.dart';

class PlayerDetailScreen extends StatefulWidget {
  final String playerName;

  const PlayerDetailScreen({super.key, required this.playerName});

  @override
  State<PlayerDetailScreen> createState() => _PlayerDetailScreenState();
}

class _PlayerDetailScreenState extends State<PlayerDetailScreen> {
  String _selectedTab = 'stats';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.playerName}\'s Profile'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(50),
          child: Container(
            color: Theme.of(context).colorScheme.surface,
            child: Row(
              children: [
                _buildTabButton('stats', 'Statistics', Icons.bar_chart),
                _buildTabButton('history', 'Game History', Icons.history),
                _buildTabButton('rivals', 'Rivals', Icons.people),
              ],
            ),
          ),
        ),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _loadPlayerData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            debugPrint(snapshot.error.toString());
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final data = snapshot.data!;
          return _buildContent(data);
        },
      ),
    );
  }

  Future<Map<String, dynamic>> _loadPlayerData() async {
    final stats = await GameDatabaseService.getPlayerStatistics(widget.playerName);
    final history = await GameDatabaseService.loadGameHistory();
    
    // Filter games for this player
    final playerGames = history.where((game) =>
        game.players.any((p) => p.name == widget.playerName)).toList();
    
    // Calculate additional stats
    final detailedStats = _calculateDetailedStats(playerGames);
    
    return {
      'stats': stats,
      'games': playerGames,
      'detailedStats': detailedStats,
    };
  }

  Map<String, dynamic> _calculateDetailedStats(List<GameResult> games) {
    if (games.isEmpty) {
      return {
        'lowestScore': 0,
        'averagePosition': 0.0,
        'recentForm': <int>[],
        'headToHead': <String, Map<String, int>>{},
        'consistency': 0.0,
        'podiumFinishes': 0,
      };
    }

    int lowestScore = 999999;
    int totalPosition = 0;
    List<int> recentScores = [];
    Map<String, Map<String, int>> headToHead = {};
    List<int> allScores = [];
    int podiumFinishes = 0;

    for (final game in games) {
      final playerResult = game.players.firstWhere((p) => p.name == widget.playerName);
      final score = playerResult.score;
      allScores.add(score);
      
      if (score < lowestScore) {
        lowestScore = score;
      }

      // Calculate position in this game
      final sortedPlayers = List<PlayerResult>.from(game.players)
        ..sort((a, b) => b.score.compareTo(a.score));
      final position = sortedPlayers.indexWhere((p) => p.name == widget.playerName) + 1;
      totalPosition += position;
      
      if (position <= 3) {
        podiumFinishes++;
      }

      // Recent form (last 10 games)
      if (recentScores.length < 10) {
        recentScores.add(score);
      }

      // Head to head stats
      for (final opponent in game.players) {
        if (opponent.name != widget.playerName) {
          if (!headToHead.containsKey(opponent.name)) {
            headToHead[opponent.name] = <String, int>{'wins': 0, 'losses': 0, 'draws': 0};
          }
          if (playerResult.score > opponent.score) {
            headToHead[opponent.name]!['wins'] = 
                headToHead[opponent.name]!['wins']! + 1;
          } else if (playerResult.score < opponent.score) {
            headToHead[opponent.name]!['losses'] = 
                headToHead[opponent.name]!['losses']! + 1;
          } else {
            headToHead[opponent.name]!['draws'] = 
                headToHead[opponent.name]!['draws']! + 1;
          }
        }
      }
    }

    // Calculate consistency (standard deviation)
    double consistency = 0.0;
    if (allScores.length > 1) {
      final mean = allScores.reduce((a, b) => a + b) / allScores.length;
      final variance = allScores.map((score) => 
          (score - mean) * (score - mean)).reduce((a, b) => a + b) / allScores.length;
      consistency = variance > 0 ? (100 / (1 + variance / 100)) : 100;
    }

    return {
      'lowestScore': lowestScore == 999999 ? 0 : lowestScore,
      'averagePosition': totalPosition / games.length,
      'recentForm': recentScores.reversed.toList(),
      'headToHead': headToHead,
      'consistency': consistency,
      'podiumFinishes': podiumFinishes,
    };
  }

  Widget _buildTabButton(String tab, String label, IconData icon) {
    final isSelected = _selectedTab == tab;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _selectedTab = tab),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: isSelected ? Theme.of(context).colorScheme.primary : Colors.transparent,
                width: 3,
              ),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 18,
                color: isSelected ? Theme.of(context).colorScheme.primary : Colors.grey,
              ),
              const SizedBox(width: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? Theme.of(context).colorScheme.primary : Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent(Map<String, dynamic> data) {
    switch (_selectedTab) {
      case 'stats':
        return _buildStatisticsTab(data['stats'], data['detailedStats']);
      case 'history':
        return _buildGameHistoryTab(data['games']);
      case 'rivals':
        return _buildRivalsTab(data['detailedStats']['headToHead']);
      default:
        return const SizedBox();
    }
  }

  Widget _buildStatisticsTab(Map<String, dynamic> stats, Map<String, dynamic> detailedStats) {
    return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Main stats grid
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: MediaQuery.of(context).size.width > 600 ? 4 : 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
            childAspectRatio: 1.1,
              children: [
                _buildStatCard('Games Played', stats['gamesPlayed'],
                    Icons.games, Colors.blue),
                _buildStatCard('Games Won', stats['gamesWon'],
                    Icons.emoji_events, Colors.green),
              _buildStatCard('Win Rate', stats['winRate'], Icons.percent, Colors.teal),
              _buildStatCard('Podiums', detailedStats['podiumFinishes'],
                  Icons.workspace_premium, Colors.amber),
              _buildStatCard('Highest Score', stats['highestScore'],
                  Icons.trending_up, Colors.orange),
              _buildStatCard('Lowest Score', detailedStats['lowestScore'],
                  Icons.trending_down, Colors.red),
                _buildStatCard('Average Score', stats['averageScore'],
                    Icons.bar_chart, Colors.purple),
              _buildStatCard('Avg Position', 
                  detailedStats['averagePosition'].toStringAsFixed(1),
                  Icons.leaderboard, Colors.indigo),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Consistency meter
          _buildConsistencySection(detailedStats['consistency']),
          
          const SizedBox(height: 24),
          
          // Recent form
          if (detailedStats['recentForm'].isNotEmpty)
            _buildRecentFormSection(detailedStats['recentForm']),
        ],
      ),
    );
  }

  Widget _buildConsistencySection(double consistency) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.show_chart, color: Colors.deepPurple),
                const SizedBox(width: 8),
                Text(
                  'Performance Consistency',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            LinearProgressIndicator(
              value: consistency / 100,
              minHeight: 20,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(
                consistency > 70 ? Colors.green : 
                consistency > 40 ? Colors.orange : Colors.red,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${consistency.toStringAsFixed(1)}% - ${_getConsistencyLabel(consistency)}',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  String _getConsistencyLabel(double consistency) {
    if (consistency > 70) return 'Very Consistent';
    if (consistency > 50) return 'Fairly Consistent';
    if (consistency > 30) return 'Moderate';
    return 'Variable';
  }

  Widget _buildRecentFormSection(List<int> recentScores) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.timeline, color: Colors.blue),
                const SizedBox(width: 8),
                Text(
                  'Recent Form (Last ${recentScores.length} Games)',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 100,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: recentScores.asMap().entries.map((entry) {
                  final maxScore = recentScores.reduce((a, b) => a > b ? a : b);
                  final height = maxScore > 0 ? (entry.value / maxScore) * 80.0 : 0.0;
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 2),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            entry.value.toString(),
                            style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            height: height,
                            decoration: BoxDecoration(
                              color: Colors.blue.withValues(alpha: 0.7),
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGameHistoryTab(List<GameResult> games) {
    if (games.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.history, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text('No games played yet', style: TextStyle(fontSize: 18, color: Colors.grey)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: games.length,
      itemBuilder: (context, index) {
        final game = games[index];
        final sortedPlayers = List<PlayerResult>.from(game.players)
          ..sort((a, b) => b.score.compareTo(a.score));
        final position = sortedPlayers.indexWhere((p) => p.name == widget.playerName) + 1;
        final isWinner = position == 1;

        return Card(
          elevation: 2,
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          isWinner ? Icons.emoji_events : Icons.sports_score,
                          color: isWinner ? Colors.amber : Colors.grey,
                          size: 24,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          DateFormat('MMM d, y').format(game.date),
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: _getPositionColor(position).withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        _getPositionLabel(position),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: _getPositionColor(position),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Divider(),
                const SizedBox(height: 8),
                ...sortedPlayers.map((player) {
                  final isCurrentPlayer = player.name == widget.playerName;
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            player.name,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: isCurrentPlayer ? FontWeight.bold : FontWeight.normal,
                              color: isCurrentPlayer ? Theme.of(context).colorScheme.primary : null,
                            ),
                          ),
                        ),
                        Text(
                          player.score.toString(),
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: isCurrentPlayer ? FontWeight.bold : FontWeight.normal,
                            color: isCurrentPlayer ? Theme.of(context).colorScheme.primary : null,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildRivalsTab(Map<String, Map<String, int>> headToHead) {
    if (headToHead.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.people_outline, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text('No rival data available', style: TextStyle(fontSize: 18, color: Colors.grey)),
          ],
        ),
      );
    }

    // Sort rivals by total games played
    final sortedRivals = headToHead.entries.toList()
      ..sort((a, b) {
        final aTotal = (a.value['wins'] ?? 0) + (a.value['losses'] ?? 0) + (a.value['draws'] ?? 0);
        final bTotal = (b.value['wins'] ?? 0) + (b.value['losses'] ?? 0) + (b.value['draws'] ?? 0);
        return bTotal.compareTo(aTotal);
      });

    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: sortedRivals.length,
      itemBuilder: (context, index) {
        final rival = sortedRivals[index];
        final wins = rival.value['wins'] ?? 0;
        final losses = rival.value['losses'] ?? 0;
        final draws = rival.value['draws'] ?? 0;
        final total = wins + losses + draws;
        final winRate = total > 0 ? (wins / total * 100) : 0;

        return Card(
          elevation: 2,
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
                      child: Text(
                        rival.key[0].toUpperCase(),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            rival.key,
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            '$total games played',
                            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: winRate >= 50 ? Colors.green.withValues(alpha: 0.2) : Colors.red.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${winRate.toStringAsFixed(0)}% WR',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: winRate >= 50 ? Colors.green : Colors.red,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildRecordStat('Wins', wins, Colors.green),
                    ),
                    Expanded(
                      child: _buildRecordStat('Losses', losses, Colors.red),
                    ),
                    Expanded(
                      child: _buildRecordStat('Draws', draws, Colors.grey),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                LinearProgressIndicator(
                  value: total > 0 ? wins / total : 0,
                  minHeight: 8,
                  backgroundColor: Colors.red.withValues(alpha: 0.3),
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildRecordStat(String label, int value, Color color) {
    return Column(
      children: [
        Text(
          value.toString(),
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
        ),
      ],
    );
  }

  Color _getPositionColor(int position) {
    switch (position) {
      case 1:
        return Colors.amber;
      case 2:
        return Colors.grey;
      case 3:
        return Colors.brown;
      default:
        return Colors.blueGrey;
    }
  }

  String _getPositionLabel(int position) {
    switch (position) {
      case 1:
        return '🥇 1st';
      case 2:
        return '🥈 2nd';
      case 3:
        return '🥉 3rd';
      default:
        return '${position}th';
    }
  }

  Widget _buildStatCard(
      String title, dynamic value, IconData icon, Color color) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ),
            const SizedBox(height: 4),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                value.toString(),
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
