import 'package:flutter/material.dart';
import 'package:pooker_score/components/pool_ball_button.dart';
import 'package:pooker_score/models/game_model.dart';
import 'package:pooker_score/models/turn.dart';
import 'package:provider/provider.dart';

class ActionButtons extends StatelessWidget {
  const ActionButtons({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<GameModel>(
      builder: (context, gameModel, child) {
        return Column(
          spacing: 20,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                PoolBallButton(
                  color: gameModel.remainingBalls > 0
                      ? Colors.red
                      : Colors.grey.shade700,
                  onPressed: gameModel.remainingBalls > 0
                      ? () {
                          Provider.of<GameModel>(context, listen: false)
                              .submitGameEvent(
                                  GameEvent(
                                      potted: true, colour: BallColour.red),
                                  Navigator.of(context));
                        }
                      : null,
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
        );
      },
    );
  }
}
