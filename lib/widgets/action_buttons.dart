import 'package:flutter/material.dart';
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
                Expanded(
                  child: ElevatedButton(
                    onPressed: gameModel.nextTargetBall == BallColour.Red
                        ? () {
                            Provider.of<GameModel>(context, listen: false)
                                .submitGameEvent(GameEvent(
                                    potted: true, colour: BallColour.Red));
                          }
                        : null,
                    style: ElevatedButton.styleFrom(
                        shape: CircleBorder(),
                        minimumSize: Size(180, 180),
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        shadowColor: Colors.black,
                        elevation: 15,
                        side: BorderSide(color: Colors.black, width: 4)),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(
                          Icons.sports_soccer_outlined,
                          size: 60,
                          color: Colors.white,
                        ),
                        Text(
                          "Red",
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
                    onPressed: gameModel.nextTargetBall == BallColour.Black
                        ? () {
                            Provider.of<GameModel>(context, listen: false)
                                .submitGameEvent(GameEvent(
                                    potted: true, colour: BallColour.Black));
                          }
                        : null,
                    style: ElevatedButton.styleFrom(
                        shape: CircleBorder(),
                        minimumSize: Size(180, 180),
                        backgroundColor: Colors.black,
                        foregroundColor: Colors.white,
                        shadowColor: Colors.black54,
                        elevation: 15,
                        side: BorderSide(color: Colors.black, width: 4)),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Text(
                          "8",
                          style: TextStyle(
                            fontSize: 60,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          "Black",
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
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
                          .submitGameEvent(GameEvent(
                              foul: true,
                              colour: BallColour.Red,
                              potted: true));
                    },
                    style: ElevatedButton.styleFrom(
                        shape: CircleBorder(),
                        minimumSize: Size(180, 180),
                        backgroundColor: Colors.yellow.shade700,
                        foregroundColor: Colors.black,
                        shadowColor: Colors.yellowAccent,
                        elevation: 15,
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
                              GameEvent(potted: false, colour: BallColour.Na));
                    },
                    style: ElevatedButton.styleFrom(
                        shape: CircleBorder(),
                        minimumSize: Size(180, 180),
                        backgroundColor: Colors.purple.shade700,
                        foregroundColor: Colors.white,
                        shadowColor: Colors.purpleAccent,
                        elevation: 15,
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
