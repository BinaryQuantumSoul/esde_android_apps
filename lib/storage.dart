import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsProvider with ChangeNotifier {
  late SharedPreferences prefs;

  late bool _whitelist;
  late bool _showSystemApps;
  late bool _overwriteDirs;
  late bool _doNotSaveMedia;
  late bool _disablePathCheck;
  late String _pathRoms;
  late String _pathMedia;

  bool get whitelist => _whitelist;
  bool get showSystemApps => _showSystemApps;
  bool get overwriteDirs => _overwriteDirs;
  bool get doNotSaveMedia => _doNotSaveMedia;
  bool get disablePathCheck => _disablePathCheck;
  String get pathRoms => _pathRoms;
  String get pathMedia => _pathMedia;

  set whitelist(bool value) {
    _whitelist = value;
    prefs.setBool('setting_whitelist', value);
    notifyListeners();
  }

  set showSystemApps(bool value) {
    _showSystemApps = value;
    prefs.setBool('setting_show_system_apps', value);
    notifyListeners();
  }

  set overwriteDirs(bool value) {
    if (value) {
      disablePathCheck = false;
    }

    _overwriteDirs = value;
    prefs.setBool('setting_overwrite', value);
    notifyListeners();
  }

  set doNotSaveMedia(bool value) {
    _doNotSaveMedia = value;
    prefs.setBool('setting_no_media', value);
    notifyListeners();
  }

  set disablePathCheck(bool value) {
    if (value) {
      overwriteDirs = false;
    } else if (_disablePathCheck) {
      pathRoms = '';
    }

    _disablePathCheck = value;
    prefs.setBool('setting_disable_path_check', value);
    notifyListeners();
  }

  set pathRoms(String value) {
    _pathRoms = value;
    prefs.setString('setting_path_roms', value);
    notifyListeners();
  }

  set pathMedia(String value) {
    _pathMedia = value;
    prefs.setString('setting_path_media', value);
    notifyListeners();
  }

  Future<void> init() async {
    prefs = await SharedPreferences.getInstance();

    _whitelist = prefs.getBool('setting_whitelist') ?? false;
    _showSystemApps = prefs.getBool('setting_show_system_apps') ?? false;
    _overwriteDirs = prefs.getBool('setting_overwrite') ?? false;
    _doNotSaveMedia = prefs.getBool('setting_no_media') ?? false;
    _disablePathCheck = prefs.getBool('setting_disable_path_check') ?? false;

    _pathRoms = prefs.getString('setting_path_roms') ?? 'no directory';
    _pathMedia = prefs.getString('setting_path_media') ?? 'no directory';
    notifyListeners();
  }
}
