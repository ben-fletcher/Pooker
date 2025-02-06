import 'package:flutter/material.dart';
import 'package:pooker_score/models/game_model.dart';
import 'package:pooker_score/models/player.dart';
import 'package:pooker_score/pages/calculator.dart';
import 'package:pooker_score/themes.dart';
import 'package:provider/provider.dart';

class SetupPage extends StatefulWidget {
  const SetupPage({super.key});

  @override
  _SetupPageState createState() => _SetupPageState();
}

class _SetupPageState extends State<SetupPage> {
  final TextEditingController _nameController = TextEditingController();
  final FocusNode _nameFocusNode = FocusNode();

  void _addPlayer(GameModel gameModel) {
    if (_nameController.text.isNotEmpty) {
      final newPlayer = Player(
          Id: gameModel.players.length + 1,
          Name: _nameController.text,
          Turns: []);
      gameModel.addPlayer(newPlayer);
      _nameController.clear();
      _nameFocusNode.requestFocus();
    }
  }

  void _removePlayer(GameModel gameModel, int index) {
    gameModel.removePlayer(index);
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: LightTheme,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('New Game'),
        ),
        body: Consumer<GameModel>(
          builder: (context, gameModel, child) => Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                TextField(
                  controller: _nameController,
                  focusNode: _nameFocusNode,
                  decoration: const InputDecoration(labelText: 'Player Name'),
                  textCapitalization: TextCapitalization.words,
                  onSubmitted: (_) => _addPlayer(gameModel),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => _addPlayer(gameModel),
                  child: const Text('Add Player'),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: ListView.builder(
                    itemCount: gameModel.players.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: Text(gameModel.players[index].Name),
                        trailing: IconButton(
                          icon: Icon(Icons.remove_circle, color: Colors.red),
                          onPressed: () => _removePlayer(gameModel, index),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 16),
                FilledButton.icon(
                  onPressed: gameModel.players.isNotEmpty
                      ? () {
                          Navigator.of(context).pushAndRemoveUntil(
                            MaterialPageRoute(
                                builder: (context) => const CalculatorPage()),
                            (Route<dynamic> route) => false,
                          );
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 32, vertical: 16),
                    backgroundColor:
                        gameModel.players.isNotEmpty ? null : Colors.grey,
                  ),
                  icon: const Icon(Icons.play_arrow, size: 32),
                  label: const Text('Start Game'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
