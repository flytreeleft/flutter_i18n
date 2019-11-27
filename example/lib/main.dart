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

import './page/home_page.dart';

final I18n _i18n = I18n.build();

void main() => runApp(I18nApp());

class I18nApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      locale: const Locale('zh'),
      supportedLocales: [
        const Locale('en'),
        const Locale('zh'),
      ],
      localizationsDelegates: [
        I18n.delegate(),
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      onGenerateTitle: (context) => _i18n.of(context).lang('Flutter I18n Example'),
      home: HomePage(onGenerateTitle: (context) => _i18n.of(context).lang('Flutter I18n Example')),
    );
  }
}
