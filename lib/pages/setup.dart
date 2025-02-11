import 'package:flutter/material.dart';
import 'package:pooker_score/models/game_model.dart';
import 'package:pooker_score/models/player.dart';
import 'package:pooker_score/pages/calculator.dart';
import 'package:pooker_score/themes.dart';
import 'package:provider/provider.dart';

class SetupPage extends StatefulWidget {
  const SetupPage({super.key});

  @override
  State<SetupPage> createState() => _SetupPageState();
}

class _SetupPageState extends State<SetupPage> {
  final TextEditingController _nameController = TextEditingController();
  final FocusNode _nameFocusNode = FocusNode();

  void _addPlayer(GameModel gameModel) {
    if (_nameController.text.isNotEmpty) {
      final newPlayer = Player(
          id: gameModel.players.length + 1,
          name: _nameController.text,
          turns: []);
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
          title: const Text('New Game', style: TextStyle(fontSize: 24)),
        ),
        body: Consumer<GameModel>(
          builder: (context, gameModel, child) => Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: _nameController,
                  focusNode: _nameFocusNode,
                  decoration: InputDecoration(
                    labelText: 'Player Name',
                    labelStyle: TextStyle(fontSize: 18),
                    border: OutlineInputBorder(),
                  ),
                  textCapitalization: TextCapitalization.words,
                  onSubmitted: (_) => _addPlayer(gameModel),
                ),
                const SizedBox(height: 16),
                Center(
                  child: ElevatedButton(
                    onPressed: () => _addPlayer(gameModel),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 12),
                      textStyle: TextStyle(fontSize: 18),
                    ),
                    child: const Text('Add Player'),
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: ListView.builder(
                    itemCount: gameModel.players.length,
                    itemBuilder: (context, index) {
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        child: ListTile(
                          title: Text(gameModel.players[index].name,
                              style: TextStyle(fontSize: 18)),
                          trailing: IconButton(
                            icon: Icon(Icons.remove_circle, color: Colors.red),
                            onPressed: () => _removePlayer(gameModel, index),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 16),
                Center(
                  child: FilledButton.icon(
                    onPressed: gameModel.players.isNotEmpty
                      ? () {
                            Navigator.of(context).pushAndRemoveUntil(
                              MaterialPageRoute(
                                  builder: (context) => const CalculatorPage()),
                              (Route<dynamic> route) => false,
                            );
                          }
                      : null,
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 32, vertical: 16),
                      backgroundColor:
                          gameModel.players.isNotEmpty ? null : Colors.grey,
                      textStyle: TextStyle(fontSize: 18),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    icon: const Icon(Icons.play_arrow, size: 32),
                    label: const Text('Let\'s Go!',
                        style: TextStyle(
                          fontFamily: 'Comic Sans MS',
                          fontWeight: FontWeight.bold,
                        )),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
