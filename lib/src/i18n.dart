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

import 'package:flutter/material.dart';

import './utils.dart';

const _default_module = '_';
const _default_namespace = 'default';
const _default_base_path = 'assets/i18n';

class I18n {
  final String _namespace;
  final String _module;

  const I18n({String namespace, String module})
      : this._module = module ?? _default_module,
        this._namespace = namespace ?? _default_namespace;

  static _I18nDelegate delegate({String basePath}) {
    return _I18nDelegate(basePath ?? _default_base_path);
  }

  static I18n build({String namespace, dynamic module}) {
    final name = module == null || module is String ? module : module.toString();

    return I18n(module: name, namespace: namespace);
  }

  _I18nLang of(BuildContext context) {
    _I18nContext i18nContext = Localizations.of<_I18nContext>(context, _I18nContext);

    return i18nContext._lang(namespace: this._namespace, module: this._module);
  }
}

class _I18nDelegate extends LocalizationsDelegate<_I18nContext> {
  final String _basePath;

  _I18nDelegate(String basePath) : this._basePath = basePath.replaceAll(RegExp(r'^/+|/+$'), '');

  // Support all locale language
  @override
  bool isSupported(Locale locale) => true;

  @override
  bool shouldReload(_I18nDelegate old) => false;

  @override
  Future<_I18nContext> load(Locale locale) async {
    // Assume that changing language isn't a high frequency action,
    // so we just rebuild the _I18nContext to save the memory.
    _I18nContext context = _I18nContext(locale);

    await context.load(this._basePath);

    return context;
  }
}

class _I18nContext {
  final Locale _locale;

  Map<String, Map> _mapping = {};

  _I18nContext(this._locale);

  _I18nLang _lang({String namespace, String module}) {
    return _I18nLang(namespace: namespace, module: module, context: this);
  }

  Future<bool> load(String basePath) async {
    this._mapping = await loadI18nResources(this._locale, 'AssetManifest.json', basePath);

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
    final String ns = this._namespace + '/' + this._module;
    final Map message = this._context._mapping[ns][text];

    if (message != null && message[this._context._locale] != null) {
      text = message[this._context._locale];
    }

    return text;
  }
}
