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

import 'package:flutter/material.dart';

import 'package:flutter_i18n/flutter_i18n.dart';

final I18n _i18n = I18n.build(
  module: I18nExampleSpecialPage,
  namespace: 'example/special',
);

class I18nExampleSpecialPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const Text(
          '''
final I18n _i18n = I18n.build(
  module: I18nExampleSpecialPage,
  namespace: 'example/special',
);''',
          style: TextStyle(color: Colors.grey),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 12.0, bottom: 12.0),
          child: const Divider(
            height: 1,
            color: Colors.grey,
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const Text(
              '''
• _i18n.of(context).lang(
  'This an english text, but it will be translated to Chinese',
  locale: 'zh_Hans',
)''',
              style: TextStyle(color: Colors.green, fontStyle: FontStyle.italic),
            ),
            Row(
              children: <Widget>[
                // https://coolsymbol.com/
                const Text('⤷    ', style: TextStyle(color: Colors.amber, fontSize: 14)),
                Flexible(
                  child: Text(
                    _i18n.of(context).lang(
                          'This an english text, but it will be translated to Chinese',
                          locale: 'zh_Hans',
                        ),
                    style: const TextStyle(color: Colors.blue, fontSize: 12),
                  ),
                ),
              ],
            ),
          ],
        ),
        SizedBox(
          height: 18,
          child: Container(),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const Text(
              "• _i18n.of(context).lang('this.is.a.text.with.property.key')",
              style: TextStyle(color: Colors.green, fontStyle: FontStyle.italic),
            ),
            Row(
              children: <Widget>[
                // https://coolsymbol.com/
                const Text('⤷    ', style: TextStyle(color: Colors.amber, fontSize: 14)),
                Flexible(
                  child: Text(
                    _i18n.of(context).lang('this.is.a.text.with.property.key'),
                    style: const TextStyle(color: Colors.blue, fontSize: 12),
                  ),
                ),
              ],
            ),
          ],
        ),
        SizedBox(
          height: 18,
          child: Container(),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const Text(
              "• _i18n.of(null).lang('This is a text in a null BuildContext')",
              style: TextStyle(color: Colors.green, fontStyle: FontStyle.italic),
            ),
            Row(
              children: <Widget>[
                // https://coolsymbol.com/
                const Text('⤷    ', style: TextStyle(color: Colors.amber, fontSize: 14)),
                Flexible(
                  child: Text(
                    _i18n.of(null).lang('This is a text in a null BuildContext'),
                    style: const TextStyle(color: Colors.blue, fontSize: 12),
                  ),
                ),
              ],
            ),
          ],
        ),
        SizedBox(
          height: 18,
          child: Container(),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const Text(
              '''
• final I18n i18n = I18n.build(package: 'flutter_i18n');
  i18n.of(context).lang(
    'To my dear friend',
  )''',
              style: TextStyle(color: Colors.green, fontStyle: FontStyle.italic),
            ),
            Row(
              children: <Widget>[
                // https://coolsymbol.com/
                const Text('⤷    ', style: TextStyle(color: Colors.amber, fontSize: 14)),
                Flexible(
                  child: Text(
                    getPackageLocaleText(context, 'flutter_i18n', 'To my dear friend'),
                    style: const TextStyle(color: Colors.blue, fontSize: 12),
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  String getPackageLocaleText(BuildContext context, String package, String text) {
    final I18n i18n = I18n.build(package: package);

    return i18n.of(context).lang(text);
  }
}
