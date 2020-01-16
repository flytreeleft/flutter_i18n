Usage Cases
===================================================
<!-- 放上代码截图与本地化效果截图 -->

> Here, we assume that the i18n message resources are putted into the directory `assets/i18n/`
> of your app project and use it as the `basePath` where the i18n message resources are
> loading from.

## Basic

```yaml
# Translations in the file `assets/i18n/default.yaml`
i18n:
  # `_` represents a module name, it can be omitted when calling `I18n.build(...)`
  _:
    - _: This is a text
      zh: 这是一段文本
      zh_Hant: 這是一段文本
```

```dart
// Equals with `final I18n _i18n = I18n.build(namespace: 'default', module: '_')`
final I18n _i18n = I18n.build();

// ...
  @override
  Widget build(BuildContext context) {
    // For English locale
    assert(_i18n.of(context).lang('This is a text') == 'This is a text');
    // For Simplified Chinese locale
    assert(_i18n.of(context).lang('This is a text') == '这是一段文本');
    // For Traditional Chinese locale
    assert(_i18n.of(context).lang('This is a text') == '這是一段文本');

    return null;
  }
// ...
```

## Template Text

```yaml
# Translations in the file `assets/i18n/default.yaml`
i18n:
  Templates:
    - _: Hello, {{ name.en }}!
      zh: 您好，{{ name.zh }}！
```

```dart
// Equals with `final I18n _i18n = I18n.build(namespace: 'default', module: 'Templates')`
final I18n _i18n = I18n.build(module: 'Templates');

// ...
  @override
  Widget build(BuildContext context) {
    // For English locale
    assert(
      _i18n.of(context)
           .lang('Hello, {{ name.en }}!', args: const { 'name': {'en': 'World', 'zh': '世界'} })
      == 'Hello, World!'
    );
    // For Chinese locale
    assert(
      _i18n.of(context)
           .lang('Hello, {{ name.en }}!', args: const { 'name': {'en': 'World', 'zh': '世界'} })
      == '您好，世界！'
    );

    return null;
  }
// ...
```

## Annotated Text

```yaml
# Translations in the file `assets/i18n/annotated/default.yaml`
i18n:
  _:
    - _: This is a text
      zh: 这是一段文本
      zh_Hant: 這是一段文本
    - _: This is a text
      annotation: another
      en: This is another text
      zh: 这是另一段文字
      zh_Hant: 這是另一段文字
```

```dart
// Equals with `final I18n _i18n = I18n.build(namespace: 'annotated/default', module: '_')`
final I18n _i18n = I18n.build(namespace: 'annotated');

// ...
  @override
  Widget build(BuildContext context) {
    // For English locale
    assert(_i18n.of(context).lang('This is a text') == 'This is a text');
    // For Simplified Chinese locale
    assert(_i18n.of(context).lang('This is a text') == '这是一段文本');
    // For Traditional Chinese locale
    assert(_i18n.of(context).lang('This is a text') == '這是一段文本');

    // For English locale
    assert(_i18n.of(context).lang('This is a text', annotation: 'another') == 'This is another text');
    // For Simplified Chinese locale
    assert(_i18n.of(context).lang('This is a text', annotation: 'another') == '这是另一段文字');
    // For Traditional Chinese locale
    assert(_i18n.of(context).lang('This is a text', annotation: 'another') == '這是另一段文字');

    return null;
  }
// ...
```

## Remote Text

Assume that there is a remote i18n message resource which can be fetched from
`https://i18n.example.com/assets/i18n/`. And we have the following files in it:

```
├── i18n.json     # The i18n message resources manifest
└── remote
    └── text.yaml
```

The content of the file `i18n.json` is:

```json
["remote/text.yaml"]
```

And the content of the file `remote/text.yaml` is:

```yaml
i18n:
  Remotes:
    - _: This is a text from remote
      zh: 这是一段来自远端服务的文本
      zh_Hant: 這是一段來自遠端服務的文本
```

Then do translation for the remote text like:

