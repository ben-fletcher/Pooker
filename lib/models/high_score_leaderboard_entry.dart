/// One row on the high-score leaderboard (best single-game score per player).
class HighScoreLeaderboardEntry {
  final String name;
  final int highScore;
  final int gamesPlayed;

  const HighScoreLeaderboardEntry({
    required this.name,
    required this.highScore,
    required this.gamesPlayed,
  });
}
