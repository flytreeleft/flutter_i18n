API Document
======================================================================================

## I18n

### `static LocalizationsDelegate<I18nModuleContext> delegate({...})`

```dart
static LocalizationsDelegate<I18nModuleContext> delegate({
  String basePath,
  String manifestPath,
  I18nResourceLoaderSpec loader,
  bool debug: false,
});
```

Create the `LocalizationsDelegate` for the app.

- `basePath`: [String] The base directory to put the i18n message resources.
  If you want to load resources from the local, the `basePath` should be
  the root of the i18n message [assets](https://flutter.dev/docs/development/ui/assets-and-images),
  if your i18n message resources should be loaded from the remote host,
  just set `basePath` as a URL link address. Default is `assets/i18n` which is a local assets path.
- `manifestPath`: [String] The path of manifest which specifies all of
  the i18n message resource paths. Default is `AssetManifest.json`.
  For the remote resources, the manifest's content should be an array json string
  which contains resource paths, e.g. `['a/b.yaml', 'c/d.yml', ...]`.
- `loader`: [I18nResourceLoaderSpec] .

### `static I18n build({String package, String namespace, dynamic module})`

Create a `I18n` instance to load and translate the messages which are defined in
`${basePath}/${namespace}/default.yaml` or `${basePath}/${namespace}.yaml` for the `module`.

- `package`: [String] The package name of a Flutter library. If you want to use `flutter_i18n`
  in your Flutter library project, you need to specify the `package` as your library name.
  **Note**: if your library is in debug, the `I18n` will load the i18n messages from the `basePath`,
  if your library is imported by other project, it will load i18n messages from
  `packages/<library_name>/${basePath}`.
- `namespace`: [String] The YAML filepath where the i18n messages are defined in.
  Default is `default` which means the i18n messages are defined in the `${basePath}/default.yaml`.
- `module`: [String] A module name or a class name to distinguish the i18n messages
  between the different widgets. Default is `_` (a underline which represents the default module).

For example, if you want to use `I18n` in the widget `Calculator` for the library
[flutter_calculator](https://github.com/flytreeleft/flutter_calculator)
and define its i18n messages in `assets/i18n/main/calculator.yaml`, you need to create `I18n` like:

```dart
final I18n _i18n = I18n.build(
  package: 'flutter_calculator',
  module: Calculator,
  namespace: 'main/calculator',
);
```

### `I18nModule of(BuildContext context)`

### `Locale locale(BuildContext context)`

## I18nModuleContext

### `I18nModule module({String package, String namespace, String module})`

## I18nModule

### `String lang(String text, {dynamic args, String annotation, locale})`

Load `I18n` instance from `BuildContext` and translate the `text`:

```dart
String msg = _i18n.of(context).lang('This is a text');
```

- `text`: [String] The i18n message content, if no specified translated message, `#lang(...)`
  will return the `text` self.
- `args`: [List|Map|Object] The data which will be injected to the message template
  (using [mustache](https://mustache.github.io)).
- `lang`: [String|Locale] The language which the text will be translated to. If not specified this,
  the `text` will be translated to the app's locale language.

## I18nResourceLoaderSpec

```dart
typedef LoadFn = Future<Map<String, String>> Function(Locale locale, String basePath, String manifestPath);

typedef ParseFn = Map<String, I18nMessages> Function(Locale locale, String namespace, String content);

class I18nResourceLoaderSpec {
  final bool cacheable;
  final bool showError;
  final LoadFn load;
  final ParseFn parse;
}
```
