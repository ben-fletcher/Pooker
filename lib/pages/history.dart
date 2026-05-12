import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pooker_score/helpers/games_export_helper.dart';
import 'package:pooker_score/models/game_result.dart';
import 'package:pooker_score/pages/game_result_page.dart';
import 'package:pooker_score/services/database_service.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage>
    with SingleTickerProviderStateMixin {
  late Future<List<GameResult>> _gameHistoryFuture;
  Map<String, int> _playerWins = {};
  int _totalGamesPlayed = 0;
  double _averageScore = 0.0;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  bool _contentFadeStarted = false;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );
    _loadGameHistory();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  void _loadGameHistory() {
    _contentFadeStarted = false;
    _fadeController.reset();
    setState(() {
      _gameHistoryFuture = GameDatabaseService.loadGameHistory();
      _gameHistoryFuture.then((gameHistory) {
        if (!mounted) return;
        setState(() {
          _calculatePlayerWins(gameHistory);
          _calculateTotalGamesPlayed(gameHistory);
          _calculateAverageScore(gameHistory);
        });
      });
    });
  }

  Future<void> _exportAndShareAllGames(BuildContext context) async {
    final games = await GameDatabaseService.loadGameHistory();
    if (!context.mounted) return;
    await GamesExportHelper.presentExportOptions(context, games: games);
  }

  void _calculatePlayerWins(List<GameResult> gameHistory) {
    final wins = <String, int>{};
    for (var game in gameHistory) {
      if (game.players.isNotEmpty) {
        final winner = game.players.reduce((a, b) => a.score > b.score ? a : b);
        wins[winner.name] = (wins[winner.name] ?? 0) + 1;
      }
    }
    _playerWins = wins;
  }

  void _calculateTotalGamesPlayed(List<GameResult> gameHistory) {
    _totalGamesPlayed = gameHistory.length;
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
    _averageScore = totalPlayers > 0 ? totalScore / totalPlayers : 0.0;
  }

  static String _sectionLabel(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final gameDay = DateTime(date.year, date.month, date.day);
    final diff = today.difference(gameDay).inDays;

    if (diff == 0) return 'Today';
    if (diff == 1) return 'Yesterday';
    if (diff < 7) return 'This week';
    if (diff < 30) return 'This month';
    return 'Older';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Game History'),
        elevation: 0,
        scrolledUnderElevation: 4,
        actions: [
          IconButton(
            icon: const Icon(Icons.ios_share),
            tooltip: 'Export all games',
            onPressed: () => _exportAndShareAllGames(context),
          ),
        ],
      ),
      body: FutureBuilder<List<GameResult>>(
        future: _gameHistoryFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return _buildLoadingState(colorScheme);
          }
          if (snapshot.hasError) {
            return _buildErrorState(context, colorScheme);
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return _buildEmptyState(context, colorScheme);
          }

          final gameHistory = snapshot.data!;
          final grouped = _groupGamesBySection(gameHistory);

          if (!_contentFadeStarted) {
            _contentFadeStarted = true;
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) _fadeController.forward();
            });
          }

          return FadeTransition(
            opacity: _fadeAnimation,
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                    child: _buildStatsStrip(context, colorScheme)),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 28, 20, 12),
                    child: Text(
                      'Past games',
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ),
                ),
                ...grouped.entries.map((e) => _buildSection(
                      context,
                      sectionLabel: e.key,
                      games: e.value,
                      colorScheme: colorScheme,
                      theme: theme,
                    )),
                SliverToBoxAdapter(
                    child:
                        SizedBox(height: MediaQuery.paddingOf(context).bottom)),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildLoadingState(ColorScheme colorScheme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 52,
              height: 52,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                color: colorScheme.primary,
              ),
            ),
            const SizedBox(height: 28),
            Text(
              'Loading history…',
              style: TextStyle(
                color: colorScheme.onSurfaceVariant,
                fontSize: 17,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, ColorScheme colorScheme) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 48),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 72,
              color: colorScheme.error.withValues(alpha: 0.85),
            ),
            const SizedBox(height: 24),
            Text(
              'Couldn’t load game history',
              textAlign: TextAlign.center,
              style: theme.textTheme.titleLarge?.copyWith(
                color: colorScheme.onSurface,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Pull down to try again.',
              style: TextStyle(
                color: colorScheme.onSurfaceVariant,
                fontSize: 15,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, ColorScheme colorScheme) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 44, vertical: 48),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                color:
                    colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.history_rounded,
                size: 72,
                color: colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: 32),
            Text(
              'No games yet',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Finished games will show up here so you can look back at results and stats.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: colorScheme.onSurfaceVariant,
                fontSize: 16,
                height: 1.45,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Map<String, List<GameResult>> _groupGamesBySection(List<GameResult> games) {
    final map = <String, List<GameResult>>{};
    const order = ['Today', 'Yesterday', 'This week', 'This month', 'Older'];

    for (final game in games) {
      final label = _sectionLabel(game.date);
      map.putIfAbsent(label, () => []).add(game);
    }

    final ordered = <String, List<GameResult>>{};
    for (final key in order) {
      if (map.containsKey(key)) ordered[key] = map[key]!;
    }
    return ordered;
  }

  Widget _buildStatsStrip(BuildContext context, ColorScheme colorScheme) {
    if (_playerWins.isEmpty) return const SizedBox.shrink();

    final mostWinsEntry =
        _playerWins.entries.reduce((a, b) => a.value > b.value ? a : b);

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Row(
        children: [
          Expanded(
            child: _StatPill(
              value: '$_totalGamesPlayed',
              label: 'Games',
              colorScheme: colorScheme,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            flex: 2,
            child: _StatPill(
              value: mostWinsEntry.key,
              label: '${mostWinsEntry.value} wins',
              colorScheme: colorScheme,
              highlight: true,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _StatPill(
              value: _averageScore.toStringAsFixed(0),
              label: 'Avg',
              colorScheme: colorScheme,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(
    BuildContext context, {
    required String sectionLabel,
    required List<GameResult> games,
    required ColorScheme colorScheme,
    required ThemeData theme,
  }) {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            if (index == 0) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 10, top: 16),
                child: Text(
                  sectionLabel.toUpperCase(),
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: colorScheme.primary,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.4,
                  ),
                ),
              );
            }
            final game = games[index - 1];
            return _GameHistoryCard(
              game: game,
              colorScheme: colorScheme,
              theme: theme,
              onTap: () async {
                final result = await Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => GameResultPage(gameResult: game),
                  ),
                );
                if (result == true && context.mounted) {
                  _loadGameHistory();
                }
              },
            );
          },
          childCount: games.length + 1,
        ),
      ),
    );
  }
}

