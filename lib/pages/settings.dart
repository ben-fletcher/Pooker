import 'dart:io';

import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart'; // Add this import
import 'package:package_info_plus/package_info_plus.dart';
import 'package:pooker_score/services/database_service.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
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
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    String version = packageInfo.version;
    showAboutDialog(
      context: context,
      applicationName: 'Pooker',
      applicationVersion: version,
      applicationIcon: Image.asset('assets/pooker.png', width: 32),
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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 10,
          children: [
            ElevatedButton(
              onPressed: _openAboutPage,
              child: const Text('About'),
            ),
            const SizedBox(height: 20),
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
              child:
                  const Text('Reset Data', style: TextStyle(color: Colors.red)),
            ),
          ],
        ),
      ),
    );
  }
}
