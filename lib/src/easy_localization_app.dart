import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:easy_localization/src/easy_localization_controller.dart';
import 'package:easy_logger/easy_logger.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'asset_loader.dart';
import 'localization.dart';

part 'utils.dart';

///  EasyLocalization
///  example:
///  ```
///  void main(){
///    runApp(EasyLocalization(
///      child: MyApp(),
///      supportedLocales: [Locale('en', 'US'), Locale('ar', 'DZ')],
///      path: 'resources/langs/langs.csv',
///      assetLoader: CsvAssetLoader()
///    ));
///  }
///  ```
class EasyLocalization extends StatefulWidget {
  /// Place for your main page widget.
  final Widget child;

  /// List of supported locales.
  /// {@macro flutter.widgets.widgetsApp.supportedLocales}
  final List<Locale> supportedLocales;

  /// Locale when the locale is not in the list
  final Locale? fallbackLocale;

  /// Overrides device locale.
  final Locale? startLocale;

  /// Force update of the controller for runtime [assetLoader] update.
  final bool forceUpdateController;

  /// Trigger for using only language code for reading localization files.
  /// @Default value false
  /// Example:
  /// ```
  /// en.json //useOnlyLangCode: true
  /// en-US.json //useOnlyLangCode: false
  /// ```
  final bool useOnlyLangCode;

  /// If a localization key is not found in the locale file, try to use the fallbackLocale file.
  /// @Default value false
  /// Example:
  /// ```
  /// useFallbackTranslations: true
  /// ```
  final bool useFallbackTranslations;

  /// If a localization key is empty in the locale file, try to use the fallbackLocale file.
  /// Does not take effect if [useFallbackTranslations] is false.
  /// @Default value false
  /// Example:
  /// ```
  /// useFallbackTranslationsForEmptyResources: true
  /// ```
  final bool useFallbackTranslationsForEmptyResources;

  /// Ignore usage of plural strings for languages that do not use plural rules.
  /// @Default value false
  /// Example:
  /// ```
  /// // Default behavior, use "zero" rule for 0 even if the language doesn't
  /// // use it by default (e.g. "en"). If "zero" localization for that string
  /// // doesn't exist, "other" is still used as fallback.
  /// // "nTimes": "{count, plural, =0{never} =1{once} other{{count} times}}"
  /// // Text(AppLocalizations.of(context)!.nTimes(_counter)),
  /// // will print "never, once, 2 times" for ALL languages.
  /// ignorePluralRules: true
  /// // Use "zero" rule for 0 only if the language is set to do so (e.g. for
  /// "lt" but not for "en").
  /// // "nTimes": "{count, plural, =0{never} =1{once} other{{count} times}}"
  /// // Text(AppLocalizations.of(context)!.nTimes(_counter)),
  /// // will print "never, once, 2 times" ONLY for languages with plural rules.
  /// ignorePluralRules: false
  /// ```
  final bool ignorePluralRules;

  /// Path to your folder with localization files.
  /// Example:
  /// ```dart
  /// path: 'assets/translations',
  /// path: 'assets/translations/lang.csv',
  /// ```
  final String path;

  /// Class loader for localization files.
  /// You can use custom loaders from [Easy Localization Loader](https://github.com/aissat/easy_localization_loader) or create your own class.
  /// @Default value `const RootBundleAssetLoader()`
  // ignore: prefer_typing_uninitialized_variables
  final AssetLoader assetLoader;

  /// Class loader for localization files that belong to other packages.
  /// You can use custom loaders from [Easy Localization Loader](https://github.com/aissat/easy_localization_loader) or create your own class.
  /// Example:
  /// ```dart
  //   runApp(
  //   EasyLocalization(
  //     supportedLocales: const <Locale>[
  //       Locale('en'),
  //     ],
  //     fallbackLocale: const Locale('en'),
  //     assetLoader: const RootBundleAssetLoader(),
  //     extraAssetLoaders: [
  //         TranslationsLoader(packageName: 'package_example_1'),
  //         TranslationsLoader(packageName: 'package_example_2'),
  //     ],
  //     path: 'lib/l10n/translations',
  //     child: const MainApp(),
  //   ),
  // );
  /// @Default value `null`
  final List<AssetLoader>? extraAssetLoaders;