class _StatPill extends StatelessWidget {
  final String value;
  final String label;
  final ColorScheme colorScheme;
  final bool highlight;

  const _StatPill({
    required this.value,
    required this.label,
    required this.colorScheme,
    this.highlight = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
      decoration: BoxDecoration(
        color: highlight
            ? colorScheme.primaryContainer.withValues(alpha: 0.4)
            : colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: highlight ? colorScheme.primary : colorScheme.onSurface,
              letterSpacing: -0.5,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w500,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _GameHistoryCard extends StatelessWidget {
  final GameResult game;
  final ColorScheme colorScheme;
  final ThemeData theme;
  final VoidCallback onTap;

  const _GameHistoryCard({
    required this.game,
    required this.colorScheme,
    required this.theme,
    required this.onTap,
  });

  Color _positionColor(int position) {
    switch (position) {
      case 1:
        return Colors.amber;
      case 2:
        return Colors.grey;
      case 3:
        return Colors.brown;
      default:
        return colorScheme.onSurfaceVariant;
    }
  }

  @override
  Widget build(BuildContext context) {
    final sortedPlayers = List<PlayerResult>.from(game.players)
      ..sort((a, b) => b.score.compareTo(a.score));

    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerLow,
              borderRadius: BorderRadius.circular(16),
              border: Border(
                left: BorderSide(
                  color: colorScheme.primary,
                  width: 4,
                ),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(14, 10, 14, 8),
                  child: Row(
                    children: [
                      Text(
                        DateFormat('EEE d MMM').format(game.date),
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Spacer(),
                      Icon(
                        Icons.chevron_right_rounded,
                        size: 20,
                        color:
                            colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
                      ),
                    ],
                  ),
                ),
                ...sortedPlayers.asMap().entries.map((entry) {
                  final position = entry.key + 1;
                  final player = entry.value;
                  final isWinner = position == 1;
                  return Container(
                    margin: const EdgeInsets.only(bottom: 2),
                    padding: EdgeInsets.only(
                      left: 14,
                      right: 14,
                      top: isWinner ? 6 : 4,
                      bottom: isWinner ? 8 : 6,
                    ),
                    decoration: BoxDecoration(
                      color: isWinner
                          ? colorScheme.primary.withValues(alpha: 0.12)
                          : null,
                      borderRadius: BorderRadius.only(
                        topRight: const Radius.circular(8),
                        bottomRight: const Radius.circular(8),
                      ),
                    ),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 28,
                          child: isWinner
                              ? Icon(
                                  Icons.emoji_events_rounded,
                                  size: 18,
                                  color: Colors.amber.shade700,
                                )
                              : Text(
                                  position <= 3
                                      ? ['🥇', '🥈', '🥉'][position - 1]
                                      : '$position.',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: _positionColor(position),
                                  ),
                                ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            player.name,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight:
                                  isWinner ? FontWeight.w700 : FontWeight.w500,
                              color: isWinner
                                  ? colorScheme.onSurface
                                  : colorScheme.onSurfaceVariant,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          '${player.score}',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: isWinner
                                ? colorScheme.primary
                                : _positionColor(position),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
                const SizedBox(height: 6),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
