import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:pooker_score/models/game_model.dart';
import 'package:pooker_score/models/player.dart';
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
            final double targetOffset = activePlayerIndex * 92.0;
            if (scrollController.hasClients) {
              final double maxExtent =
                  scrollController.position.maxScrollExtent.toDouble();
              final double clampedOffset =
                  math.min(math.max(targetOffset, 0.0), maxExtent);
              scrollController.animateTo(
                clampedOffset,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              );
            }
          }
        });

        final cs = Theme.of(context).colorScheme;
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Scoreboard',
                        style: Theme.of(context)
                            .textTheme
                            .titleLarge
                            ?.copyWith(fontWeight: FontWeight.w700),
                      ),
                      Row(
                        children: [
                          _Chip(text: 'Reds: ${gameModel.remainingBalls}',
                              color: cs.primary),
                          const SizedBox(width: 8),
                          _Chip(
                              text:
                                  'Next: ${gameModel.nextTargetBall == BallColour.red ? 'Red' : 'Black'}',
                              color: gameModel.nextTargetBall ==
                                      BallColour.red
                                  ? Colors.red
                                  : Colors.black),
                        ],
                      )
                    ],
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: SingleChildScrollView(
                      controller: scrollController,
                      child: Column(
                        children: gameModel.players.map((player) {
                          final bool isActive =
                              gameModel.activePlayer == player;
                          final int currentBreak = _computeCurrentBreak(player);
                          final int foulCount = _computeFouls(player);
                          return Container(
                            margin: const EdgeInsets.symmetric(vertical: 6),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 10),
                            decoration: BoxDecoration(
                              color: isActive
                                  ? cs.primary.withOpacity(0.08)
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: cs.outline.withOpacity(0.24),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Container(
                                      width: 10,
                                      height: 10,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color:
                                            isActive ? cs.primary : cs.outline,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        player.name,
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleMedium,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    Text(
                                      player.score.toString(),
                                      style: Theme.of(context)
                                          .textTheme
                                          .headlineSmall
                                          ?.copyWith(fontWeight: FontWeight.w700),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Row(
                                  children: [
                                    _InfoPill(
                                      icon: Icons.sports_score,
                                      label: 'Break',
                                      value: '$currentBreak',
                                    ),
                                    const SizedBox(width: 8),
                                    _InfoPill(
                                      icon: Icons.report_problem,
                                      label: 'Fouls',
                                      value: '$foulCount',
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Wrap(
                                  spacing: 6,
                                  runSpacing: 6,
                                  children: _buildTurnChips(context, player),
                                ),
                              ],
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

int _computeCurrentBreak(Player player) {
  int sum = 0;
  for (int i = player.turns.length - 1; i >= 0; i--) {
    final t = player.turns[i];
    if (t.event.foul == true || t.event.potted == false) {
      break;
    }
    sum += t.score;
  }
  return sum;
}

int _computeFouls(player) {
  return player.turns.where((t) => t.event.foul == true).length;
}

List<Widget> _buildTurnChips(BuildContext context, player) {
  final cs = Theme.of(context).colorScheme;
  return player.turns.map<Widget>((t) {
    final bool isFoul = t.event.foul == true;
    final bool isPotted = t.event.potted;
    Color chipColor;
    IconData icon;
    if (isFoul) {
      chipColor = cs.error;
      icon = Icons.close;
    } else if (isPotted) {
      if (t.event.colour == BallColour.red) {
        chipColor = Colors.red;
      } else {
        chipColor = Colors.black;
      }
      icon = Icons.circle;
    } else {
      chipColor = cs.tertiary;
      icon = Icons.chevron_right_rounded;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: chipColor.withOpacity(0.08),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: chipColor.withOpacity(0.35)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: chipColor),
        ],
      ),
    );
  }).toList();
}

class _Chip extends StatelessWidget {
  final String text;
  final Color color;
  const _Chip({required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.10),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withOpacity(0.25)),
      ),
      child: Text(
        text,
        style: Theme.of(context)
            .textTheme
            .labelLarge
            ?.copyWith(color: Theme.of(context).colorScheme.onSurface),
      ),
    );
  }
}

class _InfoPill extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoPill({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: cs.surfaceVariant.withOpacity(0.5),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: cs.onSurfaceVariant),
          const SizedBox(width: 6),
          Text(
            '$label: $value',
            style: Theme.of(context)
                .textTheme
                .labelLarge
                ?.copyWith(color: cs.onSurfaceVariant),
          )
        ],
      ),
    );
  }
}
