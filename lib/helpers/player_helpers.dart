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
                GameDatabaseService.insertPlayer(playerName);
              }
              Navigator.of(context).pop();
            },
            child: Text('Add'),
          ),
        ],
      );
    }
  );
}
