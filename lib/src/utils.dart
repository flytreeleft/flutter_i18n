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

import 'package:yaml/yaml.dart';

List<String> _parseLocalCodes(Locale locale) {
  return [
    locale.languageCode,
    locale.languageCode + '_' + locale.countryCode,
    locale.languageCode + '-' + locale.countryCode,
    locale.languageCode + '_' + locale.scriptCode + '_' + locale.countryCode,
    locale.languageCode + '-' + locale.scriptCode + '-' + locale.countryCode,
  ];
}

Map<String, Map> _parseI18nYaml(String yaml, String topNamespace, Locale locale) {
  final mapping = (loadYaml(yaml) ?? {})['i18n'] ?? {};
  final List<String> matchingLocales = _parseLocalCodes(locale);

  final Map<String, Map> i18nMap = {};
  for (String module in mapping.keys) {
    String namespace = topNamespace + '/' + module;
    Map<String, Map> messageMap = {};

    for (Map message in mapping[module]) {
      String defaultText = '';
      Map<Locale, String> langTextMap = {};

      for (String lang in message.keys) {
        String text = message[lang];

        if ('_' == lang) {
          defaultText = text;
        } else if (matchingLocales.contains(lang)) {
          langTextMap[locale] = text;
          break;
        }
      }

      messageMap[defaultText] = langTextMap;
    }

    i18nMap[namespace] = messageMap;
  }

  return i18nMap;
}

Future<Map<String, Map>> loadI18nResources(Locale locale, String manifestPath, String basePath) async {
  // https://stackoverflow.com/questions/56544200/flutter-how-to-get-a-list-of-names-of-all-images-in-assets-directory#answer-56555070
  // {..., {"assets/i18n/default.yaml":["assets/i18n/default.yaml"],"assets/i18n/page.yaml":["assets/i18n/page.yaml"]}
  final manifestContent = await rootBundle.loadString(manifestPath);
  final Map<String, dynamic> manifestMap = json.decode(manifestContent);
  final List<String> resourcePaths = manifestMap.keys.where((String key) => key.startsWith(basePath + '/')).toList();

  final Map<String, Map> resources = {};
  for (String path in resourcePaths) {
    final String namespace = path.substring(basePath.length + 1).replaceAll(RegExp(r'\.[^.]+$'), '');
    final String yaml = await rootBundle.loadString(path);

    resources.addAll(_parseI18nYaml(yaml, namespace, locale));
  }

  print(json.encode(resources));

  return resources;
}
