API Document
======================================================================================

## I18n

### `static LocalizationsDelegate<I18nModuleContext> delegate({...})`

Create the `LocalizationsDelegate` for the app. The following is the full method signature:

```dart
static LocalizationsDelegate<I18nModuleContext> delegate({
  String basePath,
  String manifestPath,
  I18nResourceLoaderSpec loader,
  bool debug: false,
});
```

- `basePath`: **[String]** The base directory to put the i18n message resources.
  If you want to load resources from the local, the `basePath` should be
  the root of the i18n message [assets](https://flutter.dev/docs/development/ui/assets-and-images),
  if your i18n message resources should be loaded from the remote host,
  just set `basePath` as a URL link address. Default is `assets/i18n` which is a local assets path.
- `manifestPath`: **[String]** The path of manifest which specifies all of
  the i18n message resource paths. Default is `AssetManifest.json`.
  For the remote resources, the manifest's content should be an array json string
  which contains resource paths, e.g. `['a/b.yaml', 'c/d.yml', ...]`.
- `loader`: **[I18nResourceLoaderSpec]** The custom i18n resource loader and parser,
  and to specify if enable cache and error-shown.
  e.g. `loader: I18nResourceLoaderSpec(cacheable: false, showError: true)`.
- `debug`: **[bool]** Enable debug mode or not. If it's `true`, the cache will be disabled
  and the error will be shown. Default is `false`.

The returned `LocalizationsDelegate<I18nModuleContext>` will async load the specified resources
which were declared in `manifestPath` from the `basePath`, then create `I18nModuleContext`
to build the i18n context for modules.

Usually, you only need to call `I18n.delegate({...})` in the root widget as the following code:

```dart
@override
Widget build(BuildContext context) {
  return MaterialApp(
    localizationsDelegates: [
      I18n.delegate(debug: true),
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
    ],
  );
}
```

But, if you want to load other i18n message resources at runtime, you can call it like this:

```dart
Future<String> _fetchRemoteLocale(Locale locale, String text) async {
  return await I18n.delegate(
    basePath: 'https://raw.githubusercontent.com/flytreeleft/flutter_i18n/master/example/assets/i18n',
    manifestPath: 'example/remote/i18n.json',
    loader: const I18nResourceLoaderSpec(cacheable: false, showError: true),
  ).load(locale).then((ctx) => ctx.module(namespace: 'example/remote').lang(text));
}
```

### `static I18n build({String package, String namespace, dynamic module})`

To build a `I18n` instance (named as `_i18n`) for the current module, so that you can do
i18n translation with the inner variable `_i18n`, e.g. `_i18n.of(context).lang('Hello world!')`.

- `package`: **[String]** The package name of a Flutter library. If you want to use `flutter_i18n`
  in your Flutter library project, you need to specify the `package` as the library name
  in all modules. **Note**: If your library is in development, the `I18n` will load the i18n
  messages from the [Flutter assets](https://flutter.dev/docs/development/ui/assets-and-images),
  if your library is imported by other project, the i18n messages will be loaded from
  `packages/<library_name>/`, the `I18n` will automatically load all `*.yaml` or `*.yml` files
  which contain the top node `i18n:`.
- `namespace`: **[String]** The namespace of `module`. The filepath which is relative with `basePath`
  will be used as the part of `namespace` (excluding the suffix). If the file is named as
  `default.yaml` or `default.yml`, the namespace should omit the `default`, e.g. assumes that
  the i18n messages defined in `example/advance/default.yaml`, so the `namespace` will be started
  with `example/advance`, and if all i18n messages are stored in `${basePath}/default.yaml`,
  the parameter `namespace` can be ignored. **Note**: If in the YAML file, the `module` is the child
  of other node, the `namespace` should contains the parent node names and separates them with `/`
  from top to bottom.
- `module`: **[String]** A module name to organize the i18n messages. The `module` can be
  a string or a class. Usually, we regard a widget as a module, so `module` represents
  the widget class. Default is `_`, a underline which represents the default module.
  The default module in a `namespace` will be defined at the first location in the YAML file.

Give you an example. If you want to use `I18n` in the widget `Calculator` for the library
[flutter_calculator](https://github.com/flytreeleft/flutter_calculator) and its i18n messages were
defined in `assets/i18n/calculator.yaml` (which will be packaged in `packages/flutter_calculator/`),
you need to build `I18n` in the module `calculator.dart` like the following code:

```dart
final I18n _i18n = I18n.build(
  package: 'flutter_calculator',
  namespace: 'calculator',
  module: Calculator,
);
```

**Note**: The parameter `package` is just used in a Flutter library, for other Flutter project,
it should be omitted.

### `I18nModule of(BuildContext context)`

Get the `I18nModuleContext` which is bound to the current `BuildContext`, then build and return
`I18nModule` instance for the current module.

After you get the `I18nModule` instance, you can do translation where the text will be shown in:

```dart
@override
Widget build(BuildContext context) {
  return Column(
    children: <Widget>[
      Flexible(
        child: Text(
          _i18n.of(context).lang('This is a text which will translated for different locale.'),
        ),
      ),
    ],
  );
}
```

**Note**: Usually, the i18n messages will be cached, and `I18nModule` just provide a method to
get these messages based on the current locale, so you do not need to worry about your memory
or the performance.

### `Locale locale(BuildContext context)`

Get the locale which is related to the current `BuildContext`.

It will return `null` if `I18n.delegate(...)` isn't called, the `null` represents the system locale.

## I18nModuleContext

### `I18nModule module({String package, String namespace, String module})`

Build a [I18nModule](#I18nModule) instance for the specified `module` which is unified with `namespace`
in the `package` library.

Usually, the `I18nModule` instance should be created via calling `_i18n.of(context)`.
But, you should call it when you use `I18n.delegate(...).load(locale)` directly:

```dart
Future<String> _fetchRemoteLocale(Locale locale, String text) async {
  return await I18n.delegate(
    basePath: 'https://raw.githubusercontent.com/flytreeleft/flutter_i18n/master/example/assets/i18n',
    manifestPath: 'example/remote/i18n.json',
    loader: const I18nResourceLoaderSpec(cacheable: false, showError: true),
  )
  .load(locale)
  .then((I18nModuleContext ctx) => ctx.module(namespace: 'example/remote')
  .lang(text));
}
```

## I18nModule

### `String lang(String text, {dynamic args, String annotation, locale})`

Translate the `text` to the current locale or the specified `locale`,
and it will do [Mustache](https://mustache.github.io) template parsing when the `text`
contains Mustache syntax.

- `text`: **[String]** The i18n message text. If no specified translated message for the locale,
  `#lang(...)` will just return the `text` self.
- `args`: **[List|Map|Object]** The data which will be injected to
  the [Mustache](https://mustache.github.io) template.
- `locale`: **[String|Locale]** The locale code or object which the `text` will be translated to.
  If not specified it, the `text` will be translated to the current locale.
- `annotation`: **[String]** An annotation for distinguishing the same `text` which should
  be translated to different locale content in one module.

Here are some usage examples:

```dart
String msg = _i18n.of(context).lang('This is a text');

String msg = _i18n.of(context).lang(
  'My name is {{ name.en }}.',
  args: { 'name': {'en': 'Lily', 'zh': '莉莉'} },
);

String msg = _i18n.of(context).lang('This is a text', locale: 'zh_Hans');

String msg = _i18n.of(context).lang('This is a text', annotation: 'another-meaning');
```

## I18nResourceLoaderSpec

A plain model for specify the user-defined i18n message resource loader and parser.

You can define your loading and parsing way to meet your needs.

The following is its declaration:

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

You can set `cacheable` to `false` to disable the i18n messages cache.

Also you can set `showError` to `true` to the loading or parsing error,
so that calling `I18nModule#lang(...)` will return the error always.
