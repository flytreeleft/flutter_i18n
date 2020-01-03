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

import './i18n_const.dart';
import './i18n_module.dart';
import './i18n_resource.dart';
import './i18n_resource_loader.dart';

const I18nResourceLoaderSpec _default_loader = const I18nResourceLoaderSpec(cacheable: true, showError: false);

class I18n {
  final String _package;
  final String _namespace;
  final String _module;

  const I18n({String package, String namespace, String module})
      : this._package = package,
        this._module = module,
        this._namespace = namespace;

  /// Get the [I18nModuleContext] which is bound to the current [BuildContext],
  /// then build and return [I18nModule] for the [I18n] instance.
  I18nModule of(BuildContext context) {
    return _getModuleContext(context).module(package: this._package, namespace: this._namespace, module: this._module);
  }

  /// Get the [Locale] which is related to the current [BuildContext].
  Locale locale(BuildContext context) {
    return _getModuleContext(context).locale;
  }

  /// Build an [I18n] instance for the specified [module] which is in the [namespace]
  /// and maybe is a flutter library named as [package].
  static I18n build({String package, String namespace, dynamic module}) {
    final name = module == null || module is String ? module : module.toString();

    return I18n(package: package, namespace: namespace, module: name);
  }

  /// Create [LocalizationsDelegate] instance which will load i18n messages and build the [I18nModuleContext].
  static LocalizationsDelegate<I18nModuleContext> delegate({
    String basePath,
    String manifestPath,
    I18nResourceLoaderSpec loader,
    bool debug: false,
  }) {
    loader = loader ?? _default_loader;

    return _I18nDelegate(
      basePath ?? default_base_path,
      manifestPath ?? default_manifest_path,
      I18nResourceLoaderSpec(
        cacheable: !debug && loader.cacheable,
        showError: debug || loader.showError,
        load: loader.load,
        parse: loader.parse,
      ),
    );
  }

  I18nModuleContext _getModuleContext(BuildContext context) {
    I18nModuleContext moduleContext;

    if (context == null || (moduleContext = Localizations.of<I18nModuleContext>(context, I18nModuleContext)) == null) {
      moduleContext = I18nModuleContext.noop;
    }

    return moduleContext;
  }
}

class _I18nDelegate extends LocalizationsDelegate<I18nModuleContext> {
  final String _basePath;
  final String _manifestPath;

  final I18nResourceLoader _normalResourceLoader;
  final I18nPackageResourceLoader _packageResourceLoader;

  _I18nDelegate(String basePath, String manifestPath, I18nResourceLoaderSpec loader)
      : this._basePath = basePath,
        this._manifestPath = manifestPath,
        this._packageResourceLoader = I18nPackageResourceLoader(
          cacheable: loader.cacheable,
          showError: loader.showError,
        ),
        this._normalResourceLoader = loader.load != null
            ? I18nUserDefinedResourceLoader(loader)
            : I18nNormalResourceLoader(cacheable: loader.cacheable, showError: loader.showError);

  // Support all locale language
  @override
  bool isSupported(Locale locale) => true;

  @override
  bool shouldReload(_I18nDelegate old) => false;

  /// When the [locale] is changed, this method will be called.
  /// Note, if [loader].cacheable is true, all i18n resources will be cached
  /// even if the loader instances were rebuilt.
  @override
  Future<I18nModuleContext> load(Locale locale) async {
    I18nResource packageResource = await this._packageResourceLoader.load(locale, 'packages', default_manifest_path);
    I18nResource normalResource = await this._normalResourceLoader.load(locale, this._basePath, this._manifestPath);

    return I18nModuleContext(locale, I18nCombinedResource([packageResource, normalResource]));
  }
}
