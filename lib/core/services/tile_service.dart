import 'dart:io';

import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

class TileService {
  const TileService({
    this.assetPath = 'assets/maps/gensan.pmtiles',
    this.outputFileName = 'gensan.pmtiles',
  });

  final String assetPath;
  final String outputFileName;

  Future<String?> initializeOfflineTiles() async {
    final file = await _tileFile();
    if (await file.exists()) {
      return file.path;
    }

    try {
      final tileBytes = await rootBundle.load(assetPath);
      await file.parent.create(recursive: true);
      await file.writeAsBytes(
        tileBytes.buffer.asUint8List(),
        flush: true,
      );
      return file.path;
    } on Exception {
      return null;
    }
  }

  Future<String?> localTilePath() async {
    final file = await _tileFile();
    if (!await file.exists()) {
      return null;
    }

    return file.path;
  }

  Future<File> _tileFile() async {
    final directory = await getApplicationDocumentsDirectory();
    return File('${directory.path}/$outputFileName');
  }
}
