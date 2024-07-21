import 'package:esde_android/storage.dart';
import 'package:esde_android/widgets.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final settingsProvider = Provider.of<SettingsProvider>(context);

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 50,
        backgroundColor: Theme.of(context).colorScheme.onSecondary,
        title: Text('Path settings',
            style: TextStyle(color: Theme.of(context).colorScheme.secondary)),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            SwitchSetting(
                text: 'Use whitelist instead of blacklist ',
                value: settingsProvider.whitelist,
                onChanged: (bool newValue) {
                  settingsProvider.whitelist = newValue;
                }),
            SwitchSetting(
                text: 'Delete existing files ',
                value: settingsProvider.overwriteDirs,
                onChanged: (bool newValue) {
                  settingsProvider.overwriteDirs = newValue;
                }),
            SwitchSetting(
                text: 'Do not save media ',
                value: settingsProvider.doNotSaveMedia,
                onChanged: (bool newValue) {
                  settingsProvider.doNotSaveMedia = newValue;
                }),
            PathPicker(
                pickerText: 'ROMs',
                path: settingsProvider.pathRoms,
                onChanged: (String newString) {
                  settingsProvider.pathRoms = newString;
                },
                nameCheck: 'ROMs'),
            if (!settingsProvider.doNotSaveMedia)
              PathPicker(
                  pickerText: 'ES-DE/downloaded_media',
                  path: settingsProvider.pathMedia,
                  onChanged: (String newString) {
                    settingsProvider.pathMedia = newString;
                  },
                  nameCheck: 'downloaded_media'),
          ],
        ),
      ),
    );
  }
}
