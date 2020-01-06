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

import './i18n_const.dart';
import './i18n_utils.dart';
import './i18n_message.dart';
import './i18n_resource.dart';
import './i18n_resource_parser.dart';

final RegExp _regexUrlMatch = RegExp(r'^http(s)?://[^/\\]+');
final RegExp _regexHeadingOrTrailingSlashMatch = RegExp(r'^/+|/+$');
final RegExp _regexFileSuffixMatch = RegExp(r'\.[^.]+$');
final RegExp _regexDefaultPathEndingMatch = RegExp(r'/default$');
final RegExp _regexPackageNameInPathMatch = RegExp(r'^packages/([^/]+)/.+');
final RegExp _regexI18nYamlContentMatch = RegExp(r'^i18n:');

typedef LoadFn = Future<Map<String, String>> Function(Locale locale, String basePath, String manifestPath);
typedef ParseFn = Map<String, I18nMessages> Function(Locale locale, String namespace, String content);

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

    // Note: Only cache the resource when the resources are loaded successfully
    return loadResources(locale, root, manifest).then((resources) {
      final I18nResource resource = parseResources(locale, resources ?? {});

      if (this.cacheable) {
        _resourceCache[resourceKey] = resource;
      }

      return resource;
    }).catchError((e) => this.showError ? I18nErrorOccurredResource(null, e.toString()) : null);
  }

  Future<Map<String, String>> loadResources(Locale locale, String basePath, String manifestPath);

  I18nResource parseResources(Locale locale, Map<String, String> resources) {
    // Mapping: <'namespace/module', I18nMessage>
    final Map<String, I18nMessages> messagesMap = {};
    final List<I18nResource> errorOccurredResources = [];

    for (String namespace in resources.keys) {
      final String content = resources[namespace];

      try {
        messagesMap.addAll(parseResource(locale, namespace, content));
      } catch (e) {
        if (this.showError) {
          errorOccurredResources.add(I18nErrorOccurredResource(namespace, e.toString()));
        }
        //print(e);
      }
    }

    I18nResource resource = I18nResource(messagesMap);
    if (errorOccurredResources.isEmpty) {
      return resource;
    } else {
      return I18nCombinedResource([resource, ...errorOccurredResources]);
    }
  }

  Map<String, I18nMessages> parseResource(Locale locale, String namespace, String content) {
    final I18nResourceParser parser = I18nResourceParser(locale);

    return parser.parse(namespace, content);
  }
}

/// The user defined [I18nResourceLoader] to support to load i18n messages via [loader].load().
class I18nUserDefinedResourceLoader extends I18nResourceLoader {
  final I18nResourceLoaderSpec loader;

  I18nUserDefinedResourceLoader(this.loader)
      : assert(loader.load != null),
        super(cacheable: loader.cacheable, showError: loader.showError);

  @override
  Future<Map<String, String>> loadResources(Locale locale, String basePath, String manifestPath) {
    return this.loader.load(locale, basePath, manifestPath);
  }

  @override
  Map<String, I18nMessages> parseResource(Locale locale, String namespace, String content) {
    if (this.loader.parse == null) {
      return super.parseResource(locale, namespace, content);
    }

    return this.loader.parse(locale, namespace, content);
  }
}

/// The [I18nResourceLoader] for loading the i18n messages from the app's local or remote resources.
/// Whether loading from local or remote, dependent on if the [basePath] is a local file or a remote url.
class I18nNormalResourceLoader extends I18nUserDefinedResourceLoader {
  I18nNormalResourceLoader({bool cacheable, bool showError})
      : super(
          I18nResourceLoaderSpec(
            cacheable: cacheable,
            showError: showError,
            load: _loadLocalOrRemoteResourceFiles,
          ),
        );
}

/// The [I18nResourceLoader] for loading the i18n messages from the libraries' resources.
class I18nPackageResourceLoader extends I18nUserDefinedResourceLoader {
  I18nPackageResourceLoader({bool cacheable, bool showError})
      : super(
          I18nResourceLoaderSpec(
            cacheable: cacheable,
            showError: showError,
            load: (Locale locale, String basePath, String manifestPath) => _loadPackageResourceFiles(locale),
          ),
        );
}

