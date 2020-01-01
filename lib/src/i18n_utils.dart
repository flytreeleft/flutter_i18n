/*
 * Copyright (C) 2020 flytreeleft<flytreeleft@crazydan.org>
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

final Map<Locale, List<String>> _localeCodesMap = {};
final Map<String, Locale> _strLocaleMap = {};

String trimToEmpty(String str) {
  return str?.trim() ?? '';
}

String trimToNull(String str) {
  final String trimmed = trimToEmpty(str);

  return trimmed == '' ? null : trimmed;
}

List<String> parseLocalCodes(Locale locale) {
  if (_localeCodesMap.containsKey(locale)) {
    return _localeCodesMap[locale];
  }

  List<String> codes = _localeCodesMap.putIfAbsent(locale, () => []);

  // Sort codes by the priority
  if (locale.countryCode != null && locale.scriptCode != null) {
    codes.addAll([
      locale.languageCode + '_' + locale.scriptCode + '_' + locale.countryCode,
      locale.languageCode + '-' + locale.scriptCode + '-' + locale.countryCode
    ]);
  }

  if (locale.scriptCode != null) {
    codes.addAll([locale.languageCode + '_' + locale.scriptCode, locale.languageCode + '-' + locale.scriptCode]);
  }

  if (locale.countryCode != null) {
    codes.addAll([locale.languageCode + '_' + locale.countryCode, locale.languageCode + '-' + locale.countryCode]);
  }

  codes.add(locale.languageCode);

  return codes;
}

Locale strToLocale(String str) {
  final String trimmedStr = trimToNull(str);
  List<String> codes = trimmedStr?.split(RegExp(r'-|_')) ?? [];

  if (codes.isEmpty) {
    return null;
  }

  if (_strLocaleMap.containsKey(trimmedStr)) {
    return _strLocaleMap[trimmedStr];
  }

  Locale locale;
  if (codes.length == 1) {
    locale = Locale(codes[0]);
  } else if (codes.length == 3) {
    locale = Locale.fromSubtags(languageCode: codes[0], scriptCode: codes[1], countryCode: codes[2]);
  }

  _strLocaleMap[trimmedStr] = locale = Locale(codes[0], codes[1]);

  return locale;
}
