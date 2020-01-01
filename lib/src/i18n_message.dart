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

import 'package:reflected_mustache/mustache.dart';

import './i18n_utils.dart';

final RegExp _regexTemplateMatch = RegExp(r'\{\{[^\{\}]+\}\}', multiLine: true);

class I18nMessage {
  final String defaultText;
  final String annotation;
  final Map<String, String> _localeTextMap;
  final bool _disableParser;

  I18nMessage(this.defaultText, this.annotation, Map<String, String> localeTextMap, {bool disableParser: false})
      : this._localeTextMap = localeTextMap ?? {},
        this._disableParser = disableParser;

  String parse(List<String> localeCodes, {dynamic args}) {
    String text = this.defaultText;

    if (this._localeTextMap.isNotEmpty && localeCodes.isNotEmpty) {
      for (String localeCode in (localeCodes ?? [])) {
        if (this._localeTextMap.containsKey(localeCode)) {
          text = this._localeTextMap[localeCode];
          break;
        }
      }
    }

    if (this._disableParser || !text.contains(_regexTemplateMatch)) {
      return text;
    }

    Template template = Template(text);

    return template.renderString(args ?? {});
  }
}

class I18nMessages {
  static final I18nMessages empty = I18nMessages(null);

  final Map<String, I18nMessage> _messageMap;

  I18nMessages(Map<String, I18nMessage> messageMap) : this._messageMap = messageMap ?? {};

  /// Get [I18nMessage] which is associated with the [defaultText] and [annotation].
  I18nMessage get(String defaultText, {String annotation}) {
    if (this._messageMap.isEmpty) {
      return I18nMessage(defaultText, annotation, null);
    }

    final String msgKey = createMsgKey(defaultText, annotation);

    return this._messageMap.putIfAbsent(msgKey, () => I18nMessage(defaultText, annotation, null));
  }

  static String msgKey(I18nMessage msg) {
    return createMsgKey(msg.defaultText, msg.annotation);
  }

  static String createMsgKey(String defaultText, String annotation) {
    return '${trimToNull(annotation) ?? "_"}:${defaultText ?? ""}';
  }
}
