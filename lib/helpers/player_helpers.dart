import 'package:flutter/material.dart';
import 'package:pooker_score/models/player.dart';
import 'package:pooker_score/services/database_service.dart';

Future<void> showAddPlayerDialog(BuildContext context) {
  final nameController = TextEditingController();

  void submit() {
    final playerName = nameController.text;
    if (playerName.isNotEmpty) {
      GameDatabaseService.insertPlayer(playerName).then((success) {
        if (!context.mounted) {
          return;
        }

        if (!success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Player already exists',
                style: TextStyle(
                    color: Theme.of(context).colorScheme.onErrorContainer),
              ),
              duration: Duration(seconds: 2),
              backgroundColor: Theme.of(context).colorScheme.errorContainer,
            ),
          );
        }
        Navigator.of(context).pop();
      });
    } else {
      Navigator.of(context).pop();
    }
  }

  return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Add Player'),
          content: TextField(
            focusNode: FocusNode()..requestFocus(),
            controller: nameController,
            autocorrect: false,
            textCapitalization: TextCapitalization.words,
            decoration: InputDecoration(hintText: 'Enter player name'),
            onSubmitted: (_) => submit(),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: submit,
              child: Text('Add'),
            ),
          ],
        );
      });
}

List<Player> getOrderPlayers(List<Player> players) {
  final playersCopy = players.toList();
  playersCopy.sort((a, b) {
    var scoreCompare = b.score.compareTo(a.score);
    if (scoreCompare != 0) {
      return scoreCompare;
    }

    scoreCompare = a.turns
        .where((t) => t.event.foul == true)
        .length
        .compareTo(b.turns.where((t) => t.event.foul == true).length);
    if (scoreCompare != 0) {
      return scoreCompare;
    }

    // Player starting after get's tie broken
    return 1;
  });

  return playersCopy;
}
