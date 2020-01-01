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
import 'dart:convert';

import 'package:flutter/services.dart';

import 'package:http/http.dart' as http;

import './i18n_utils.dart';
import './i18n_message.dart';
import './i18n_resource.dart';
import './i18n_resource_parser.dart';

final RegExp _regexUrlMatch = RegExp(r'^http(s)?://[^/\\]+');
final RegExp _regexHeadingOrTrailingSlashMatch = RegExp(r'^/+|/+$');
final RegExp _regexFileSuffixMatch = RegExp(r'\.[^.]+$');
final RegExp _regexDefaultPathEndingMatch = RegExp(r'/default$');

typedef LoadFn = Future<Map<String, String>> Function(Locale locale, String basePath, String manifestPath);
typedef ParseFn = I18nResource Function(Locale locale, Map<String, String> resourceFiles);

class I18nResourceLoaderSpec {
  final bool cacheable;
  final bool showError;
  final LoadFn load;
  final ParseFn parse;

  const I18nResourceLoaderSpec({this.cacheable: false, this.showError: false, this.load, this.parse});
}

abstract class I18nResourceLoader {
  static final Map<String, I18nResource> _resourceCache = {};

  final bool cacheable;
  final bool showError;

  const I18nResourceLoader({this.cacheable: false, this.showError: false});

  Future<I18nResource> load(Locale locale, String basePath, String manifestPath) {
    final String root = trimToEmpty(basePath?.replaceAll(_regexHeadingOrTrailingSlashMatch, '')) ?? '';
    final String manifest = trimToEmpty(manifestPath?.replaceAll(_regexHeadingOrTrailingSlashMatch, '')) ?? '';

    assert(root != '', "'$basePath' isn't a valid file or url path.");
    assert(manifest != '', "$manifestPath isn't a valid manifest file path.");

    final String resourceKey = '${this.runtimeType}/$root/$manifest';

    if (this.cacheable && _resourceCache.containsKey(resourceKey)) {
      return Future.sync(() => _resourceCache[resourceKey]);
    }

    // Note: Only cache the resource when the resource files are loaded successfully
    return loadResourceFiles(locale, root, manifest).then((files) {
      I18nResource resource = parseResourceFiles(locale, files ?? {});

      if (this.cacheable) {
        _resourceCache[resourceKey] = resource;
      }

      return resource;
    }).catchError((e) => this.showError ? I18nErrorOccurredResource(e.toString()) : null);
  }

  Future<Map<String, String>> loadResourceFiles(Locale locale, String basePath, String manifestPath);

  I18nResource parseResourceFiles(Locale locale, Map<String, String> resourceFiles) {
    final I18nResourceParser parser = I18nResourceParser(locale);

    // Mapping: <'namespace/module', I18nMessage>
    final Map<String, I18nMessages> messagesMap = {};

    for (String namespace in resourceFiles.keys) {
      String yaml = resourceFiles[namespace];

      messagesMap.addAll(parser.parse(namespace, yaml));
    }

    return I18nResource(messagesMap);
  }
}

/// The user defined [I18nResourceLoader] to support to load i18n messages via [loader].load().
class I18nUserDefinedResourceLoader extends I18nResourceLoader {
  final I18nResourceLoaderSpec loader;

  I18nUserDefinedResourceLoader(this.loader)
      : assert(loader.load != null),
        super(cacheable: loader.cacheable, showError: loader.showError);

  @override
  Future<Map<String, String>> loadResourceFiles(Locale locale, String basePath, String manifestPath) {
    return this.loader.load(locale, basePath, manifestPath);
  }

  @override
  I18nResource parseResourceFiles(Locale locale, Map<String, String> resourceFiles) {
    if (this.loader.parse == null) {
      return super.parseResourceFiles(locale, resourceFiles);
    }
    return this.loader.parse(locale, resourceFiles);
  }
}

/// The [I18nResourceLoader] for loading the i18n messages from the app's local or remote resources.
/// Whether loading from local or remote, dependent on if the [basePath] is a local file or a remote url.
class I18nLocalOrRemoteResourceLoader extends I18nResourceLoader {
  const I18nLocalOrRemoteResourceLoader({bool cacheable, bool showError})
      : super(cacheable: cacheable, showError: showError);

  @override
  Future<Map<String, String>> loadResourceFiles(Locale locale, String basePath, String manifestPath) {
    I18nResourceLoader loader;

    if (_regexUrlMatch.hasMatch(basePath)) {
      loader = I18nRemoteResourceLoader(cacheable: this.cacheable, showError: this.showError);
    } else {
      loader = I18nLocalResourceLoader(cacheable: this.cacheable, showError: this.showError);
    }

    return loader.loadResourceFiles(locale, basePath, manifestPath);
  }
}

/// The [I18nResourceLoader] for loading the i18n messages from the app's local resources.
class I18nLocalResourceLoader extends I18nResourceLoader {
  const I18nLocalResourceLoader({bool cacheable, bool showError}) : super(cacheable: cacheable, showError: showError);

  @override
  Future<Map<String, String>> loadResourceFiles(Locale locale, String basePath, String manifestPath) async {
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
}

/// The [I18nResourceLoader] for loading the i18n messages from the app's remote resources.
class I18nRemoteResourceLoader extends I18nResourceLoader {
  const I18nRemoteResourceLoader({bool cacheable, bool showError}) : super(cacheable: cacheable, showError: showError);

  @override
  Future<Map<String, String>> loadResourceFiles(Locale locale, String basePath, String manifestPath) async {
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
}

/// The [I18nResourceLoader] for loading the i18n messages from the libraries' resources.
class I18nPackageResourceLoader extends I18nLocalResourceLoader {
  final String probePath;

  const I18nPackageResourceLoader({bool cacheable, bool showError, this.probePath})
      : super(cacheable: cacheable, showError: showError);

  @override
  Future<Map<String, String>> loadResourceFiles(Locale locale, String basePath, String manifestPath) async {
    // TODO Ignore basePath and manifestPath
    // TODO Add 'packages/xxx/' as namespace's prefix
    return {};
  }
}
