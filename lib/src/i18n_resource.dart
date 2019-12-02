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

import 'package:yaml/yaml.dart';

class _I18nMessage {
  final String _defaultText;
  final String _annotation;
  final String _localeText;

  const _I18nMessage({String defaultText, String annotation, String localeText})
      : this._defaultText = defaultText,
        this._annotation = annotation,
        this._localeText = localeText;
}

class I18nMessage {
  final Map<String, _I18nMessage> _message;

  I18nMessage({Map<String, _I18nMessage> message}) : this._message = message;

  String parse(String defaultText, {dynamic args, String annotation}) {
    String messageKey = createKey(annotation, defaultText);

    String text = defaultText;
    if (this._message[messageKey] != null) {
      text = this._message[messageKey]._localeText ?? this._message[messageKey]._defaultText;
    }

    // TODO Parse text

    return text;
  }

  static String key(_I18nMessage message) {
    return createKey(message._annotation, message._defaultText);
  }

  static String createKey(String annotation, String defaultText) {
    return '${annotation ?? ""}:${defaultText ?? ""}';
  }
}

class I18nResource {
  final Map<String, Map<String, _I18nMessage>> _messages;

  I18nResource({Map<String, Map<String, _I18nMessage>> messages}) : this._messages = messages;

  I18nMessage get({String namespace, String module}) {
    String ns = '$namespace/$module';

    return I18nMessage(message: this._messages[ns] ?? {});
  }

  static Future<I18nResource> load(Locale locale, {@required String basePath, @required String manifestPath}) async {
    Map<String, String> resourceMap = {};

    if (RegExp(r'^http(s)?://[^/\\]+').hasMatch(basePath)) {
      resourceMap = await _loadRemoteResources(basePath, manifestPath);
    } else {
      resourceMap = await _loadLocalResources(basePath, manifestPath);
    }

    Map<String, Map<String, _I18nMessage>> messages = {};
    for (String namespace in resourceMap.keys) {
      String yaml = resourceMap[namespace];

      messages.addAll(_parseMessageYaml(locale, namespace, yaml));
    }

    return I18nResource(messages: messages);
  }
}

Future<Map<String, String>> _loadLocalResources(String basePath, String manifestPath) async {
  // https://stackoverflow.com/questions/56544200/flutter-how-to-get-a-list-of-names-of-all-images-in-assets-directory#answer-56555070
  // {..., {"assets/i18n/default.yaml":["assets/i18n/default.yaml"],"assets/i18n/page.yaml":["assets/i18n/page.yaml"]}
  final manifestContent = await rootBundle.loadString(manifestPath);
  final Map<String, dynamic> manifestMap = json.decode(manifestContent);

  final List<String> resourcePaths = manifestMap.keys.where((String key) => key.startsWith(basePath + '/')).toList();

  final Map<String, String> resources = {};

  for (String resourcePath in resourcePaths) {
    final String namespace = resourcePath.substring(basePath.length + 1).replaceAll(RegExp(r'\.[^.]+$'), '');
    final String yaml = await rootBundle.loadString(resourcePath);

    resources[namespace] = yaml;
  }

  return resources;
}

Future<Map<String, String>> _loadRemoteResources(String basePath, String manifestPath) async {
  // TODO 支持加载URL资源

  return {};
}

Map<String, Map<String, _I18nMessage>> _parseMessageYaml(Locale locale, String namespace, String yaml) {
  final i18nNode = (loadYaml(yaml) ?? {})['i18n'] ?? {};
  assert(i18nNode is Map,
      'The root node - i18n (in "$namespace.yaml") should be a map, but got "${i18nNode.runtimeType}".');

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

      String defaultText = '';
      String annotation = '';
      String localeText = '';
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
          messages[messageKey] == null, 'The following message was already defined in "$namespace":\n    $defaultText');

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
