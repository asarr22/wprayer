import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wprayer/providers/locale_provider.dart';
import 'package:wprayer/screens/home_screen.dart';
import 'package:wprayer/utils/constants/texts.dart';
import 'package:wprayer/utils/localization/app_localizations.dart';
import 'package:wprayer/utils/theme/app_theme.dart';

class App extends ConsumerWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeProvider);

    return MaterialApp(
      title: WTexts.appName,
      debugShowCheckedModeBanner: false,
      theme: WAppTheme.dark,
      // Localization
      locale: locale,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      
      supportedLocales: AppLocalizations.supportedLocales,
      home: const HomeScreen(),
    );
  }
}
