/*
 * Copyright (C) 2019 flytreeleft<flytreeleft@crazydan.org>
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import 'package:flutter/material.dart';

import 'package:flutter_localizations/flutter_localizations.dart';

import 'package:flutter_i18n/flutter_i18n.dart';

import './app_state.dart';
import './page/home_page.dart';

import './locale_controller.dart';

final I18n _i18n = I18n.build();

void main() => runApp(I18nApp());

class I18nApp extends StatefulWidget {
  final AppState appState = AppState(locale: const Locale('zh'), supportedLocales: [
    // https://en.wikipedia.org/wiki/Language_localisation#Language_tags_and_codes
    const Locale('en'),
    const Locale('en', 'US'),
    const Locale('en', 'GB'),
    const Locale.fromSubtags(languageCode: 'zh'),
    const Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hans'),
    const Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hant'),
  ]);

  @override
  State<StatefulWidget> createState() => _I18nAppState();
}

class _I18nAppState extends State<I18nApp> {
  final LocaleController _localeController = LocaleController(null);

  @override
  void initState() {
    super.initState();

    this._localeController.value = this.widget.appState.locale;
    this._localeController.addListener(this._doChangeLocale);
  }

  @override
  void dispose() {
    this._localeController.removeListener(this._doChangeLocale);

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      locale: this.widget.appState.locale,
      supportedLocales: this.widget.appState.supportedLocales,
      localizationsDelegates: [
        I18n.delegate(),
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      onGenerateTitle: (context) => _i18n.of(context).lang('Flutter I18n Example'),
      home: HomePage(
        localeController: this._localeController,
        appState: this.widget.appState,
        onGenerateTitle: (context) => _i18n.of(context).lang('Flutter I18n Example'),
      ),
    );
  }

  void _doChangeLocale() {
    setState(() {
      this.widget.appState.changeLocale(this._localeController.value);
    });
  }
}
