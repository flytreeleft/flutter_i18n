Getting Started
==============================================================

## Import Dependency

- Add dependency to your `pubspec.yaml`:

```yaml
dependencies:
  flutter_i18n:
    git:
      url: git://github.com/flytreeleft/flutter_i18n.git
      ref: master
```

- Import `flutter_i18n` and create an inner global `I18n` instance in your widget dart file:

```dart
import 'package:flutter_i18n/flutter_i18n.dart';

// Create the i18n for the default module which is in the default package.
final I18n _i18n = I18n.build();
```

- Use `_i18n` anywhere you can get `BuildContext` directly or indirectly:

```dart
// ...
  @override
  Widget build(BuildContext context) {
    final title = _i18n.of(context).lang('Flutter I18n Example');

    return /*...*/;
  }
// ...
```

## Enable Localization

Actually, that's all you need to have to do. That means there is no need to define or
specify the i18n message resources. Your app will work well and it will show the text
which is used as the first parameter of `i18n.lang(...)`.

If you want to support another language for facing other country's people.
Just put your i18n message resource files into the directory `assets/i18n/`
(which is called the `basePath` to load i18n resource files) in your app project
and declare the i18n message [assets](https://flutter.dev/docs/development/ui/assets-and-images)
in your `pubspec.yaml`:

```yaml
# ...
flutter:
  # ...
  assets:
    - assets/i18n/default.yaml
    - assets/i18n/page.yaml
    # Or just specify the i18n directory (needs to end with `/`)
    #- assets/i18n/
```

Then, initialize the localization delegate for `I18n` in the root widget `MaterialApp`:

```dart
import 'package:flutter_localizations/flutter_localizations.dart';

// ...
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      locale: const Locale('en'),
      supportedLocales: [
        // https://en.wikipedia.org/wiki/Language_localisation#Language_tags_and_codes
        const Locale('en'),
        const Locale.fromSubtags(languageCode: 'zh'),
        const Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hant'),
      ],
      localizationsDelegates: [
        I18n.delegate(),
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      home: HomePage(),
    );
  }
// ...
```

## Prepare i18n message

The default i18n message resource file should be named as `default.yaml`,
and define i18n message as following:

```yaml
i18n:
  # The underline means the default module or default locale code
  _:
    - _: Flutter I18n Example
      en_US: Flutter I18n Example (US)
      en_GB: Flutter I18n Example (GB)
      zh: Flutter I18n功能演示
      zh_Hans: Flutter I18n功能演示 (中文简体)
      zh_Hant: Flutter I18n功能演示 (中文繁體)
```

And if you want to organize your i18n message resources in different directories or files,
just create some subdirectories or another YAML files in the `basePath`.

For example, if you created a YAML file `${basePath}/page/home.yaml`, and its content is:

```yaml
i18n:
  HomePage:
    - _: Change Language
      zh: 切换语言
    - _: This is a text
      zh: 这是一段文本
```

And you just need to specify the `namespace` and `module` name when creating the `I18n` instance:

```dart
// Note: 'HomePage' is a widget class name.
final I18n _i18n = I18n.build(module: HomePage, namespace: 'page/home');
```

**Note**:
- The parameter `module` can be a `String` or a class name.
- A full `namespace` should contain the subdirectory path and the resource file name,
  if the resource file is named as `default.yaml`, the `namespace` should not contain
  the resource file name any more.

## Structure of i18n messages
