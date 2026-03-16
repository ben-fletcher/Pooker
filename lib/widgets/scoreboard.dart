import 'dart:math';

import 'package:animated_digit/animated_digit.dart';
import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:pooker_score/models/game_model.dart';
import 'package:pooker_score/models/player.dart';
import 'package:pooker_score/models/turn.dart';
import 'package:pooker_score/widgets/turn_icon.dart';
import 'package:provider/provider.dart';

class Scoreboard extends StatefulWidget {
  final bool isEditMode;
  final void Function(Player)? onScoreTap;

  Scoreboard({
    super.key,
    this.isEditMode = false,
    this.onScoreTap,
  });

  @override
  State<Scoreboard> createState() => _ScoreboardState();
}

class _ScoreboardState extends State<Scoreboard> {
  final ScrollController scrollController = ScrollController();
  final List<ScrollController> horizonalControllers = [];

  @override
  Widget build(BuildContext context) {
    return Consumer<GameModel>(
      builder: (context, gameModel, child) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          final activePlayerIndex = gameModel.activePlayer != null
              ? gameModel.players.indexOf(gameModel.activePlayer)
              : -1;
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

          for (var c in horizonalControllers) {
            if (c.positions.isNotEmpty) {
              c.jumpTo(c.position.maxScrollExtent);
            }
          }
        });

        if (horizonalControllers.length != gameModel.players.length) {
          print('Generate controllers');
          for (int i = 0;
              i <= gameModel.players.length - horizonalControllers.length;
              i++) {
            horizonalControllers.add(ScrollController());
          }
        }

        final cs = Theme.of(context).colorScheme;
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: Card.outlined(
            color: Colors.black.withValues(alpha: 0.2),
            shape: RoundedRectangleBorder(
              side: BorderSide(
                  color: Theme.of(context).colorScheme.outline, width: 1),
              borderRadius: BorderRadius.circular(20.0),
            ),
            elevation: 10,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14.0),
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
                          _Chip(
                              text: 'Reds: ${gameModel.remainingBalls}',
                              color: cs.primary),
                          const SizedBox(width: 8),
                          _Chip(
                              text:
                                  'Next: ${gameModel.nextTargetBall == BallColour.red ? 'Red' : 'Black'}',
                              color: gameModel.nextTargetBall == BallColour.red
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
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isActive
                                    ? cs.primary.withValues(alpha: 0.7)
                                    : cs.outline.withValues(alpha: 0.2),
                                width: isActive ? 2 : 1,
                              ),
                              boxShadow: isActive
                                  ? [
                                      BoxShadow(
                                          color:
                                              cs.primary.withValues(alpha: 0.2),
                                          blurRadius: 5,
                                          spreadRadius: 2),
                                    ]
                                  : [],
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
                                    _MiniPill(
                                        icon: Icons.sports_score,
                                        text: '$currentBreak'),
                                    const SizedBox(width: 8),
                                    _MiniPill(
                                        icon: Icons.report_problem,
                                        text: '$foulCount'),
                                    const SizedBox(width: 20),
                                    GestureDetector(
                                      onTap: widget.isEditMode &&
                                              widget.onScoreTap != null
                                          ? () => widget.onScoreTap!(player)
                                          : null,
                                      child: Container(
                                        padding: widget.isEditMode
                                            ? const EdgeInsets.symmetric(
                                                horizontal: 8, vertical: 4)
                                            : null,
                                        decoration: widget.isEditMode
                                            ? BoxDecoration(
                                                color: cs.primaryContainer
                                                    .withValues(alpha: 0.3),
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                                border: Border.all(
                                                  color: cs.primary
                                                      .withValues(alpha: 0.5),
                                                  width: 2,
                                                ),
                                              )
                                            : null,
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            AnimatedDigitWidget(
                                              value: player.score,
                                              loop: false,
                                              textStyle: Theme.of(context)
                                                  .textTheme
                                                  .titleLarge
                                                  ?.copyWith(
                                                      fontWeight:
                                                          FontWeight.w700),
                                            ),
                                            if (widget.isEditMode) ...[
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
                                Container(
                                  height: 15,
                                  child: AnimatedList(
                                      key: player.animatedListState,
                                      scrollDirection: Axis.horizontal,
                                      padding: EdgeInsets.only(right: 28),
                                      controller: horizonalControllers[
                                          gameModel.players.indexOf(player)],
                                      initialItemCount:
                                          min(player.turns.length, 16),
                                      itemBuilder: (context, index, animation) {
                                        return TurnIcon(
                                            turn: player.turns[index],
                                            animation: animation);
                                      }),
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
        color: cs.secondaryContainer,
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
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.25)),
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
