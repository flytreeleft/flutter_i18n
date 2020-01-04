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

import './i18n_message.dart';

class I18nResource {
  /// The [I18nMessages] which is associated with the [I18nModule] whose
  /// key is concatenated with [namespace] and [module].
  final Map<String, I18nMessages> _messagesMap;

  I18nResource(Map<String, I18nMessages> messagesMap) : this._messagesMap = messagesMap ?? {};

  /// Return [null] when no matched module was associated.
  I18nMessages get(String namespace, String module) {
    final String ns = '$namespace/$module';

    if (this._messagesMap.containsKey(ns)) {
      return this._messagesMap[ns];
    }
    return null;
  }
}

/// A [I18nResource] which occurs some error.
/// It will always return the [error] content when calling [I18nMessage].parse().
class I18nErrorOccurredResource extends I18nResource {
  final String _namespace;
  final String _error;

  I18nErrorOccurredResource(this._namespace, this._error) : super(null);

  @override
  I18nMessages get(String namespace, String module) {
    if (this._namespace == null || namespace == this._namespace || namespace.startsWith(this._namespace + '/')) {
      return _I18nErrorOccurredMessages(this._error);
    }
    return null;
  }
}

/// A [I18nResource] which combined multiple [I18nResource]s.
class I18nCombinedResource extends I18nResource {
  final List<I18nResource> _resources;

  I18nCombinedResource(List<I18nResource> resources)
      : this._resources = resources,
        super(null);

  /// Return [null] when no matched module was associated.
  @override
  I18nMessages get(String namespace, String module) {
    I18nMessages ret;

    for (I18nResource resource in this._resources) {
      if (resource == null) {
        continue;
      }

      final I18nMessages messages = resource.get(namespace, module);
      if (messages is _I18nErrorOccurredMessages) {
        // Just match the first error occurred messages.
        if (ret == null) {
          ret = messages;
        }
        continue;
      }

      if (messages != null) {
        return messages;
      }
    }

    return ret;
  }
}

class _I18nErrorOccurredMessages extends I18nMessages {
  final String _error;

  _I18nErrorOccurredMessages(this._error) : super(null);

  /// Get [I18nMessage] which will always return the [_error] content when calling [I18nMessage].parse().
  @override
  I18nMessage get(String defaultText, {String annotation}) {
    return I18nMessage(this._error, null, null, disableParser: true);
  }
}
