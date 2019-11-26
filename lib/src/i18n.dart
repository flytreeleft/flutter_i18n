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

import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class I18n {
  final Locale locale;

  const I18n(this.locale);

  static _I18nDelegate delegate({String path: 'assets/i18n'}) {
    return _I18nDelegate(path: path);
  }

  static I18n of(BuildContext context, {dynamic module, String namespace}) {
    final type = module.runtimeType.toString();
    return Localizations.of<I18n>(context, I18n);
  }

  String lang(String text, {dynamic args, String annotation}) {
    return '';
  }

  Future<bool> load() async {
    // https://stackoverflow.com/questions/56544200/flutter-how-to-get-a-list-of-names-of-all-images-in-assets-directory#answer-56555070
    final manifestContent = await rootBundle.loadString('AssetManifest.json');
    final Map<String, dynamic> manifestMap = json.decode(manifestContent);

    return true;
  }
}

class _I18nDelegate extends LocalizationsDelegate<I18n> {
  final String path;

  const _I18nDelegate({@required this.path});

  // Support all locale language
  @override
  bool isSupported(Locale locale) => true;

  @override
  bool shouldReload(_I18nDelegate old) => false;

  @override
  Future<I18n> load(Locale locale) async {
    I18n i18n = I18n(locale);
    await i18n.load();

    return i18n;
  }
}
