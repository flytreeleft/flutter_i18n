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
import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'package:http/http.dart' as http;
import 'package:reflected_mustache/mustache.dart';

import 'package:yaml/yaml.dart';

final RegExp _regexTemplateMatch = RegExp(r'\{\{[^\{\}]+\}\}', multiLine: true);
final RegExp _regexUrlMatch = RegExp(r'^http(s)?://[^/\\]+');
final RegExp _regexFileSuffixMatch = RegExp(r'\.[^.]+$');
final RegExp _regexDefaultPathEndingMatch = RegExp(r'/default$');

class _I18nMessage {
  final String _defaultText;
  final String _annotation;
  final String _localeText;

  const _I18nMessage({String defaultText, String annotation, String localeText})
      : this._defaultText = defaultText,
        this._annotation = annotation,
        this._localeText = localeText == '' ? null : localeText;
}

class I18nMessage {
  final String _error;
  final Map<String, _I18nMessage> _message;

  I18nMessage({Map<String, _I18nMessage> message, String error})
      : this._message = message,
        this._error = error;

  String parse(String defaultText, {dynamic args, String annotation}) {
    if (this._error != null && this._error != '') {
      return this._error;
    }

    String messageKey = createKey(annotation, defaultText);

    String text = defaultText;
    if (this._message[messageKey] != null) {
      text = this._message[messageKey]._localeText ?? this._message[messageKey]._defaultText;
    }

    if (!text.contains(_regexTemplateMatch)) {
      return text;
    }

    Template template = Template(text);

    return template.renderString(args ?? {});
  }

  static String key(_I18nMessage message) {
    return createKey(message._annotation, message._defaultText);
  }

  static String createKey(String annotation, String defaultText) {
    return '${annotation ?? ""}:${defaultText ?? ""}';
  }
}

class I18nResource {
  final String _error;
  final Map<String, Map<String, _I18nMessage>> _messages;

  I18nResource({Map<String, Map<String, _I18nMessage>> messages, String error})
      : this._messages = messages,
        this._error = error;

  I18nMessage get({String namespace, String module}) {
    String ns = '$namespace/$module';

    return I18nMessage(message: this._messages[ns] ?? {}, error: this._error);
  }

  static Future<I18nResource> load(Locale locale, {@required String basePath, @required String manifestPath}) async {
    Map<String, String> resourceMap = {};

    String error;
    try {
      if (_regexUrlMatch.hasMatch(basePath)) {
        // TODO cache into local when loading successfully, otherwise, load the existing resources from the cache.
        resourceMap = await _loadRemoteResources(basePath, manifestPath);
      } else {
        resourceMap = await _loadLocalResources(basePath, manifestPath);
      }
    } catch (e) {
      error = e.toString();
    }

    Map<String, Map<String, _I18nMessage>> messages = {};
    for (String namespace in resourceMap.keys) {
      String yaml = resourceMap[namespace];

      messages.addAll(_parseMessageYaml(locale, namespace, yaml));
    }

    return I18nResource(messages: messages, error: error);
  }
}

Future<Map<String, String>> _loadLocalResources(String basePath, String manifestPath) async {
  // https://stackoverflow.com/questions/56544200/flutter-how-to-get-a-list-of-names-of-all-images-in-assets-directory#answer-56555070
  // {..., {"assets/i18n/default.yaml":["assets/i18n/default.yaml"],"assets/i18n/page.yaml":["assets/i18n/page.yaml"]}
  final manifestContent = await rootBundle.loadString(manifestPath);
  final Map<String, dynamic> manifestMap = json.decode(manifestContent);

  final List<String> resourcePaths =
      manifestMap.keys.where((String key) => key.startsWith(basePath + '/') && key.endsWith('.yaml')).toList();

  final Map<String, String> resources = {};

  for (String resourcePath in resourcePaths) {
    // Remove '/default' from subdirectory path
    final String namespace = resourcePath
        .substring(basePath.length + 1)
        .replaceAll(_regexFileSuffixMatch, '')
        .replaceAll(_regexDefaultPathEndingMatch, '');

    final String yaml = await rootBundle.loadString(resourcePath);

    resources[namespace] = yaml;
  }

  return resources;
}