  /// Save locale in device storage.
  /// @Default value true
  final bool saveLocale;

  /// Shows a custom error widget when an error is encountered instead of the default error widget.
  /// @Default value `errorWidget = ErrorWidget()`
  final Widget Function(FlutterError? message)? errorWidget;

  EasyLocalization({
    Key? key,
    required this.child,
    required this.supportedLocales,
    required this.path,
    this.fallbackLocale,
    this.startLocale,
    this.useOnlyLangCode = false,
    this.useFallbackTranslations = false,
    this.useFallbackTranslationsForEmptyResources = false,
    this.ignorePluralRules = true,
    this.assetLoader = const RootBundleAssetLoader(),
    this.extraAssetLoaders,
    this.saveLocale = true,
    this.forceUpdateController = false,
    this.errorWidget,
  })  : assert(supportedLocales.isNotEmpty),
        assert(path.isNotEmpty),
        super(key: key) {
    EasyLocalization.logger.debug('Start');
  }

  @override
  // ignore: library_private_types_in_public_api
  _EasyLocalizationState createState() => _EasyLocalizationState();

  // ignore: library_private_types_in_public_api
  static _EasyLocalizationProvider? of(BuildContext context) =>
      _EasyLocalizationProvider.of(context);

  /// ensureInitialized needs to be called in main
  /// so that savedLocale is loaded and used from the
  /// start.
  static Future<void> ensureInitialized() async =>
      await EasyLocalizationController.initEasyLocation();

  /// Customizable logger
  static EasyLogger logger = EasyLogger(name: '🌎 Easy Localization');
}

class _EasyLocalizationState extends State<EasyLocalization> {
  // _EasyLocalizationDelegate? delegate;
  EasyLocalizationController? localizationController;
  FlutterError? translationsLoadError;
  Locale? _currentLocale;

  @override
  void initState() {
    super.initState();

    _udpateLocalizationController('Init state');
  }

  @override
  void didUpdateWidget(covariant EasyLocalization oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.forceUpdateController) {
      _udpateLocalizationController('Did update widget');
    }
  }

  @override
  void dispose() {
    localizationController!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    EasyLocalization.logger.debug('Build');
    if (translationsLoadError != null) {
      return widget.errorWidget != null
          ? widget.errorWidget!(translationsLoadError)
          : ErrorWidget(translationsLoadError!);
    }

    final _EasyLocalizationProvider localisationProvider =
        _EasyLocalizationProvider(
      widget,
      localizationController!,
      delegate: _EasyLocalizationDelegate(
        localizationController: localizationController,
        supportedLocales: widget.supportedLocales,
        useFallbackTranslationsForEmptyResources:
            widget.useFallbackTranslationsForEmptyResources,
        ignorePluralRules: widget.ignorePluralRules,
        forceLoad: widget.forceUpdateController,
      ),
    );
    if (widget.forceUpdateController &&
        localisationProvider.currentLocale != null) {
      if (_currentLocale != null &&
          _currentLocale != localisationProvider.currentLocale) {
        localisationProvider.delegate.load(localisationProvider.currentLocale!);
      }
      _currentLocale = localisationProvider.currentLocale;
    }
    return localisationProvider;
  }

  void _udpateLocalizationController(String debugMessage) {
    if (localizationController != null) {
      localizationController!.dispose();
    }

    EasyLocalization.logger.debug(debugMessage);
    localizationController = EasyLocalizationController(
      saveLocale: widget.saveLocale,
      fallbackLocale: widget.fallbackLocale,
      supportedLocales: widget.supportedLocales,
      startLocale: widget.startLocale,
      assetLoader: widget.assetLoader,
      extraAssetLoaders: widget.extraAssetLoaders,
      useOnlyLangCode: widget.useOnlyLangCode,
      useFallbackTranslations: widget.useFallbackTranslations,
      path: widget.path,
      onLoadError: (FlutterError e) {
        setState(() {
          translationsLoadError = e;
        });
      },
    );
    // causes localization to rebuild with new language
    localizationController!.addListener(() {
      if (mounted) setState(() {});
    });
  }
}

