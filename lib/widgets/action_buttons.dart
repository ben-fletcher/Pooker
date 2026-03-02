import 'package:flutter/material.dart';
import 'package:pooker_score/models/game_model.dart';
import 'package:pooker_score/models/turn.dart';
import 'package:provider/provider.dart';

class ActionButtons extends StatelessWidget {
  const ActionButtons({super.key});

  bool _canApplySkillShot(GameModel gameModel) {
    // Check if there's at least one turn in history
    if (gameModel.players.isEmpty) return false;

    // Check if there's any recent turn (pot, foul, or miss)
    // Allow skill shots for impressive pots OR funny fouls!
    for (var player in gameModel.players) {
      if (player.turns.isNotEmpty) {
        final lastTurn = player.turns.last;
        // Exclude only skill shot bonuses themselves
        final bool isSkillShotBonus = !lastTurn.event.potted &&
            lastTurn.event.foul != true &&
            lastTurn.event.colour == BallColour.na &&
            lastTurn.score > 0;
        if (!isSkillShotBonus) {
          return true;
        }
      }
    }
    return false;
  }

  void _showFoulDialog(BuildContext context, GameModel gameModel) {
    if (gameModel.nextTargetBall == BallColour.red) {
      Provider.of<GameModel>(context, listen: false).submitGameEvent(
          GameEvent(foul: true, colour: BallColour.na, potted: false),
          Navigator.of(context));
      return;
    }

    showModalBottomSheet(
        context: context,
        showDragHandle: true,
        builder: (context) => SafeArea(
          child: SizedBox(
                height: 210,
                width: double.infinity,
                child: Column(
                  spacing: 20,
                  children: [
                    Text("Foul Type?",
                        style: Theme.of(context).textTheme.titleLarge!.copyWith(fontFamily: 'Roboto')),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        spacing: 10,
                        children: [
                          ElevatedButton.icon(
                              onPressed: () {
                                Provider.of<GameModel>(context, listen: false)
                                    .submitGameEvent(
                                        GameEvent(
                                            foul: true,
                                            colour: BallColour.na,
                                            potted: false),
                                        Navigator.of(context));
                                Navigator.of(context).pop();
                              },
                              style: ElevatedButton.styleFrom(
                                minimumSize: Size(60, 60),
                                backgroundColor: Colors.orange.shade800,
                              ),
                              icon: Icon(Icons.gps_off_outlined,
                                  color: Colors.white),
                              label: const Text(
                                "Miss",
                                style:
                                    TextStyle(fontSize: 20, color: Colors.white),
                              )),
                          FilledButton.icon(
                              onPressed: () {
                                Provider.of<GameModel>(context, listen: false)
                                    .submitGameEvent(
                                        GameEvent(
                                            foul: true,
                                            colour: BallColour.red,
                                            potted: true),
                                        Navigator.of(context));
                                Navigator.of(context).pop();
                              },
                              style: FilledButton.styleFrom(
                                minimumSize: Size(60, 60),
                                backgroundColor: Colors.red.shade800,
                              ),
                              icon:
                                  Icon(Icons.not_interested, color: Colors.white),
                              label: const Text(
                                "Potted Red",
                                style:
                                    TextStyle(fontSize: 20, color: Colors.white),
                              )),
                        ],
                      ),
                    )
                  ],
                ),
              ),
        ));
  }

  void _showMultipleRedsDialog(BuildContext context, GameModel gameModel) {
    final int maxReds = gameModel.remainingBalls;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'How many reds potted?',
          textAlign: TextAlign.center,
        ),
        titleTextStyle:
            Theme.of(context).textTheme.titleMedium!.copyWith(fontSize: 20),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: List.generate(
                maxReds > 5 ? 5 : maxReds,
                (index) {
                  final count = index + 2; // Start from 2 reds
                  return FilledButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      gameModel.submitGameEvent(
                        GameEvent(
                          potted: true,
                          colour: BallColour.red,
                          count: count,
                        ),
                        Navigator.of(context),
                      );
                    },
                    style: FilledButton.styleFrom(
                      minimumSize: Size(60, 60),
                      backgroundColor: Colors.red,
                    ),
                    child: Text(
                      '$count',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel'),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<GameModel>(builder: (context, gameModel, child) {
      return Column(
        spacing: 10,
        children: [
          if (gameModel.remainingBalls > 1)
            Padding(
              padding: const EdgeInsets.only(bottom: 10.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.info_outline, size: 16, color: Colors.white70),
                  const SizedBox(width: 6),
                  Text(
                    'Long press red ball for multiple reds',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),
          SizedBox(
            height: 70,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                spacing: 15,
                children: [
                  Expanded(
                    child: FilledButton.tonal(
                      onPressed: () {
                        _showFoulDialog(context, gameModel);
                      },
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.close, color: Colors.red),
                          Text('Foul',
                              style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'Roboto')),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: FilledButton.tonal(
                      onPressed: () {
                        Provider.of<GameModel>(context, listen: false)
                            .undoLastEvent(context);
                      },
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.undo, color: Colors.grey.shade400),
                          Text('Undo',
                              style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'Roboto')),
                        ],
                      ),
                    ),
                  ),
                  if (gameModel.skillShotEnabled &&
                      _canApplySkillShot(gameModel))
                    Expanded(
                      child: FilledButton.tonal(
                        onPressed: () {
                          Provider.of<GameModel>(context, listen: false)
                              .applySkillShotBonus();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('⭐ Bonus Point! (+1)'),
                              duration: Duration(seconds: 2),
                              backgroundColor: Colors.amber.shade800,
                            ),
                          );
                        },
                        style: FilledButton.styleFrom(
                          backgroundColor: _canApplySkillShot(gameModel)
                              ? null
                              : Colors.grey.withValues(alpha: 0.2),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.star, color: Colors.amber.shade800),
                            Text('Skill',
                                style: TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'Roboto')),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            height: 250,
            child: Row(
              spacing: 20,
              children: [
                if (gameModel.nextTargetBall == BallColour.red)
                  Expanded(
                    child: GestureDetector(
                      onLongPress: gameModel.remainingBalls > 1
                          ? () => _showMultipleRedsDialog(context, gameModel)
                          : null,
                      child: FilledButton(
                        onPressed: gameModel.remainingBalls > 0
                            ? () {
                                Provider.of<GameModel>(context, listen: false)
                                    .submitGameEvent(
                                        GameEvent(
                                            potted: true,
                                            colour: BallColour.red,
                                            count: 1),
                                        Navigator.of(context));
                              }
                            : null,
                        style: FilledButton.styleFrom(
                          backgroundColor: gameModel.remainingBalls > 0
                              ? Colors.red.shade800
                              : Colors.grey.shade700,
                          foregroundColor: Colors.white,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Red',
                              style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'Roboto'),
                            ),
                            Text('1',
                                style: TextStyle(
                                    fontSize: 24, fontFamily: 'Roboto')),
                          ],
                        ),
                      ),
                    ),
                  ),
                if (gameModel.nextTargetBall == BallColour.black)
                  Expanded(
                    child: FilledButton.tonal(
                      onPressed: () {
                        Provider.of<GameModel>(context, listen: false)
                            .submitGameEvent(
                                GameEvent(
                                    potted: true, colour: BallColour.black),
                                Navigator.of(context));
                      },
                      style: FilledButton.styleFrom(
                        backgroundColor: Colors.grey.shade900,
                        foregroundColor: Colors.white,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Black',
                            style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Roboto'),
                          ),
                          Text('3',
                              style: TextStyle(
                                  fontSize: 24, fontFamily: 'Roboto')),
                        ],
                      ),
                    ),
                  ),
                Expanded(
                  child: FilledButton.tonal(
                    onPressed: () {
                      Provider.of<GameModel>(context, listen: false)
                          .submitGameEvent(
                              GameEvent(potted: false, colour: BallColour.na),
                              Navigator.of(context));
                    },
                    style: FilledButton.styleFrom(
                      backgroundColor:
                          Theme.of(context).colorScheme.primaryContainer,
                      foregroundColor: Colors.white,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'End',
                          style: TextStyle(fontSize: 28, fontFamily: 'Roboto'),
                        ),
                        Text('Turn',
                            style:
                                TextStyle(fontSize: 24, fontFamily: 'Roboto')),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          )
        ],
      );
    });
  }
}
