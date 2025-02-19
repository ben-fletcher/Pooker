import 'package:flutter/material.dart';
import 'package:pooker_score/models/player.dart';

class Podium extends StatelessWidget {
  final PlayerScore? winner;
  final PlayerScore? secondPlace;
  final PlayerScore? thirdPlace;

  const Podium({super.key, this.winner, this.secondPlace, this.thirdPlace});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        if (secondPlace != null)
          Column(
            children: [
              Icon(
                Icons.emoji_events,
                size: 80,
                color: Colors.grey,
              ),
              Text(
                secondPlace!.name,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        if (winner != null)
          Column(
            children: [
              Icon(
                Icons.emoji_events,
                size: 100,
                color: Colors.amber,
              ),
              Text(
                winner!.name,
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.amber,
                ),
              ),
            ],
          ),
        if (thirdPlace != null)
          Column(
            children: [
              Icon(
                Icons.emoji_events,
                size: 60,
                color: Colors.brown,
              ),
              Text(
                thirdPlace!.name,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.brown,
                ),
              ),
            ],
          ),
      ],
    );
  }
}
