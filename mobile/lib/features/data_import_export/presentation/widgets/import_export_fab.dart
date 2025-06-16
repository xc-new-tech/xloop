import 'package:flutter/material.dart';

class ImportExportFab extends StatelessWidget {
  final VoidCallback onImport;
  final VoidCallback onExport;
  final VoidCallback onBackup;

  const ImportExportFab({
    super.key,
    required this.onImport,
    required this.onExport,
    required this.onBackup,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        FloatingActionButton(
          heroTag: "backup",
          onPressed: onBackup,
          backgroundColor: Colors.orange,
          child: const Icon(Icons.backup),
        ),
        const SizedBox(height: 8),
        FloatingActionButton(
          heroTag: "import",
          onPressed: onImport,
          backgroundColor: Colors.green,
          child: const Icon(Icons.download),
        ),
        const SizedBox(height: 8),
        FloatingActionButton(
          heroTag: "export",
          onPressed: onExport,
          backgroundColor: Colors.blue,
          child: const Icon(Icons.upload),
        ),
      ],
    );
  }
} 