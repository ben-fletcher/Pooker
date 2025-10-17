import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:pooker_score/models/game_model.dart';
import 'package:pooker_score/models/player.dart';
import 'package:pooker_score/models/turn.dart';
import 'package:provider/provider.dart';

class Scoreboard extends StatelessWidget {
  final bool isEditMode;
  final void Function(Player)? onScoreTap;

  const Scoreboard({
    super.key,
    this.isEditMode = false,
    this.onScoreTap,
  });

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
            elevation: 1,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10.0),
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
                            margin: const EdgeInsets.symmetric(vertical: 5),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: isActive
                                  ? cs.primary.withOpacity(0.08)
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: cs.outline.withOpacity(0.2),
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
                                            .titleSmall,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    _MiniPill(icon: Icons.sports_score, text: '$currentBreak'),
                                    const SizedBox(width: 8),
                                    _MiniPill(icon: Icons.report_problem, text: '$foulCount'),
                                    const SizedBox(width: 20),
                                    GestureDetector(
                                      onTap: isEditMode && onScoreTap != null
                                          ? () => onScoreTap!(player)
                                          : null,
                                      child: Container(
                                        padding: isEditMode
                                            ? const EdgeInsets.symmetric(
                                                horizontal: 8, vertical: 4)
                                            : null,
                                        decoration: isEditMode
                                            ? BoxDecoration(
                                                color: cs.primaryContainer.withOpacity(0.3),
                                                borderRadius: BorderRadius.circular(8),
                                                border: Border.all(
                                                  color: cs.primary.withOpacity(0.5),
                                                  width: 2,
                                                ),
                                              )
                                            : null,
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(
                                              player.score.toString(),
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .titleLarge
                                                  ?.copyWith(fontWeight: FontWeight.w700),
                                            ),
                                            if (isEditMode) ...[
                                              const SizedBox(width: 4),
                                              Icon(
                                                Icons.edit,
                                                size: 16,
                                                color: cs.primary,
                                              ),
                                            ],
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                // Turn history: last 16 icons
                                SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: Row(
                                    children: _buildTurnIcons(context, player, 16),
                                  ),
                                )
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

// Removed unused _buildTurnChips in favor of compact _buildTurnIcons

List<Widget> _buildTurnIcons(BuildContext context, Player player, int maxItems) {
  final cs = Theme.of(context).colorScheme;
  final turns = player.turns.reversed.take(maxItems).toList().reversed;
  return turns.map<Widget>((t) {
    final bool isFoul = t.event.foul == true;
    final bool isPotted = t.event.potted;
    final bool isSkillShot = !isPotted && !isFoul && t.event.colour == BallColour.na && t.score > 0;
    Color color;
    IconData icon;
    Widget iconWidget;
    
    if (isSkillShot) {
      // Skill shot bonus
      color = Colors.amber;
      iconWidget = Icon(Icons.star, size: 14, color: color);
    } else if (isFoul) {
      color = cs.error;
      icon = Icons.close;
      iconWidget = Icon(icon, size: 14, color: color);
    } else if (isPotted) {
      if (t.event.colour == BallColour.red) {
        color = Colors.red;
        // Show multiple circles for multiple reds
        if (t.event.count > 1) {
          iconWidget = Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ...List.generate(
                t.event.count > 3 ? 3 : t.event.count,
                (index) => Padding(
                  padding: EdgeInsets.only(left: index > 0 ? 2.0 : 0),
                  child: Icon(Icons.circle, size: 14, color: color),
                ),
              ),
              if (t.event.count > 3)
                Padding(
                  padding: const EdgeInsets.only(left: 2.0),
                  child: Text(
                    '+${t.event.count - 3}',
                    style: TextStyle(
                      fontSize: 10,
                      color: color,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          );
        } else {
          iconWidget = Icon(Icons.circle, size: 14, color: color);
        }
      } else {
        color = Colors.black;
        iconWidget = Icon(Icons.circle, size: 14, color: color);
      }
    } else {
      color = cs.tertiary;
      icon = Icons.chevron_right_rounded;
      iconWidget = Icon(icon, size: 14, color: color);
    }
    
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: iconWidget,
    );
  }).toList();
}

class _MiniPill extends StatelessWidget {
  final IconData icon;
  final String text;
  const _MiniPill({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: cs.surfaceVariant.withOpacity(0.6),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: cs.onSurfaceVariant),
          const SizedBox(width: 4),
          Text(
            text,
            style: Theme.of(context)
                .textTheme
                .labelMedium
                ?.copyWith(color: cs.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
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

// Removed unused _InfoPill; condensed break/foul line instead
