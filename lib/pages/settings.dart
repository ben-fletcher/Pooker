// ignore_for_file: use_build_context_synchronously

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:pooker_score/helpers/games_export_helper.dart';
import 'package:pooker_score/services/database_service.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _skillShotEnabled = false;
  bool _developerModeEnabled = false;
  String _version = "";

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    final skillShotEnabled = await GameDatabaseService.getSkillShotEnabled();
    final developerMode = await GameDatabaseService.getDeveloperModeEnabled();
    if (!context.mounted) {
      return;
    }

    setState(() {
      _skillShotEnabled = skillShotEnabled;
      _developerModeEnabled = developerMode;
      _version = "v${packageInfo.version}";
    });
  }

  Future<void> _toggleSkillShot(bool value) async {
    await GameDatabaseService.setSkillShotEnabled(value);
    setState(() {
      _skillShotEnabled = value;
    });
  }

  Future<void> _toggleDeveloperMode(bool value) async {
    await GameDatabaseService.setDeveloperModeEnabled(value);
    setState(() {
      _developerModeEnabled = value;
    });
  }

  Future<void> _exportDatabase() async {
    if (kIsWeb) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Export is not supported on web')),
      );
      return;
    }

    await GameDatabaseService.exportDatabase();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Database exported')),
    );
  }

  Future<void> _importDatabase() async {
    if (kIsWeb) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Import is not supported on web')),
      );
      return;
    }

    FilePickerResult? result = await FilePicker.platform.pickFiles(
      dialogTitle: 'Import Database',
      type: FileType.any,
    );

    if (result != null && result.files.single.path != null) {
      await GameDatabaseService.importDatabase(result.files.single.path!);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Database imported successfully')),
      );
    }
  }

  Future<void> _exportGamesJson() async {
    final games = await GameDatabaseService.loadGameHistory();
    if (!mounted) return;
    await GamesExportHelper.presentExportOptions(context, games: games);
  }

  Future<void> _importGamesJson() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      dialogTitle: 'Import games (merge)',
      type: FileType.any,
      withData: true,
    );
    if (result == null || result.files.isEmpty || !context.mounted) return;

    final file = result.files.single;
    if (file.bytes == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content:
                Text('Could not read file. Try selecting the file again.')),
      );
      return;
    }
    final jsonString = utf8.decode(file.bytes!);

    if (!GameDatabaseService.looksLikeExportJson(jsonString)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('File does not look like a Pooker games export')),
      );
      return;
    }

    final importResult =
        await GameDatabaseService.importGamesFromJson(jsonString);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Imported ${importResult.gamesImported} game(s). ${importResult.playersAdded} new player(s) added.',
          ),
        ),
      );
    }
  }

  Future<void> _resetData() async {
    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Data'),
        content: const Text('Are you sure you want to reset all data?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Reset'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await GameDatabaseService.resetDatabase();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Data has been reset')),
      );
    }
  }

  void _openAboutPage() async {
    showAboutDialog(
      context: context,
      applicationName: 'Pooker',
      applicationVersion: _version,
      applicationIcon: ClipRRect(
          borderRadius: BorderRadiusGeometry.circular(6),
          child: Image.asset('assets/pooker.png', width: 32)),
      children: [
        const Text('An app to keep track of the score of a pooker game'),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: 10,
              children: [
                Center(
                  child: Text('Version: $_version',
                      style: Theme.of(context).textTheme.labelMedium),
                ),
                FilledButton(
                  onPressed: _openAboutPage,
                  child: const Text('About'),
                ),
                const SizedBox(height: 20),
                Card(
                    child: Column(
                  children: [
                    SwitchListTile(
                      title: const Text('Bonus Point Button'),
                      subtitle: const Text(
                        'Award an extra point for skillful shots or funny fouls',
                      ),
                      value: _skillShotEnabled,
                      onChanged: _toggleSkillShot,
                      secondary: const Icon(Icons.star),
                    ),
                    SwitchListTile(
                      title: Text('Developer Mode',
                          style: TextStyle(
                              color: Theme.of(context).colorScheme.error)),
                      subtitle: const Text(
                        'WARNING: May result in loss of data',
                      ),
                      value: _developerModeEnabled,
                      onChanged: _toggleDeveloperMode,
                      secondary: const Icon(Icons.developer_mode),
                    )
                  ],
                )),
                const SizedBox(height: 20),
                Text(
                  'Export & share games',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const Text(
                  'Export games as a shareable file. Others can import it to add these games and any new players without losing existing data.',
                  style: TextStyle(fontSize: 13),
                ),
                const SizedBox(height: 8),
                ElevatedButton.icon(
                  onPressed: _exportGamesJson,
                  icon: const Icon(Icons.upload_file),
                  label: const Text('Export all games'),
                ),
                ElevatedButton.icon(
                  onPressed: _importGamesJson,
                  icon: const Icon(Icons.download),
                  label: const Text('Import games (merge)'),
                ),
                const SizedBox(height: 20),
                ..._buildDatabaseOptions()
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildDatabaseOptions() {
    if (!kIsWeb && _developerModeEnabled) {
      return [
        Text(
          'Database',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        ElevatedButton(
          onPressed: _exportDatabase,
          child: const Text('Export Database'),
        ),
        ElevatedButton(
          onPressed: _importDatabase,
          child: const Text('Import Database'),
        ),
        ElevatedButton(
          onPressed: _resetData,
          child: const Text('Reset Data', style: TextStyle(color: Colors.red)),
        )
      ];
    }

    return [];
  }
}
