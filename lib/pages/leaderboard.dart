import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pooker_score/models/game_model.dart';
import 'package:pooker_score/models/high_score_leaderboard_entry.dart';
import 'package:pooker_score/pages/player_detail.dart';
import 'package:pooker_score/pages/setup.dart';
import 'package:pooker_score/services/database_service.dart';
import 'package:provider/provider.dart';

class LeaderboardPage extends StatefulWidget {
  const LeaderboardPage({super.key});

  @override
  State<LeaderboardPage> createState() => _LeaderboardPageState();
}

class _LeaderboardPageState extends State<LeaderboardPage>
    with TickerProviderStateMixin {
  late Future<List<HighScoreLeaderboardEntry>> _future;
  late AnimationController _podiumController;
  late AnimationController _listController;

  @override
  void initState() {
    super.initState();
    _future = GameDatabaseService.getHighScoreLeaderboard();
    _podiumController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _listController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );
    _scheduleEntranceAnimations();
  }

  void _scheduleEntranceAnimations() {
    _future.then((list) {
      if (!mounted) return;
      if (list.isEmpty) return;
      _podiumController.forward(from: 0);
      Future.delayed(const Duration(milliseconds: 320), () {
        if (mounted) _listController.forward(from: 0);
      });
    });
  }

  Future<void> _onRefresh() async {
    _podiumController.reset();
    _listController.reset();
    setState(() {
      _future = GameDatabaseService.getHighScoreLeaderboard();
    });
    final list = await _future;
    if (!mounted) return;
    if (list.isNotEmpty) {
      _podiumController.forward(from: 0);
      await Future<void>.delayed(const Duration(milliseconds: 320));
      if (mounted) await _listController.forward(from: 0);
    }
    HapticFeedback.lightImpact();
  }

  @override
  void dispose() {
    _podiumController.dispose();
    _listController.dispose();
    super.dispose();
  }

  void _openPlayer(HighScoreLeaderboardEntry entry) {
    HapticFeedback.selectionClick();
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => PlayerDetailScreen(playerName: entry.name),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Leaderboard'),
        centerTitle: true,
      ),
      body: FutureBuilder<List<HighScoreLeaderboardEntry>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting &&
              !snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'Something went wrong: ${snapshot.error}',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          final entries = snapshot.data ?? [];
          if (entries.isEmpty) {
            return _EmptyLeaderboard(
              onNewGame: () {
                Provider.of<GameModel>(context, listen: false).reset();
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute<void>(
                    builder: (context) => const SetupPage(),
                  ),
                );
              },
            );
          }

          final rest = entries.length > 3 ? entries.sublist(3) : <HighScoreLeaderboardEntry>[];

          return RefreshIndicator(
            onRefresh: _onRefresh,
            color: cs.primary,
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
                    child: _PodiumSection(
                      entries: entries,
                      controller: _podiumController,
                      onTap: _openPlayer,
                    ),
                  ),
                ),
                if (rest.isNotEmpty) ...[
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    sliver: SliverToBoxAdapter(
                      child: Text(
                        'The rest of the field',
                        style: theme.textTheme.titleSmall?.copyWith(
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 8)),
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final entry = rest[index];
                        final rank = index + 4;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: _StaggeredListRow(
                            index: index,
                            listController: _listController,
                            child: Semantics(
                              label:
                                  'Rank $rank, ${entry.name}, high score ${entry.highScore}',
                              button: true,
                              child: Material(
                                color: cs.surfaceContainerHighest
                                    .withValues(alpha: 0.6),
                                borderRadius: BorderRadius.circular(16),
                                clipBehavior: Clip.antiAlias,
                                child: InkWell(
                                  onTap: () => _openPlayer(entry),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 14,
                                    ),
                                    child: Row(
                                      children: [
                                        _RankChip(rank: rank, compact: true),
                                        const SizedBox(width: 12),
                                        CircleAvatar(
                                          backgroundColor:
                                              cs.primaryContainer,
                                          foregroundColor:
                                              cs.onPrimaryContainer,
                                          child: Text(
                                            entry.name.isNotEmpty
                                                ? entry.name[0]
                                                    .toUpperCase()
                                                : '?',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 14),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                entry.name,
                                                style: theme
                                                    .textTheme.titleMedium
                                                    ?.copyWith(
                                                  fontWeight: FontWeight.w600,
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              Text(
                                                '${entry.gamesPlayed} games played',
                                                style: theme
                                                    .textTheme.bodySmall
                                                    ?.copyWith(
                                                  color: cs.onSurfaceVariant,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Text(
                                          '${entry.highScore}',
                                          style: theme.textTheme.headlineSmall
                                              ?.copyWith(
                                            fontWeight: FontWeight.bold,
                                            color: cs.tertiary,
                                          ),
                                        ),
                                        Icon(
                                          Icons.chevron_right,
                                          color: cs.onSurfaceVariant,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                      childCount: rest.length,
                    ),
                  ),
                ],
                const SliverToBoxAdapter(child: SizedBox(height: 32)),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _EmptyLeaderboard extends StatelessWidget {
  final VoidCallback onNewGame;

  const _EmptyLeaderboard({required this.onNewGame});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return CustomScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: [
        SliverFillRemaining(
          hasScrollBody: false,
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.85, end: 1.0),
                  duration: const Duration(milliseconds: 1200),
                  curve: Curves.elasticOut,
                  builder: (context, scale, child) {
                    return Transform.scale(scale: scale, child: child);
                  },
                  child: Icon(
                    Icons.emoji_events_outlined,
                    size: 96,
                    color: cs.tertiary.withValues(alpha: 0.85),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'No scores yet!',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  'Finish a game and your best scores will light up the board.',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: cs.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 36),
                FilledButton.icon(
                  onPressed: onNewGame,
                  icon: const Icon(Icons.play_circle_fill),
                  label: const Text('Start a game'),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 28,
                      vertical: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _PodiumSection extends StatelessWidget {
  final List<HighScoreLeaderboardEntry> entries;
  final AnimationController controller;
  final void Function(HighScoreLeaderboardEntry) onTap;

  const _PodiumSection({
    required this.entries,
    required this.controller,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    if (entries.isEmpty) return const SizedBox.shrink();

    if (entries.length == 1) {
      return _SingleChampion(
        entry: entries[0],
        controller: controller,
        onTap: () => onTap(entries[0]),
      );
    }

    if (entries.length == 2) {
      return _TwoPodium(
        first: entries[0],
        second: entries[1],
        controller: controller,
        onTap: onTap,
      );
    }

    return _ThreePodium(
      first: entries[0],
      second: entries[1],
      third: entries[2],
      controller: controller,
      onTap: onTap,
    );
  }
}

class _SingleChampion extends StatelessWidget {
  final HighScoreLeaderboardEntry entry;
  final AnimationController controller;
  final VoidCallback onTap;

  const _SingleChampion({
    required this.entry,
    required this.controller,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final interval = const Interval(0.15, 0.95, curve: Curves.elasticOut);

    return Center(
      child: AnimatedBuilder(
        animation: controller,
        builder: (context, child) {
          final t = interval.transform(controller.value);
          return Transform.scale(
            scale: t,
            child: Opacity(opacity: t.clamp(0.0, 1.0), child: child),
          );
        },
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(24),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Icon(Icons.emoji_events, size: 100, color: cs.tertiary),
                  const SizedBox(height: 8),
                  Text(
                    entry.name,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: cs.tertiary,
                        ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    '${entry.highScore} pts',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: cs.onSurfaceVariant,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _TwoPodium extends StatelessWidget {
  final HighScoreLeaderboardEntry first;
  final HighScoreLeaderboardEntry second;
  final AnimationController controller;
  final void Function(HighScoreLeaderboardEntry) onTap;

  const _TwoPodium({
    required this.first,
    required this.second,
    required this.controller,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(
          child: _PodiumColumn(
            entry: second,
            rank: 2,
            trophyColor: cs.outline,
            pedestalHeight: 72,
            iconSize: 72,
            interval: const Interval(0.0, 0.42, curve: Curves.elasticOut),
            controller: controller,
            onTap: () => onTap(second),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _PodiumColumn(
            entry: first,
            rank: 1,
            trophyColor: cs.tertiary,
            pedestalHeight: 104,
            iconSize: 92,
            interval: const Interval(0.22, 1.0, curve: Curves.elasticOut),
            controller: controller,
            onTap: () => onTap(first),
          ),
        ),
      ],
    );
  }
}

class _ThreePodium extends StatelessWidget {
  final HighScoreLeaderboardEntry first;
  final HighScoreLeaderboardEntry second;
  final HighScoreLeaderboardEntry third;
  final AnimationController controller;
  final void Function(HighScoreLeaderboardEntry) onTap;

  const _ThreePodium({
    required this.first,
    required this.second,
    required this.third,
    required this.controller,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: _PodiumColumn(
            entry: second,
            rank: 2,
            trophyColor: cs.outline,
            pedestalHeight: 76,
            iconSize: 70,
            interval: const Interval(0.0, 0.4, curve: Curves.elasticOut),
            controller: controller,
            onTap: () => onTap(second),
          ),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: _PodiumColumn(
            entry: first,
            rank: 1,
            trophyColor: cs.tertiary,
            pedestalHeight: 112,
            iconSize: 96,
            interval: const Interval(0.28, 1.0, curve: Curves.elasticOut),
            controller: controller,
            onTap: () => onTap(first),
          ),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: _PodiumColumn(
            entry: third,
            rank: 3,
            trophyColor: cs.tertiaryContainer,
            pedestalHeight: 56,
            iconSize: 58,
            interval: const Interval(0.1, 0.48, curve: Curves.elasticOut),
            controller: controller,
            onTap: () => onTap(third),
          ),
        ),
      ],
    );
  }
}

class _PodiumColumn extends StatelessWidget {
  final HighScoreLeaderboardEntry entry;
  final int rank;
  final Color trophyColor;
  final double pedestalHeight;
  final double iconSize;
  final Interval interval;
  final AnimationController controller;
  final VoidCallback onTap;

  const _PodiumColumn({
    required this.entry,
    required this.rank,
    required this.trophyColor,
    required this.pedestalHeight,
    required this.iconSize,
    required this.interval,
    required this.controller,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        final raw = interval.transform(controller.value);
        final t = raw.clamp(0.0, 1.0);
        return Transform.scale(
          scale: 0.5 + 0.5 * t,
          alignment: Alignment.bottomCenter,
          child: Opacity(opacity: t, child: child),
        );
      },
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.emoji_events, size: iconSize, color: trophyColor),
                const SizedBox(height: 4),
                Text(
                  entry.name,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: trophyColor,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  '${entry.highScore}',
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: cs.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  height: pedestalHeight,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        cs.surfaceContainerHigh,
                        cs.surfaceContainerHighest,
                      ],
                    ),
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(12),
                    ),
                    border: Border.all(
                      color: cs.outline.withValues(alpha: 0.35),
                    ),
                  ),
                  alignment: Alignment.topCenter,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: _RankChip(rank: rank, compact: false),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _RankChip extends StatelessWidget {
  final int rank;
  final bool compact;

  const _RankChip({required this.rank, required this.compact});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 12 : 10,
        vertical: compact ? 8 : 6,
      ),
      decoration: BoxDecoration(
        color: cs.tertiaryContainer,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        '#$rank',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: cs.onPrimaryContainer,
          fontSize: compact ? 15 : 14,
        ),
      ),
    );
  }
}

class _StaggeredListRow extends StatelessWidget {
  final int index;
  final AnimationController listController;
  final Widget child;

  const _StaggeredListRow({
    required this.index,
    required this.listController,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    const stagger = 0.055;
    const window = 0.22;

    return AnimatedBuilder(
      animation: listController,
      builder: (context, _) {
        final start = (index * stagger).clamp(0.0, 0.78);
        final end = (start + window).clamp(0.0, 1.0);
        double t;
        final v = listController.value;
        if (v <= start) {
          t = 0;
        } else if (v >= end) {
          t = 1;
        } else {
          t = (v - start) / (end - start);
        }
        t = Curves.easeOutCubic.transform(t);
        return Opacity(
          opacity: t,
          child: Transform.translate(
            offset: Offset(24 * (1 - t), 0),
            child: child,
          ),
        );
      },
    );
  }
}
