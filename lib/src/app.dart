import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'package:itemeyes/src/views/receipt_details_view.dart';
import 'package:itemeyes/src/views/receipt_list_view.dart';
import 'package:itemeyes/src/settings/settings_controller.dart';
import 'package:itemeyes/src/settings/settings_view.dart';
import 'package:itemeyes/src/views/receipt_split_view.dart';

/// The Widget that configures your application.
class MyApp extends StatelessWidget {
  const MyApp({
    super.key,
    required this.settingsController,
  });

  final SettingsController settingsController;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: settingsController,
      builder: (BuildContext context, Widget? child) {
        return MaterialApp(
          restorationScopeId: 'app',
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('en', ''), // English, no country code
          ],
          onGenerateTitle: (BuildContext context) => AppLocalizations.of(context)!.appTitle,
          theme: ThemeData(),
          darkTheme: ThemeData.dark(),
          themeMode: settingsController.themeMode,
          onGenerateRoute: (RouteSettings routeSettings) {
            return MaterialPageRoute<void>(
              settings: routeSettings,
              builder: (BuildContext context) {
                switch (routeSettings.name) {
                  case SettingsView.routeName:
                    return SettingsView(controller: settingsController);
                  case ReceiptDetailsView.routeName:
                    return const ReceiptDetailsView();
                  case ReceiptSplitView.routeName:
                    return const ReceiptSplitView();
                  case ReceiptListView.routeName:
                  default:
                    return const ReceiptListView();
                }
              },
            );
          },
        );
      },
    );
  }
}