```dart
// ...
  @override
  Widget build(BuildContext context) {

    return FutureBuilder<String>(
      future: this._fetchRemoteLocale(locale, 'This is a text from remote'),
      builder: (BuildContext context, AsyncSnapshot<String> snapshot) {

        switch (snapshot.connectionState) {
          case ConnectionState.done:
            final String msg = snapshot.data ?? text;

            // For English locale
            assert(msg == 'This is a text from remote');
            // For Simplified Chinese locale
            assert(msg == '这是一段来自远端服务的文本');
            // For Traditional Chinese locale
            assert(msg == '這是一段來自遠端服務的文本');

            return Text(msg);
          default:
            return Text('Loading ...');
        }
      },
    );
  }

  Future<String> _fetchRemoteLocale(Locale locale, String text) async {
    return await I18n.delegate(
      basePath: 'https://i18n.example.com/assets/i18n/',
      manifestPath: 'i18n.json',
    )
    .load(locale)
    .then((ctx) => ctx.module(namespace: 'remote/text', module: 'Remotes')
    .lang(text));
  }
// ...
```

## Specified Locale

```yaml
# Translations in the file `assets/i18n/default.yaml`
i18n:
  special:
    SpecifiedLocale:
      - _: This an english text, but it will be translated to Chinese
        zh_Hans: 这本应该是一段英文文本，但却会被转译为中文
        zh_Hant: 這本應該是一段英文文本，但卻會被轉譯為中文
```

```dart
final I18n _i18n = I18n.build(namespace: 'special', module: 'SpecifiedLocale');

// ...
  @override
  Widget build(BuildContext context) {
    // For English locale
    assert(
      _i18n.of(context)
           .lang('This an english text, but it will be translated to Chinese', locale: 'zh_Hans')
      == '这本应该是一段英文文本，但却会被转译为中文'
    );
    // For Traditional Chinese locale
    assert(
      _i18n.of(context)
           .lang('This an english text, but it will be translated to Chinese', locale: 'zh_Hans')
      == '这本应该是一段英文文本，但却会被转译为中文'
    );

    return null;
  }
// ...
```

## Via Property Key

```yaml
# Translations in the file `assets/i18n/default.yaml`
i18n:
  _:
    - _: "this.is.a.text.with.property.key"
      en: This is a text mapping by a property key
      zh: 这是一段通过Property Key映射到的文本
      zh_Hant: 這是一段通過Property Key映射到的文本
```

```dart
final I18n _i18n = I18n.build();

// ...
  @override
  Widget build(BuildContext context) {
    // For English locale
    assert(
      _i18n.of(context)
           .lang('this.is.a.text.with.property.key')
      == 'This is a text mapping by a property key'
    );
    // For Simplified Chinese locale
    assert(
      _i18n.of(context)
           .lang('this.is.a.text.with.property.key')
      == '这是一段通过Property Key映射到的文本'
    );
    // For Traditional Chinese locale
    assert(
      _i18n.of(context)
           .lang('this.is.a.text.with.property.key')
      == '這是一段通過Property Key映射到的文本'
    );

    return null;
  }
// ...
```

## Flutter Library

We have putted a text in the library `flutter_i18n`:

```yaml
# Translations in the file `assets/i18n/default.yaml`
i18n:
  _:
    - _: To my dear friend
      en: |
        To my dear friend:
          Hope you be sincere, kind and self-cultivation.
          Hope you be brave, confident and responsible.
          Hope you be focused, enthusiastic, and have ambitions.
          Hope you be strong, work hard, and make a difference.
                  From your Danger Dan!
      zh: |
        致，我亲爱的朋友：
          愿你真诚、善良、有修养；
          愿你勇敢、自信、有担当；
          愿你专注、热忱、有理想；
          愿你坚强、拼搏、有作为；
          愿你「走出半生，归来仍是少年」；
                 来自，爱你的蛋！
```

So you can get the complete translated text with the following code:

```dart
// ...
  @override
  Widget build(BuildContext context) {
    final I18n i18n = I18n.build(package: 'flutter_i18n');

    // For English locale
    assert(
      i18n.of(context).lang('To my dear friend')
      == '''To my dear friend:
  Hope you be sincere, kind and self-cultivation.
  Hope you be brave, confident and responsible.
  Hope you be focused, enthusiastic, and have ambitions.
  Hope you be strong, work hard, and make a difference.
          From your Danger Dan!'''
    );
    // For Chinese locale
    assert(
      i18n.of(context).lang('To my dear friend')
      == '''致，我亲爱的朋友：
  愿你真诚、善良、有修养；
  愿你勇敢、自信、有担当；
  愿你专注、热忱、有理想；
  愿你坚强、拼搏、有作为；
  愿你「走出半生，归来仍是少年」；
         来自，爱你的蛋！'''
    );

    return null;
  }
// ...
```