///////////////// Loader Functions //////////////////

/// The [LoadFn] for loading the i18n messages from the app's local or remote resources.
Future<Map<String, String>> _loadLocalOrRemoteResourceFiles(Locale locale, String basePath, String manifestPath) async {
  LoadFn load;

  if (_regexUrlMatch.hasMatch(basePath)) {
    load = _loadRemoteResourceFiles;
  } else {
    load = _loadLocalResourceFiles;
  }

  return load(locale, basePath, manifestPath);
}

/// The [LoadFn] for loading the i18n messages from the app's local resources.
Future<Map<String, String>> _loadLocalResourceFiles(Locale locale, String basePath, String manifestPath) async {
  // https://stackoverflow.com/questions/56544200/flutter-how-to-get-a-list-of-names-of-all-images-in-assets-directory#answer-56555070
  // {..., "assets/i18n/default.yaml":["assets/i18n/default.yaml"], "assets/i18n/page.yaml":["assets/i18n/page.yaml"]}
  final List<String> resourcePaths = await _getResourcesIn(basePath);

  final Map<String, String> resources = {};

  for (String resourcePath in resourcePaths) {
    final String namespace = _determineResourceNamespace(basePath, resourcePath);

    final String yaml = await rootBundle.loadString(resourcePath);

    resources[namespace] = yaml;
  }

  return resources;
}

/// The [I18nResourceLoader] for loading the i18n messages from the app's remote resources.
Future<Map<String, String>> _loadRemoteResourceFiles(Locale locale, String basePath, String manifestPath) async {
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

/// The [LoadFn] for loading the i18n messages from the libraries' resources.
Future<Map<String, String>> _loadPackageResourceFiles(Locale locale) async {
  // {..., "packages/flutter_i18n/assets/i18n/default.yaml":["packages/flutter_i18n/assets/i18n/default.yaml"]}
  final List<String> resourcePaths = await _getResourcesIn('packages');

  final Map<String, String> resourceContentMap = {};
  final Map<String, List<String>> packageResourcePathsMap = {};

  for (String resourcePath in resourcePaths) {
    final String yaml = await rootBundle.loadString(resourcePath);
    if (!_regexI18nYamlContentMatch.hasMatch(yaml)) {
      continue;
    }

    final String packageName = _regexPackageNameInPathMatch.firstMatch(resourcePath).group(1);

    resourceContentMap[resourcePath] = yaml;
    packageResourcePathsMap.putIfAbsent(packageName, () => []).add(resourcePath);
  }

  final Map<String, String> resources = {};

  for (String packageName in packageResourcePathsMap.keys) {
    final List<String> packageResourcePaths = packageResourcePathsMap[packageName];
    final String packageResourceBasePath =
        packageResourcePaths.first.substring(0, packageResourcePaths.first.lastIndexOf('/'));

    for (String packageResourcePath in packageResourcePaths) {
      final String namespace =
          'packages/$packageName/' + _determineResourceNamespace(packageResourceBasePath, packageResourcePath);

      resources[namespace] = resourceContentMap[packageResourcePath];
    }
  }

  return resources;
}

Future<List<String>> _getResourcesIn(String basePath) async {
  final String manifestContent = await rootBundle.loadString(default_manifest_path);
  final Map<String, dynamic> manifestMap = json.decode(manifestContent);

  final List<String> resourcePaths = manifestMap.keys
      .where((String key) => key.startsWith('$basePath/') && (key.endsWith('.yaml') || key.endsWith('.yml')))
      .toList();

  resourcePaths.sort((r1, r2) => r1.split('/').length - r2.split('/').length);

  return resourcePaths;
}

String _determineResourceNamespace(String basePath, String resourcePath) {
  // Remove '/default' from subdirectory path
  return resourcePath
      .substring(basePath.length + 1)
      .replaceAll(_regexFileSuffixMatch, '')
      .replaceAll(_regexDefaultPathEndingMatch, '');
}
