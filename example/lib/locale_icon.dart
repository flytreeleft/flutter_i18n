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

class LocaleIcon {
  final String text;
  final Locale locale;
  final Image img;

  LocaleIcon({this.text, this.locale, this.img});
}

class LocaleIcons {
  static LocaleIcon get(Locale locale) {
    String countryCode = locale.countryCode;

    String text = '';
    // https://github.com/bytepark/country_icons/tree/master/icons/flags/png
    // https://en.wikipedia.org/wiki/Language_localisation#Language_tags_and_codes
    switch (locale.languageCode) {
      case 'zh':
        text = '中文';
        countryCode = 'CN';

        if (locale.scriptCode == 'Hans') {
          text = '中文(简体)';
        } else if (locale.scriptCode == 'Hant') {
          text = '中文(繁體)';
        }
        break;
      default:
        text = 'English' + (countryCode != null ? '($countryCode)' : '');
        countryCode = countryCode ?? 'GB';
        break;
    }

    return LocaleIcon(
      text: text,
      locale: locale,
      img: Image.asset(
        'icons/flags/png/${countryCode.toLowerCase()}.png',
        package: 'country_icons',
        width: 24,
        height: 24,
        fit: BoxFit.scaleDown,
      ),
    );
  }
}
