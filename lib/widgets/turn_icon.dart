import 'package:flutter/material.dart';
import 'package:pooker_score/models/turn.dart';

class TurnIcon extends StatelessWidget {
  final Turn turn;
  final Animation<double> animation;
  late final Animation<Offset> offsetAnimation;

  TurnIcon({super.key, required this.turn, required this.animation}) {
    offsetAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(1.5, 0.0),
    ).animate(animation);
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final bool isFoul = turn.event.foul == true;
    final bool isPotted = turn.event.potted;
    final bool isSkillShot = !isPotted &&
        !isFoul &&
        turn.event.colour == BallColour.na &&
        turn.score > 0;
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
      if (turn.event.colour == BallColour.red) {
        color = Colors.red;
        // Show multiple circles for multiple reds
        if (turn.event.count > 1) {
          iconWidget = Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ...List.generate(
                turn.event.count > 3 ? 3 : turn.event.count,
                (index) => Padding(
                  padding: EdgeInsets.only(left: index > 0 ? 2.0 : 0),
                  child: Icon(Icons.circle, size: 14, color: color),
                ),
              ),
              if (turn.event.count > 3)
                Padding(
                  padding: const EdgeInsets.only(left: 2.0),
                  child: Text(
                    '+${turn.event.count - 3}',
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
      child: FadeTransition(
          opacity: animation,
          child: SlideTransition(position: offsetAnimation, child: iconWidget)),
    );
  }
}
