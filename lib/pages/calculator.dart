import 'dart:math';

import 'package:flutter/material.dart';
import 'package:pooker_score/data.dart';
import 'package:pooker_score/models/game_model.dart';
import 'package:pooker_score/models/player.dart';
import 'package:pooker_score/pages/finish.dart';
import 'package:pooker_score/pages/rules.dart';
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
  bool _isEditMode = false;

  @override
  void initState() {
    super.initState();
    WakelockPlus.enable();
    // Load settings from database
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final gameModel = Provider.of<GameModel>(context, listen: false);
      gameModel.loadSettings();
    });
  }

  @override
  void dispose() {
    super.dispose();
    WakelockPlus.disable();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<MaterialTheme>(builder: (context, theme, _) {
      return Consumer<GameModel>(builder: (context, gameModel, child) {
        final cs = Theme.of(context).colorScheme;
        return Container(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: Alignment.topCenter,
              radius: 3,
              colors: [
                cs.primary.withValues(alpha: 0.18),
                cs.primary.withValues(alpha: 0.04),
                Color(0xff102216).withValues(alpha: 0.5),
                Color(0xff102216),
              ],
              stops: const [0.0, 0.3, 0.5, 1.0],
            )
          ),
          child: Stack(
            children: [
              Scaffold(
                backgroundColor: Colors.transparent,
                appBar: AppBar(
                  backgroundColor: Colors.transparent,
                  title: Text(APP_TITLE),
                  elevation: 0,
                  scrolledUnderElevation: 0,
                  bottom: PreferredSize(
                      preferredSize: Size(double.infinity, 3),
                      child: LinearProgressIndicator(
                        value: (gameModel.totalBalls - gameModel.remainingBalls) /
                            gameModel.totalBalls,
                      )),
                  leading: IconButton(
                    icon: Icon(Icons.undo),
                    onPressed: () {
                      gameModel.undoLastEvent(context);
                    },
                  ),
                  actions: [
                    IconButton(
                      icon: Icon(_isEditMode ? Icons.edit_off : Icons.edit),
                      onPressed: () {
                        setState(() {
                          _isEditMode = !_isEditMode;
                        });
                      },
                      tooltip: _isEditMode ? 'Exit Edit Mode' : 'Edit Scores',
                    ),
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
                            PopupMenuItem(
                              child: Row(
                                spacing: 10.0,
                                children: [
                                  Icon(Icons.help_outline),
                                  Text('Rules'),
                                ],
                              ),
                              onTap: () {
                                Navigator.of(context).push(MaterialPageRoute(
                                    builder: (_) => const RulesPage()));
                              },
                            ),
                          ],
                        );
                      },
                    )
                  ],
                ),
                body: SafeArea(
                  child: Center(
                    child: Column(
                      children: [
                        if (_isEditMode)
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                                vertical: 8, horizontal: 16),
                            color: Colors.orange.shade800,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.edit, size: 16, color: Colors.white),
                                const SizedBox(width: 8),
                                Text(
                                  'Edit Mode - Tap scores to adjust',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        if (MediaQuery.of(context).size.aspectRatio > 1)
                          _buildTabletMainControls(gameModel)
                        else
                          ..._buildMainControls(gameModel)
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      });
    });
  }

  List<Widget> _buildMainControls(GameModel gameModel) {
    return [
      Expanded(
        child: Scoreboard(
          isEditMode: _isEditMode,
          onScoreTap: _isEditMode
              ? (player) => _showEditScoreDialog(gameModel, player)
              : null,
        ),
      ),
      Padding(
        padding: const EdgeInsets.only(bottom: 8.0),
        child: ActionButtons(),
      )
    ];
  }

  Widget _buildTabletMainControls(GameModel gameModel) {
    return Expanded(
      child: Row(children: [
        Expanded(
          child: Scoreboard(
            isEditMode: _isEditMode,
            onScoreTap: _isEditMode
                ? (player) => _showEditScoreDialog(gameModel, player)
                : null,
          ),
        ),
        SizedBox(
          width: min(500, MediaQuery.of(context).size.width / 2),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: ActionButtons(),
          ),
        )
      ]),
    );
  }

  void _showEditScoreDialog(GameModel gameModel, Player player) {
    final TextEditingController scoreController = TextEditingController();
    scoreController.text = player.score.toString();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit ${player.name}\'s Score'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Current Score: ${player.score}',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: scoreController,
              keyboardType: TextInputType.numberWithOptions(signed: true),
              decoration: InputDecoration(
                labelText: 'New Score',
                border: OutlineInputBorder(),
                helperText: 'Enter the corrected score',
              ),
              autofocus: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              final int? newScore = int.tryParse(scoreController.text);
              if (newScore != null) {
                gameModel.adjustPlayerScore(player, newScore);
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content:
                        Text('${player.name}\'s score adjusted to $newScore'),
                    duration: Duration(seconds: 2),
                  ),
                );
              }
            },
            child: Text('Save'),
          ),
        ],
      ),
    );
  }

  Future showAddMidGamePlayerDialog(GameModel gameModel) async {
    List<String> players = await GameDatabaseService.loadPlayers();
    players = players
        .where((player) => !gameModel.players.any((p) => p.name == player))
        .toList();
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
              .map((player) => DropdownMenuEntry(value: player, label: player))
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
                gameModel.addPlayer(Player(
                    id: gameModel.players.length + 1,
                    name: selectedPlayer!,
                    turns: []));
                Navigator.of(context).pop();
              },
              child: Text('Add')),
        ],
      ),
    );
  }
}
