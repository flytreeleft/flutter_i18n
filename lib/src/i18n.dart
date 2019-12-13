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

import './i18n_resource.dart';

const _default_module = '_';
const _default_namespace = 'default';
const _default_base_path = 'assets/i18n';
const _default_manifest_path = 'AssetManifest.json';

class I18n {
  final String _namespace;
  final String _module;

  const I18n({String namespace, String module})
      : this._module = module ?? _default_module,
        this._namespace = namespace ?? _default_namespace;

  static _I18nDelegate delegate({String basePath, String manifestPath}) {
    return _I18nDelegate(basePath ?? _default_base_path, manifestPath ?? _default_manifest_path);
  }

  static I18n build({String package, String namespace, dynamic module}) {
    // TODO Support 'package' for a Flutter library: try to load the i18n message resources from 'packages/<lib_name>/assets/i18n' first
    final name = module == null || module is String ? module : module.toString();

    return I18n(module: name, namespace: namespace);
  }

  _I18nLang of(BuildContext context) {
    _I18nLangContext langContext = Localizations.of<_I18nLangContext>(context, _I18nLangContext);

    return langContext.module(namespace: this._namespace, module: this._module);
  }
}

class _I18nDelegate extends LocalizationsDelegate<_I18nLangContext> {
  final String _basePath;
  final String _manifestPath;

  _I18nDelegate(String basePath, String manifestPath)
      : this._basePath = basePath.replaceAll(RegExp(r'^/+|/+$'), ''),
        this._manifestPath = manifestPath;

  // Support all locale language
  @override
  bool isSupported(Locale locale) => true;

  @override
  bool shouldReload(_I18nDelegate old) => false;

  @override
  Future<_I18nLangContext> load(Locale locale) async {
    // TODO Load and cache all language messages
    // Assume that changing language isn't a high frequency action,
    // so we just rebuild the _I18nContext to save the memory.
    _I18nLangContext langContext = _I18nLangContext(locale);

    await langContext.load(this._basePath, this._manifestPath);

    return langContext;
  }
}

class _I18nLangContext {
  final Locale _locale;

  I18nResource _resource;

  _I18nLangContext(this._locale);

  _I18nLang module({String namespace, String module}) {
    return _I18nLang(context: this, namespace: namespace, module: module);
  }

  Future<bool> load(String basePath, String manifestPath) async {
    this._resource = await I18nResource.load(this._locale, basePath: basePath, manifestPath: manifestPath);

    return true;
  }
}

class _I18nLang {
  final String _namespace;
  final String _module;
  final _I18nLangContext _context;

  const _I18nLang({_I18nLangContext context, String namespace, String module})
      : this._namespace = namespace,
        this._module = module,
        this._context = context;

  String lang(String text, {dynamic args, String annotation, lang}) {
    // TODO Call `lang.toString()`
    final I18nMessage message = this._context._resource.get(namespace: this._namespace, module: this._module);

    return message.parse(text, args: args, annotation: annotation);
  }
}
