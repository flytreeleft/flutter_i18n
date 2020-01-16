Getting Started
==============================================================

## Import Dependency

Add the following configuration to your `pubspec.yaml`:

```yaml
dependencies:
  flutter_i18n:
    git:
      url: git://github.com/flytreeleft/flutter_i18n.git
      ref: master
```

Also, you can set `ref` to a stable git tag.

## Build I18n for module

Import `flutter_i18n` and create an inner global `I18n` instance `_i18n` for a module
(usually is a widget dart file):

```dart
import 'package:flutter_i18n/flutter_i18n.dart';

final I18n _i18n = I18n.build();
```

## Wrap Text with `.lang(...)`

Use `_i18n` anywhere you can get `BuildContext` directly or indirectly to translate
the specified text:

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

All that you have to do is as above. Using `I18n` will have no any affects to your app.
It will just return the original text as you passed.

But, if you want to make sure your app's text can be translated to different locale message.
You should specify `LocalizationsDelegate<I18nModuleContext>` (built via `I18n.delegate()`)
in your app's root widget (e.g. `MaterialApp`):

```dart
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_i18n/flutter_i18n.dart';

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
        I18n.delegate(), // -> LocalizationsDelegate<I18nModuleContext>
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      home: HomePage(),
    );
  }
// ...
```

## Prepare i18n messages

Furthermore, you need to do translation for the text which is appeared in your app.

First, with an example, create a YAML file in your project's root directory,
such as `assets/i18n/default.yaml` which means we put our message resources into
the default `basePath` directory - `assets/i18n`, and organize the module messages
in the `default` namespace.

Then, you need to declare the i18n message resources as the flutter
[assets](https://flutter.dev/docs/development/ui/assets-and-images) in your `pubspec.yaml`:

```yaml
# ...
flutter:
  # ...
  assets:
    - assets/i18n/default.yaml
    # Or just specify the i18n directory (needs to end with `/`)
    # and the subdirectory should be specified individually, e.g. `assets/i18n/demo/`
    #- assets/i18n/
```

And, you should put your translations to `assets/i18n/default.yaml` like:

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

Congratulations, the translations will be worked when your app is running in different locale.

## Furthermore

- Read the [message resources](./message-resources.md) to know how to organize
  the i18n message resources and your translations.
- Read the [cases](./cases.md) to be familiar with the different situation quickly.
- Read the [api](./api.md) to learn the details and advance usages of the APIs.