class _EasyLocalizationProvider extends InheritedWidget {
  final EasyLocalization parent;
  final EasyLocalizationController _localeState;
  final Locale? currentLocale;
  final _EasyLocalizationDelegate delegate;

  /// {@macro flutter.widgets.widgetsApp.localizationsDelegates}
  ///
  /// ```dart
  ///   delegates = [
  ///     delegate
  ///     GlobalMaterialLocalizations.delegate,
  ///     GlobalWidgetsLocalizations.delegate,
  ///     GlobalCupertinoLocalizations.delegate
  ///   ],
  /// ```
  List<LocalizationsDelegate> get delegates => [
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ];

  /// Get List of supported locales
  List<Locale> get supportedLocales => parent.supportedLocales;

  // _EasyLocalizationDelegate get delegate => parent.delegate;

  _EasyLocalizationProvider(this.parent, this._localeState,
      {Key? key, required this.delegate})
      : currentLocale = _localeState.locale,
        super(key: key, child: parent.child) {
    EasyLocalization.logger.debug('Init provider');
  }

  /// Get current locale
  Locale get locale => _localeState.locale;

  /// Get fallback locale
  Locale? get fallbackLocale => parent.fallbackLocale;

  // Locale get startLocale => parent.startLocale;

  /// Change app locale
  Future<void> setLocale(Locale locale) async {
    // Check old locale
    if (locale != _localeState.locale) {
      assert(parent.supportedLocales.contains(locale));
      await _localeState.setLocale(locale);
    }
  }

  /// Clears a saved locale from device storage
  Future<void> deleteSaveLocale() async {
    await _localeState.deleteSaveLocale();
  }

  /// Getting device locale from platform
  Locale get deviceLocale => _localeState.deviceLocale;
  Locale? get savedLocale => _localeState.savedLocale;

  /// Reset locale to platform locale
  Future<void> resetLocale() => _localeState.resetLocale();

  @override
  bool updateShouldNotify(_EasyLocalizationProvider oldWidget) {
    return oldWidget.currentLocale != locale;
  }

  static _EasyLocalizationProvider? of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<_EasyLocalizationProvider>();
}

class _EasyLocalizationDelegate extends LocalizationsDelegate<Localization> {
  final List<Locale>? supportedLocales;
  final EasyLocalizationController? localizationController;
  final bool useFallbackTranslationsForEmptyResources;
  final bool ignorePluralRules;
  final bool forceLoad;

  ///  * use only the lang code to generate i18n file path like en.json or ar.json
  // final bool useOnlyLangCode;

  _EasyLocalizationDelegate({
    required this.useFallbackTranslationsForEmptyResources,
    this.ignorePluralRules = true,
    this.localizationController,
    this.supportedLocales,
    this.forceLoad = false,
  }) {
    EasyLocalization.logger.debug('Init Localization Delegate');
  }

  @override
  bool isSupported(Locale locale) => supportedLocales!.contains(locale);

  @override
  Future<Localization> load(Locale value) async {
    EasyLocalization.logger.debug('Load Localization Delegate');
    if (localizationController!.translations == null && forceLoad) {
      await localizationController!.loadTranslations();
    }

    Localization.load(
      value,
      translations: localizationController!.translations,
      fallbackTranslations: localizationController!.fallbackTranslations,
      useFallbackTranslationsForEmptyResources:
          useFallbackTranslationsForEmptyResources,
      ignorePluralRules: ignorePluralRules,
    );
    return Future.value(Localization.instance);
  }

  @override
  bool shouldReload(LocalizationsDelegate<Localization> old) => false;
}