Future<Map<String, String>> _loadRemoteResources(String basePath, String manifestPath) async {
  final String manifestUrl = '$basePath/$manifestPath';
  final String manifestContent = await http.get(manifestUrl).then((response) => response.body);
  final List<dynamic> resourcePaths = json.decode(manifestContent);

  final Map<String, String> resources = {};

  for (String resourcePath in resourcePaths) {
    // Remove '/default' from subdirectory path
    final String namespace =
        resourcePath.replaceAll(_regexFileSuffixMatch, '').replaceAll(_regexDefaultPathEndingMatch, '');

    final String resourceUrl = '$basePath/$resourcePath';
    final String yaml = await http.get(resourceUrl).then((response) => response.body);

    resources[namespace] = yaml;
  }

  return resources;
}

Map<String, Map<String, _I18nMessage>> _parseMessageYaml(Locale locale, String namespace, String yaml) {
  final i18nNode = (loadYaml(yaml) ?? {})['i18n'] ?? {};
  assert(
    i18nNode is Map,
    'The root node - i18n (in "$namespace.yaml") should be a map, but got "${i18nNode.runtimeType}".',
  );

  final List<String> matchingLocales = _parseLocalCodes(locale);

  return _parseMessageModule(matchingLocales, namespace, i18nNode);
}

Map<String, Map<String, _I18nMessage>> _parseMessageModule(List<String> localeCodes, String namespace, messageNodes) {
  if (messageNodes is Map) {
    Map<String, Map<String, _I18nMessage>> nsMessages = {};

    for (String module in messageNodes.keys) {
      String ns = '$namespace/$module';

      nsMessages.addAll(_parseMessageModule(localeCodes, ns, messageNodes[module]));
    }

    return nsMessages;
  } else if (messageNodes != null) {
    assert(messageNodes is List, 'The node $namespace should be a list, but got "${messageNodes.runtimeType}"');

    Map<String, _I18nMessage> messages = {};

    for (var messageNode in messageNodes) {
      assert(messageNode is Map, 'The message node should be a map, but got "$messageNode"');

      String localeText;
      String defaultText = '';
      String annotation = '';
      for (String messageNodeKey in messageNode.keys) {
        String text = (messageNode[messageNodeKey] ?? '').trim();

        if ('_' == messageNodeKey) {
          defaultText = text;
        } else if ('annotation' == messageNodeKey) {
          annotation = text;
        } else if (localeCodes.contains(messageNodeKey)) {
          localeText = text;
        } else {
          // Unknown message node key
        }
      }

      assert(defaultText != '', 'No default text was specified in "$messageNode"');

      _I18nMessage message = _I18nMessage(defaultText: defaultText, annotation: annotation, localeText: localeText);
      String messageKey = I18nMessage.key(message);

      assert(
        messages[messageKey] == null,
        'The following message was already defined in "$namespace":\n    $defaultText',
      );

      messages[messageKey] = message;
    }

    return {namespace: messages};
  }

  return {};
}

List<String> _parseLocalCodes(Locale locale) {
  List<String> codes = [locale.languageCode];

  if (locale.countryCode != null) {
    codes.addAll([locale.languageCode + '_' + locale.countryCode, locale.languageCode + '-' + locale.countryCode]);
  }

  if (locale.scriptCode != null) {
    codes.addAll([locale.languageCode + '_' + locale.scriptCode, locale.languageCode + '-' + locale.scriptCode]);
  }

  if (locale.countryCode != null && locale.scriptCode != null) {
    codes.addAll([
      locale.languageCode + '_' + locale.scriptCode + '_' + locale.countryCode,
      locale.languageCode + '-' + locale.scriptCode + '-' + locale.countryCode
    ]);
  }

  return codes;
}
