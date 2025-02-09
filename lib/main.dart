import 'package:dynamic_color/dynamic_color.dart';
import 'package:esde_android/storage.dart';
import 'package:flutter/material.dart';
import 'package:installed_apps/app_info.dart';
import 'package:installed_apps/installed_apps.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'applist.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final settingsProvider = SettingsProvider();
  await settingsProvider.init();
  runApp(ChangeNotifierProvider(
    create: (_) => settingsProvider,
    child: const MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final settingsProvider = Provider.of<SettingsProvider>(context);

    return DynamicColorBuilder(builder: (lightColorScheme, darkColorScheme) {
      return MaterialApp(
          title: 'ES-DE Android',
          theme: ThemeData(
            colorScheme: lightColorScheme ??
                ColorScheme.fromSeed(seedColor: Colors.green),
            useMaterial3: true,
          ),
          darkTheme: ThemeData(
            colorScheme: darkColorScheme ??
                ColorScheme.fromSeed(seedColor: Colors.deepPurple),
            useMaterial3: true,
          ),
          themeMode: ThemeMode.system,
          home: FutureBuilder(
            future: Future.wait([
              InstalledApps.getInstalledApps(!settingsProvider.showSystemApps, true),
              SharedPreferences.getInstance(),
            ]),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              } else if (!snapshot.hasData) {
                return const Center(child: Text('No data'));
              } else {
                return AppListPage(
                    appList: snapshot.data![0] as List<AppInfo>,
                    prefs: snapshot.data![1] as SharedPreferences);
              }
            },
          ));
    });
  }
}
