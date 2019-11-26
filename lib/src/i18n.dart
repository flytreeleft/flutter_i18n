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
  final String _namespace;
  final String _module;

  const I18n({String namespace, String module})
      : this._module = module ?? '_',
        this._namespace = namespace ?? 'default';

  static _I18nDelegate delegate({String path: 'assets/i18n'}) {
    return _I18nDelegate(path: path);
  }

  static I18n build({String namespace, dynamic module}) {
    final name = module is String ? module : module.runtimeType.toString();

    return I18n(module: name, namespace: namespace);
  }

  _I18nLang of(BuildContext context) {
    _I18nContext i18nContext = Localizations.of<_I18nContext>(context, _I18nContext);

    return i18nContext._lang(namespace: this._namespace, module: this._module);
  }
}

class _I18nDelegate extends LocalizationsDelegate<_I18nContext> {
  final String _path;

  const _I18nDelegate({@required String path}) : this._path = path;

  // Support all locale language
  @override
  bool isSupported(Locale locale) => true;

  @override
  bool shouldReload(_I18nDelegate old) => false;

  @override
  Future<_I18nContext> load(Locale locale) async {
    await _I18nContext.load(this._path);

    // TODO Cache _I18nContext

    return _I18nContext(locale);
  }
}

class _I18nContext {
  final Locale _locale;

  _I18nContext(this._locale);

  _I18nLang _lang({String namespace, String module}) {
    return _I18nLang(namespace: namespace, module: module, context: this);
  }

  static Future<bool> load(String path) async {
    // https://stackoverflow.com/questions/56544200/flutter-how-to-get-a-list-of-names-of-all-images-in-assets-directory#answer-56555070
    final manifestContent = await rootBundle.loadString('AssetManifest.json');
    final Map<String, dynamic> manifestMap = json.decode(manifestContent);

    return true;
  }
}

class _I18nLang {
  final String _namespace;
  final String _module;
  final _I18nContext _context;

  const _I18nLang({String namespace, String module, _I18nContext context})
      : this._namespace = namespace,
        this._module = module,
        this._context = context;

  String lang(String text, {dynamic args, String annotation}) {
    return '';
  }
}
