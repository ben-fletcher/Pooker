import 'package:flutter/material.dart';
import 'package:pooker_score/components/pool_ball_button.dart';
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

  void _showMultipleRedsDialog(BuildContext context, GameModel gameModel) {
    final int maxReds = gameModel.remainingBalls;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Multiple Reds Potted'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('How many reds were potted on this shot?'),
            const SizedBox(height: 16),
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
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cancel'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<GameModel>(
      builder: (context, gameModel, child) {
        return Column(
          spacing: 20,
          children: <Widget>[
            if (gameModel.remainingBalls > 1)
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
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
             Stack(
               alignment: Alignment.center,
               children: [
                 Column(
                   spacing: 20,
                   children: [
                     Row(
                       mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                       children: <Widget>[
                         GestureDetector(
                           onLongPress: gameModel.remainingBalls > 1
                               ? () => _showMultipleRedsDialog(context, gameModel)
                               : null,
                           child: PoolBallButton(
                             color: gameModel.remainingBalls > 0
                                 ? Colors.red
                                 : Colors.grey.shade700,
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
                           ),
                         ),
                         SizedBox(width: 20),
                         PoolBallButton(
                           color: Colors.black,
                           number: "8",
                           onPressed: () {
                             Provider.of<GameModel>(context, listen: false)
                                 .submitGameEvent(
                                     GameEvent(potted: true, colour: BallColour.black),
                                     Navigator.of(context));
                           },
                         ),
                       ],
                     ),
                     Row(
                       mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                       children: <Widget>[
                         Expanded(
                           child: ElevatedButton(
                             onPressed: () {
                               Provider.of<GameModel>(context, listen: false)
                                   .submitGameEvent(
                                       GameEvent(
                                           foul: true,
                                           colour: BallColour.na,
                                           potted: false),
                                       Navigator.of(context));
                             },
                             style: ElevatedButton.styleFrom(
                                 shape: CircleBorder(),
                                 minimumSize: Size(180, 180),
                                 backgroundColor: Colors.yellow.shade700,
                                 foregroundColor: Colors.black,
                                 elevation: 8,
                                 side: BorderSide(color: Colors.black, width: 4)),
                             child: Column(
                               mainAxisAlignment: MainAxisAlignment.center,
                               children: const [
                                 Icon(
                                   Icons.close,
                                   size: 60,
                                   color: Colors.black,
                                 ),
                                 Text(
                                   "Foul",
                                   style: TextStyle(
                                       fontSize: 20, fontWeight: FontWeight.bold),
                                 ),
                               ],
                             ),
                           ),
                         ),
                         SizedBox(width: 20),
                         Expanded(
                           child: ElevatedButton(
                             onPressed: () {
                               Provider.of<GameModel>(context, listen: false)
                                   .submitGameEvent(
                                       GameEvent(potted: false, colour: BallColour.na),
                                       Navigator.of(context));
                             },
                             style: ElevatedButton.styleFrom(
                                 shape: CircleBorder(),
                                 minimumSize: Size(180, 180),
                                 backgroundColor: Colors.purple.shade700,
                                 foregroundColor: Colors.white,
                                 elevation: 8,
                                 side: BorderSide(color: Colors.black, width: 4)),
                             child: Column(
                               mainAxisAlignment: MainAxisAlignment.center,
                               children: const [
                                 Icon(
                                   Icons.next_plan,
                                   size: 60,
                                   color: Colors.white,
                                 ),
                                 Text(
                                   "Miss",
                                   style: TextStyle(
                                       fontSize: 20, fontWeight: FontWeight.bold),
                                 ),
                               ],
                             ),
                           ),
                         ),
                       ],
                     ),
                   ],
                 ),
                 // Small bonus button in the center
                 if (gameModel.skillShotEnabled && _canApplySkillShot(gameModel))
                   Container(
                     decoration: BoxDecoration(
                       shape: BoxShape.circle,
                       color: Colors.amber,
                       boxShadow: [
                         BoxShadow(
                           color: Colors.black.withOpacity(0.3),
                           blurRadius: 8,
                           offset: Offset(0, 2),
                         ),
                       ],
                     ),
                     child: IconButton(
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
                       icon: Icon(
                         Icons.star,
                         size: 32,
                         color: Colors.black,
                       ),
                       tooltip: 'Award Bonus Point (+1)',
                       iconSize: 32,
                     ),
                   ),
               ],
             ),
          ],
        );
      },
    );
  }
}
