import 'package:flutter/material.dart';
import 'package:pooker_score/data.dart';
import 'package:pooker_score/models/game_model.dart';
import 'package:pooker_score/models/player.dart';
import 'package:pooker_score/pages/finish.dart';
import 'package:pooker_score/services/database_service.dart';
import 'package:pooker_score/theme.dart';
import 'package:pooker_score/widgets/action_buttons.dart';
import 'package:pooker_score/widgets/scoreboard.dart';
import 'package:provider/provider.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

class CalculatorPage extends StatefulWidget {
  const CalculatorPage({super.key});

  @override
  State<CalculatorPage> createState() => _CalculatorPageState();
}

class _CalculatorPageState extends State<CalculatorPage> {
  @override
  void initState() {
    super.initState();
    WakelockPlus.enable();
  }

  @override
  void dispose() {
    super.dispose();
    WakelockPlus.disable();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<MaterialTheme>(builder: (context, theme, _) {
      return Theme(
        data: theme.dark(),
        child: Consumer<GameModel>(builder: (context, gameModel, child) {
          return Scaffold(
            backgroundColor: Colors.green.shade900,
            appBar: AppBar(
              title: Text(APP_TITLE),
              backgroundColor: Colors.transparent,
              elevation: 0,
              leading: IconButton(
                icon: Icon(Icons.undo),
                onPressed: () {
                  gameModel.undoLastEvent(context);
                },
              ),
              actions: [
                MenuItemButton(
                  child: Icon(Icons.menu),
                  onPressed: () {
                    showMenu(
                      context: context,
                      position: RelativeRect.fromLTRB(100, 100, 0, 0),
                      items: [
                        PopupMenuItem(
                          child: Row(
                            spacing: 10.0,
                            children: [
                              Icon(Icons.sports_score),
                              Text('Finish Game'),
                            ],
                          ),
                          onTap: () {
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (_) => FinishPage()));
                          },
                        ),
                        PopupMenuItem(
                          child: Row(
                            spacing: 10.0,
                            children: [
                              Icon(Icons.add),
                              Text('Add Player'),
                            ],
                          ),
                          onTap: () {
                            showAddMidGamePlayerDialog(gameModel);
                          },
                        ),
                      ],
                    );
                  },
                )
              ],
            ),
            body: Center(
              child: Column(
                children: [
                  Expanded(child: Scoreboard()),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 25.0),
                    child: ActionButtons(),
                  ),
                ],
              ),
            ),
          );
        }),
      );
    });
  }

  Future showAddMidGamePlayerDialog(GameModel gameModel) async {
    List<String> players = await GameDatabaseService.loadPlayers();
    players = players.where((player) => !gameModel.players.any((p) => p.name == player)).toList();
    final playerController = TextEditingController();
    String? selectedPlayer;

    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Add Player'),
        content: DropdownMenu<String>(
          width: double.infinity,
          controller: playerController,
          requestFocusOnTap: false,
          enableSearch: false,
          label: const Text('Player'),
          dropdownMenuEntries: players
              .map((player) =>
                  DropdownMenuEntry(value: player, label: player))
              .toList(),
          onSelected: (String? player) {
            selectedPlayer = player;
          },
        ),
        actions: [
          TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel')),
          TextButton(
              onPressed: () {
                if (selectedPlayer == null) {
                  return;
                }
                gameModel.addPlayer(Player(id: gameModel.players.length + 1, name: selectedPlayer!, turns: []));
                Navigator.of(context).pop();
              },
              child: Text('Add')),
        ],
      ),
    );
  }
}
