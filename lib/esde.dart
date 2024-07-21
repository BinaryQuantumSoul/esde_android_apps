import 'dart:io';

import 'package:installed_apps/app_info.dart';

class EsDeUtils {
  static Future<void> prepareEsDeFiles(
      List<AppInfo> apps,
      List<AppInfo> games,
      List<AppInfo> emulators,
      String romPath,
      String mediaPath,
      bool overwriteDirs) async {
    final mediaDirs = [
      '3dboxes',
      'backcovers',
      'covers',
      'fanart',
      'marquees',
      'miximages',
      'physicalmedia',
      'screenshots',
      'titlescreens'
    ];

    for (var pair in [
      [apps, 'androidapps'],
      [games, 'androidgames'],
      [emulators, 'emulators']
    ]) {
      final List<AppInfo> appList = pair[0] as List<AppInfo>;
      final String system = pair[1] as String;

      final Directory romDirectory = Directory('$romPath/$system');
      final Directory mediaDirectory = Directory('$mediaPath/$system');

      if (overwriteDirs) {
        if (await romDirectory.exists()) {
          await romDirectory.delete(recursive: true);
        }
        if (await mediaDirectory.exists()) {
          await mediaDirectory.delete(recursive: true);
        }
      }
      await romDirectory.create();
      await mediaDirectory.create();

      for (var app in appList) {
        final String escapedName = app.name
            .replaceAll(':', ' -')
            .replaceAll(RegExp(r'[\\/:*?"<>|]'), '_');

        File file = File('$romPath/$system/$escapedName.app');
        String fileName = escapedName;
        int counter = 1;
        while (await file.exists()) {
          counter++;
          fileName = '$escapedName $counter';
          file = File('$romPath/$system/$fileName.app');
        }

        await file.create();
        await file.writeAsString(app.packageName);

        for (var media in mediaDirs) {
          if (app.icon != null) {
            await Directory('$mediaPath/$system/$media').create();
            final File file =
                File('$mediaPath/$system/$media/$fileName.png');

            await file.create();
            await file.writeAsBytes(app.icon!);
          }
        }
      }
    }
  }
}
