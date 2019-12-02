I18n
========================

## 文件命名

资源文件命名为`<namespace>.yaml`，其中，`<namespace>`为国际化消息的命名空间，用于区分多个同名模块。
名字为`default`的命名空间为默认的资源文件，在获取国际化消息时未指定命名空间时，从该文件读取国际化消息。

## 文件内容结构

```yaml
i18n:
  # 默认模块名
  _:
    # `_`表示默认语言，其对应到给`I18n#lang(...)`传入的文本内容
    - _: This is a text
      zh: 这是一段文本
    - _: This is another text
      zh: 这是另一段文本
    - _: This is a text
      zh: 这是一段文本（但意义不同）
      # 通过指定annotation（标注）来区分内容相同但对应语言的消息内容不同的文本
      annotation: different-meaning
    # 带参数的国际化消息
    - _: Hello, ${name.en}!
      zh: 您好，${name.zh}！
  # 模块名一般为class
  Module1:
    - _: This text is in Module1
      zh: 这段文本在Module1中
  # `<namespace>/<module>`，即，限定了名字空间的模块
  ns1/Module1:
    - _: This text is in Module1 which is in namespace ns1
      zh: 这段文本在所属的名字空间为ns1的Module1中
  # 该结构与`<namespace>/<module>`等同
  ns2:
    Module1:
      - _: This text is in Moudle1 which is in namespace ns2
        zh: 这段文本在所属的名字空间为ns2的Module1中
```

`<namespace>/<module>`的消息可直接放在以`<namespace>`命名的资源文件中，且模块名不再指定该命名空间
（但可能是其他子名字空间）。

## 使用

- Simple message

```dart
final i18n = I18n.of(context);

// For zh_CN
i18n.lang('This is a text') == '这是一段文本';
```

- Same content message with annotation

```dart
final i18n = I18n.of(context);

// For zh_CN
i18n.lang('This is a text', annotation: 'different-meaning') == '这是一段文本（但意义不同）';
```

- Dynamic message with arguments

```dart
final i18n = I18n.of(context);

// For zh_CN
i18n.lang('Hello, ${name.en}!', args: {'name': {'en': 'World', 'zh': '世界'}}) == '您好，世界！';
```

- Module message

```dart
final i18n = I18n.of(context, module: Module1);

// For zh_CN
i18n.lang('This text is in Module1') == '这段文本在Module1中';
```

- Module message in the specified namespace

```dart
final i18n = I18n.of(context, module: Module1, namespace: 'ns1');

// For zh_CN
i18n.lang('This text is in Module1 which is in namespace ns1')
  == '这段文本在所属的名字空间为ns1的Module1中';
```
