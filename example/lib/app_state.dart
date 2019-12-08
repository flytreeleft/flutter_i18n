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

import 'dart:ui';

import 'package:flutter/foundation.dart';

class AppState {
  Locale _locale;
  List<Locale> _supportedLocales;

  AppState({@required Locale locale, List<Locale> supportedLocales})
      : this._locale = locale,
        this._supportedLocales = supportedLocales;

  Locale get locale => this._locale;

  List<Locale> get supportedLocales => [...this._supportedLocales];

  void changeLocale(Locale locale) {
    if (locale == null || locale == this._locale) {
      return;
    }

    this._locale = locale;
  }
}
