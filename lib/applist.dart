import 'dart:convert';

import 'package:esde_android/esde.dart';
import 'package:esde_android/settings.dart';
import 'package:esde_android/storage.dart';
import 'package:esde_android/widgets.dart';
import 'package:flutter/material.dart';
import 'package:installed_apps/app_info.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppListPage extends StatefulWidget {
  const AppListPage({super.key, required this.appList, required this.prefs});

  final List<AppInfo> appList;
  final SharedPreferences prefs;

  @override
  State<AppListPage> createState() => _AppListPageState();
}

class _AppListPageState extends State<AppListPage> {
  late Map<String, int> _radioStates;
  late Map<String, bool> _checkStates;

  final TextEditingController _searchController = TextEditingController();
  List<AppInfo> _filteredApps = [];

  @override
  void initState() {
    super.initState();

    _radioStates = (jsonDecode(widget.prefs.getString('radioStates') ?? '{}')
            as Map<dynamic, dynamic>)
        .map((key, value) => MapEntry(key, value));
    _checkStates = (jsonDecode(widget.prefs.getString('checkStates') ?? '{}')
            as Map<dynamic, dynamic>)
        .map((key, value) => MapEntry(key, value));

    _filteredApps = widget.appList;
    _searchController.addListener(_filterApps);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterApps() {
    String query = _searchController.text.toLowerCase();
    setState(() {
      _filteredApps = widget.appList
          .where((app) =>
              app.name.toLowerCase().contains(query) ||
              app.packageName.toLowerCase().contains(query))
          .toList();
    });
  }

  void _setCheckState(AppInfo app, bool value) {
    setState(() {
      _checkStates[app.packageName] = value;
    });
    widget.prefs.setString('checkStates', jsonEncode(_checkStates));
  }

  void _setRadioState(AppInfo app, int value) {
    setState(() {
      _radioStates[app.packageName] = value;
    });
    widget.prefs.setString('radioStates', jsonEncode(_radioStates));
  }

  void _showLoadingDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const Dialog(
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(width: 16),
                Text("Saving apps..."),
              ],
            ),
          ),
        );
      },
    );
  }

  void _hideLoadingDialog() {
    Navigator.of(context).pop();
  }

  Future<void> _sendToEsDe(SettingsProvider settingsProvider) async {
    _showLoadingDialog();

    final List<AppInfo> filteredAppList = widget.appList
        .where((app) =>
            (settingsProvider.whitelist &&
                (_checkStates[app.packageName] ?? false)) ||
            (!settingsProvider.whitelist &&
                !(_checkStates[app.packageName] ?? false)))
        .toList();
    final List<AppInfo> apps = filteredAppList
        .where((app) => (_radioStates[app.packageName] ?? 1) == 1)
        .toList();
    final List<AppInfo> games = filteredAppList
        .where((app) => (_radioStates[app.packageName] ?? 1) == 2)
        .toList();
    final List<AppInfo> emulators = filteredAppList
        .where((app) => (_radioStates[app.packageName] ?? 1) == 3)
        .toList();

    try {
      await EsDeUtils.prepareEsDeFiles(
          apps,
          games,
          emulators,
          settingsProvider.pathRoms,
          settingsProvider.pathMedia,
          settingsProvider.overwriteDirs);
    } catch (e) {
      SnackBar snackBar = SnackBar(
        content: Text('Error saving apps: $e'),
        duration: const Duration(seconds: 2),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    } finally {
      _hideLoadingDialog();
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color accentColor = Theme.of(context).colorScheme.secondary;
    final settingsProvider = Provider.of<SettingsProvider>(context);

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 50,
        backgroundColor: Theme.of(context).colorScheme.onSecondary,
        title: Row(
          children: [
            Text('Installed Apps (${_filteredApps.length})',
                style:
                    TextStyle(color: Theme.of(context).colorScheme.secondary)),
            const SizedBox(width: 10),
            Expanded(
              child: SizedBox(
                height: 40,
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    labelText: 'Search',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    fillColor: Theme.of(context).colorScheme.surface,
                    contentPadding: const EdgeInsets.all(10),
                  ),
                ),
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => const SettingsPage()));
            },
            icon: const Icon(Icons.settings),
            color: accentColor,
          ),
          IconButton(
            onPressed: () => _sendToEsDe(settingsProvider),
            icon: const Icon(Icons.save),
            color: accentColor,
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: _filteredApps.length,
        itemBuilder: (BuildContext context, int index) {
          final AppInfo app = _filteredApps[index];
          final Image? image = app.icon!.isNotEmpty
              ? Image.memory(app.icon!, width: 40, height: 40)
              : null;

          if (_checkStates[app.packageName] == null) {
            _checkStates[app.packageName] = false;
          }
          if (_radioStates[app.packageName] == null) {
            _radioStates[app.packageName] = 1;
          }

          bool isChecked = _checkStates[app.packageName]!;
          int selectedRadio = _radioStates[app.packageName]!;

          return Stack(children: [
            ListTile(
              leading: GestureDetector(
                child: image,
                onTap: () =>
                    _setCheckState(app, !_checkStates[app.packageName]!),
              ),
              title: Text(app.name),
              subtitle: Text(app.packageName),
              trailing: Wrap(children: [
                LabeledCheckbox(
                  label: settingsProvider.whitelist ? 'Show' : 'Hide',
                  value: isChecked,
                  onChanged: (bool? value) => _setCheckState(app, value!),
                ),
                LabeledRadio(
                  label: 'App',
                  value: 1,
                  groupValue: selectedRadio,
                  onChanged: (int? value) => _setRadioState(app, value!),
                ),
                LabeledRadio(
                  label: 'Game',
                  value: 2,
                  groupValue: selectedRadio,
                  onChanged: (int? value) => _setRadioState(app, value!),
                ),
                LabeledRadio(
                  label: 'Emulator',
                  value: 3,
                  groupValue: selectedRadio,
                  onChanged: (int? value) => _setRadioState(app, value!),
                ),
              ]),
            ),
            if ((settingsProvider.whitelist &&
                    !_checkStates[app.packageName]!) ||
                (!settingsProvider.whitelist && _checkStates[app.packageName]!))
              Positioned.fill(
                child: IgnorePointer(
                  ignoring: true,
                  child: Container(
                    color: Colors.black.withOpacity(
                        Theme.of(context).brightness == Brightness.light
                            ? 0.25
                            : 0.5),
                  ),
                ),
              ),
          ]);
        },
      ),
    );
  }
}
