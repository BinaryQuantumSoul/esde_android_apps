import 'dart:io';

import 'package:esde_android/storage.dart';
import 'package:installed_apps/app_info.dart';

class EsDeUtils {
  static Future<void> prepareEsDeFiles(
      List<AppInfo> apps,
      List<AppInfo> games,
      List<AppInfo> emulators,
      SettingsProvider settingsProvider) async {
    final List<String> mediaDirs = [
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
    final String romPath = settingsProvider.pathRoms;
    final String mediaPath = settingsProvider.pathMedia;

    for (var pair in [
      [apps, 'androidapps'],
      [games, 'androidgames'],
      [emulators, 'emulators']
    ]) {
      final List<AppInfo> appList = pair[0] as List<AppInfo>;
      final String system = pair[1] as String;

      final Directory romDirectory = Directory('$romPath/$system');
      final Directory mediaDirectory = Directory('$mediaPath/$system');

      if (settingsProvider.overwriteDirs) {
        if (await romDirectory.exists()) {
          await romDirectory.delete(recursive: true);
        }
        if (!settingsProvider.doNotSaveMedia && await mediaDirectory.exists()) {
          await mediaDirectory.delete(recursive: true);
        }
      }

      for (var app in appList) {
        final String escapedName = app.name
            .replaceAll(':', ' -')
            .replaceAll(RegExp(r'[\\/:*?"<>|]'), '_');

        File file = File('$romPath/$system/$escapedName.app');
        await file.create(recursive: true);
        await file.writeAsString(app.packageName);

        if (!settingsProvider.doNotSaveMedia) {
          for (var media in mediaDirs) {
            if (app.icon != null) {
              final File file = File('$mediaPath/$system/$media/$escapedName.png');
              await file.create(recursive: true);
              await file.writeAsBytes(app.icon!);
            }
          }
        }
      }
    }
  }
}
