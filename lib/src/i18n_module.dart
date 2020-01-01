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

import './i18n_const.dart';
import './i18n_utils.dart';
import './i18n_message.dart';
import './i18n_resource.dart';

class I18nModule {
  /// Noop [I18nModule] which will just return the parsed original text when calling [lang].
  /// It will be used when [I18n].delegate() wasn't called in the app's top widget.
  static final I18nModule noop = const I18nModule(null, null, null);

  final I18nModuleContext context;
  final String namespace;
  final String module;

  const I18nModule(this.context, this.namespace, this.module);

  /// Parse and return the localized text for the specified [text].
  /// If [lang] is specified, it will return the text which is associated with [lang].
  String lang(String text, {dynamic args, String annotation, lang}) {
    final I18nMessages messages = this.context?.resource?.get(this.namespace, this.module) ?? I18nMessages.empty;
    final I18nMessage message = messages.get(text, annotation: annotation);

    List<String> localeCodes = [];

    if (messages != I18nMessages.empty) {
      if (lang is Locale) {
        localeCodes = parseLocalCodes(lang);
      } else {
        final Locale locale = strToLocale(lang?.toString());

        localeCodes = parseLocalCodes(locale ?? this.context.locale);
      }
    }

    return message.parse(localeCodes, args: args);
  }
}

class I18nModuleContext {
  /// The [I18nModuleContext] for [_I18nNoopModule].
  /// It can be used when calling `Localizations.of<I18nModuleContext>(context, I18nModuleContext)` returns null.
  static final I18nModuleContext noop = const I18nModuleContext(null, null);

  final Locale locale;
  final I18nResource resource;

  const I18nModuleContext(this.locale, this.resource);

  /// Instantiate [I18nModule] for [namespace]/[module] which is in [package].
  I18nModule module({String package, String namespace, String module}) {
    if (this.resource == null) {
      return I18nModule.noop;
    }

    final String trimmedPackage = trimToNull(package);
    final String trimmedNamespace = trimToNull(namespace) ?? default_namespace;
    final String trimmedModule = trimToNull(module) ?? default_module;

    final String ns = trimmedPackage != null ? 'packages/$trimmedPackage/$trimmedNamespace' : trimmedNamespace;

    return I18nModule(this, ns, trimmedModule);
  }
}
