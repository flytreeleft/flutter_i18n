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

import 'package:yaml/yaml.dart';

import './i18n_message.dart';
import './i18n_utils.dart';

final RegExp _regexBlankCharsMatch = RegExp(r'\s+');

class I18nResourceParser {
  final Locale locale;

  I18nResourceParser(this.locale);

  Map<String, I18nMessages> parse(String namespace, String yaml) {
    final i18nNode = (loadYaml(yaml) ?? {})['i18n'] ?? {};
    assert(
      i18nNode is Map,
      'The root node - i18n (in "$namespace.yaml") should be a map, but got "${i18nNode.runtimeType}".',
    );

    return parseNode(namespace, i18nNode);
  }

  Map<String, I18nMessages> parseNode(String namespace, node) {
    if (node is Map) {
      // Mapping: <'namespace/module', I18nMessage>
      Map<String, I18nMessages> messagesMap = {};

      for (String module in node.keys) {
        String ns = '$namespace/$module';

        messagesMap.addAll(parseNode(ns, node[module]));
      }

      return messagesMap;
    } else if (node is List) {
      I18nMessages messages = parseMessageNodes(namespace, node);

      return {namespace: messages};
    } else if (node != null) {
      throw 'The node "${toMapPath(namespace, [])}" should be a list, but got "${node.runtimeType}"';
    }

    return {};
  }

  I18nMessages parseMessageNodes(String namespace, List nodes) {
    // Mapping: <msgKey, I18nMessage>
    Map<String, I18nMessage> messageMap = {};

    for (int i = 0; i < nodes.length; i++) {
      final childNode = nodes[i];

      if (childNode == null) {
        continue;
      } else if (!(childNode is Map)) {
        throw 'The node "${toMapPath(namespace, [i])}" should be a map, but got "${childNode.runtimeType}"';
      }

      final Map messageNode = childNode as Map;
      final I18nMessage message = parseMessageNode(i, namespace, messageNode);

      final String msgKey = I18nMessages.msgKey(message);

      assert(
        !messageMap.containsKey(msgKey),
        'The following message was already defined in "$namespace":\n    ${message.defaultText}',
      );

      messageMap[msgKey] = message;
    }

    return I18nMessages(messageMap);
  }

  I18nMessage parseMessageNode(int index, String namespace, Map messageNode) {
    // Mapping: <localeCode, localeText>
    final Map<String, String> localeTextMap = {};

    String defaultText = '';
    String annotation;

    for (var key in messageNode.keys) {
      final msg = messageNode[key];

      if (!(msg is String)) {
        throw 'The node "${toMapPath(namespace, [index, key])}" should be a String, but got "${msg.runtimeType}"';
      }

      if (key == '_') {
        defaultText = msg;
      } else if (key == 'annotation') {
        annotation = trimToNull(msg)?.replaceAll(_regexBlankCharsMatch, '_');
      } else {
        localeTextMap[key] = msg;
      }
    }

    if (defaultText == '') {
      throw 'No default text was specified in "${toMapPath(namespace, [index])}"';
    }

    return I18nMessage(defaultText, annotation, localeTextMap);
  }
}

String toMapPath(String namespace, List<dynamic> sub) {
  return namespace + '.' + (sub ?? []).join('.');
}
