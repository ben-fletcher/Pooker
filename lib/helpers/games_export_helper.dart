import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart' show Uint8List, defaultTargetPlatform, kIsWeb;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pooker_score/models/game_result.dart';
import 'package:pooker_score/services/database_service.dart';
import 'package:share_plus/share_plus.dart';

/// Android’s share sheet often doesn’t list “Files” for in-memory shares.
/// “Save to device” uses the system save dialog (SAF) so users can pick
/// Downloads or browse with the Files app.
class GamesExportHelper {
  GamesExportHelper._();

  static String _fileName(List<GameResult> games) {
    if (games.length == 1) {
      return 'pooker_game_${DateFormat('yyyyMMdd_Hm').format(games.first.date)}.json';
    }
    return 'pooker_games_export_${DateFormat('yyyyMMdd').format(DateTime.now())}.json';
  }

  /// Opens a sheet: Share (apps) or Save to device (Files / Downloads).
  static Future<void> presentExportOptions(
    BuildContext context, {
    required List<GameResult> games,
  }) async {
    if (games.isEmpty) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No games to export')),
        );
      }
      return;
    }

    final json = GameDatabaseService.exportGamesAsJson(games);
    final bytes = utf8.encode(json);
    final fileName = _fileName(games);
    final shareText = games.length == 1
        ? 'Pooker game result'
        : 'Pooker games export (${games.length} game${games.length == 1 ? '' : 's'})';
    final shareSubject = games.length == 1
        ? 'Pooker game ${DateFormat.yMMMd().format(games.first.date)}'
        : 'Pooker games export';

    if (!context.mounted) return;

    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) {
        final theme = Theme.of(sheetContext);
        final colorScheme = theme.colorScheme;

        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(8, 0, 8, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                  child: Text(
                    'Export games',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                ListTile(
                  leading: CircleAvatar(
                    backgroundColor: colorScheme.primaryContainer,
                    child: Icon(Icons.share_rounded, color: colorScheme.onPrimaryContainer),
                  ),
                  title: const Text('Share'),
                  subtitle: Text(
                    'Messages, email, Drive…',
                    style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 13),
                  ),
                  onTap: () async {
                    Navigator.of(sheetContext).pop();
                    final xFile = XFile.fromData(
                      bytes,
                      mimeType: 'application/json',
                      name: fileName,
                    );
                    await Share.shareXFiles(
                      [xFile],
                      text: shareText,
                      subject: shareSubject,
                      fileNameOverrides: [fileName],
                    );
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Ready to share')),
                      );
                    }
                  },
                ),
                if (!kIsWeb)
                  ListTile(
                    leading: CircleAvatar(
                      backgroundColor: colorScheme.secondaryContainer,
                      child: Icon(Icons.save_alt_rounded, color: colorScheme.onSecondaryContainer),
                    ),
                    title: const Text('Save to device'),
                    subtitle: Text(
                      defaultTargetPlatform == TargetPlatform.android
                          ? 'Opens the system picker — pick Downloads or browse with Files'
                          : 'Choose where to save the export file',
                      style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 13),
                    ),
                    onTap: () async {
                      Navigator.of(sheetContext).pop();
                      final path = await FilePicker.platform.saveFile(
                        dialogTitle: 'Save Pooker export',
                        fileName: fileName,
                        bytes: Uint8List.fromList(bytes),
                      );
                      if (!context.mounted) return;
                      if (path != null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Saved: $fileName')),
                        );
                      }
                    },
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
