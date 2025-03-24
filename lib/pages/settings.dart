import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart'; // Add this import
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
          children: [
            ElevatedButton(
              onPressed: _exportDatabase,
              child: const Text('Export Database'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _importDatabase,
              child: const Text('Import Database'),
            ),
          ],
        ),
      ),
    );
  }
}
