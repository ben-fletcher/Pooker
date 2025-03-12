import 'package:flutter/material.dart';
import 'package:pooker_score/models/game_model.dart';
import 'package:pooker_score/models/turn.dart';
import 'package:provider/provider.dart';

class ReplayPage extends StatefulWidget {
  const ReplayPage({super.key});

  @override
  _ReplayPageState createState() => _ReplayPageState();
}

class _ReplayPageState extends State<ReplayPage> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  int _currentTurnIndex = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..addListener(() {
        setState(() {});
      });

    _animation = Tween<double>(begin: 0, end: 1).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _playNextTurn(GameModel gameModel) {
    if (_currentTurnIndex < gameModel.turnHistory.length) {
      _controller.reset();
      _controller.forward().then((_) {
        setState(() {
          _currentTurnIndex++;
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Replay Game'),
      ),
      body: Consumer<GameModel>(
        builder: (context, gameModel, child) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Turn ${_currentTurnIndex + 1} of ${gameModel.turnHistory.length}',
                  style: const TextStyle(fontSize: 24),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () => _playNextTurn(gameModel),
                  child: const Text('Play Next Turn'),
                ),
                const SizedBox(height: 20),
                if (_currentTurnIndex < gameModel.turnHistory.length)
                  _buildTurnAnimation(gameModel.turnHistory[_currentTurnIndex]),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildTurnAnimation(PlayerTurn turn) {
    return Column(
      children: [
        Text(
          'Player: ${turn.playerIndex + 1}',
          style: const TextStyle(fontSize: 20),
        ),
        const SizedBox(height: 10),
        Text(
          'Event: ${turn.event.potted ? 'Potted' : 'Missed'} ${turn.event.colour}',
          style: const TextStyle(fontSize: 20),
        ),
        const SizedBox(height: 10),
        LinearProgressIndicator(
          value: _animation.value,
        ),
      ],
    );
  }
}
