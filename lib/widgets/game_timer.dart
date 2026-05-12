import 'dart:async';

import 'package:flutter/material.dart';
import 'package:pooker_score/models/game_model.dart';
import 'package:pooker_score/widgets/mini_pill.dart';

class GameTimer extends StatefulWidget {
  const GameTimer({super.key, required this.gameModel});

  final GameModel gameModel;

  @override
  State<GameTimer> createState() => _GameTimerState();
}

class _GameTimerState extends State<GameTimer> {
  late String _elapsedTimeString;
  late Duration _elapsedTime;
  late Timer timer;

  @override
  void initState() {
    super.initState();

    _elapsedTime = Duration.zero;
    _elapsedTimeString = _formatElapsedTime(_elapsedTime);

    timer = Timer.periodic(const Duration(seconds: 1), (Timer timer) {
      setState(() {
        _updateElapsedTime();
      });
    });
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  void _updateElapsedTime() {
    setState(() {
      _elapsedTime = DateTime.now().difference(widget.gameModel.getStartTime());
      _elapsedTimeString = _formatElapsedTime(_elapsedTime);
    });
  }

  String _formatElapsedTime(Duration time) {
    return '${time.inMinutes.remainder(60).toString().padLeft(2, '0')}:${(time.inSeconds.remainder(60)).toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return MiniPill(
      text: _elapsedTimeString,
      icon: Icons.timer_sharp,
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      showBorder: true,
    );
  }
}
