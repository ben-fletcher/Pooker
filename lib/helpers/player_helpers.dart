import 'package:flutter/material.dart';
import 'package:pooker_score/services/database_service.dart';

Future<void> showAddPlayerDialog(BuildContext context) {
  final nameController = TextEditingController();

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
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                final playerName = nameController.text;
                if (playerName.isNotEmpty) {
                  GameDatabaseService.insertPlayer(playerName).then((success) {
                    if (!success) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Player already exists',
                            style: TextStyle(
                                color: Theme.of(context)
                                    .colorScheme
                                    .onErrorContainer),
                          ),
                          duration: Duration(seconds: 2),
                          backgroundColor:
                              Theme.of(context).colorScheme.errorContainer,
                        ),
                      );
                    }
                    Navigator.of(context).pop();
                  });
                } else {
                  Navigator.of(context).pop();
                }
              },
              child: Text('Add'),
            ),
          ],
        );
      });
}
