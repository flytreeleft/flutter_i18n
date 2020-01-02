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

import 'package:loading/loading.dart';
import 'package:loading/indicator/ball_pulse_indicator.dart';

import 'package:flutter_i18n/flutter_i18n.dart';

final I18n _i18n = I18n.build(
  namespace: 'example/advance',
);

class I18nExampleAdvancePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const Text(
          '''
final I18n _i18n = I18n.build(
  namespace: 'example/advance',
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
              "• _i18n.of(context).lang('This is a text')",
              style: TextStyle(color: Colors.green, fontStyle: FontStyle.italic),
            ),
            Row(
              children: <Widget>[
                // https://coolsymbol.com/
                const Text('⤷    ', style: TextStyle(color: Colors.amber, fontSize: 20)),
                Text(
                  _i18n.of(context).lang('This is a text'),
                  style: const TextStyle(color: Colors.blue, fontSize: 18),
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
              "• _i18n.of(context).lang('This is a text', annotation: 'another')",
              style: TextStyle(color: Colors.green, fontStyle: FontStyle.italic),
            ),
            Row(
              children: <Widget>[
                // https://coolsymbol.com/
                const Text('⤷    ', style: TextStyle(color: Colors.amber, fontSize: 20)),
                Text(
                  _i18n.of(context).lang('This is a text', annotation: 'another'),
                  style: const TextStyle(color: Colors.blue, fontSize: 18),
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
              "• _i18n.of(context).lang('This is a text from remote')",
              style: TextStyle(color: Colors.green, fontStyle: FontStyle.italic),
            ),
            Row(
              children: <Widget>[
                // https://coolsymbol.com/
                const Text('⤷    ', style: TextStyle(color: Colors.amber, fontSize: 20)),
                Flexible(
                  child: this._createRemoteLocaleText(Localizations.localeOf(context), 'This is a text from remote'),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _createRemoteLocaleText(Locale locale, String text) {
    return FutureBuilder<String>(
      future: this._fetchRemoteLocale(locale, text),
      builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.done:
            return Text(
              snapshot.data ?? text,
              style: const TextStyle(color: Colors.blue, fontSize: 18),
            );
          default:
            return Loading(
              indicator: BallPulseIndicator(),
              color: Colors.pink,
            );
        }
      },
    );
  }

  Future<String> _fetchRemoteLocale(Locale locale, String text) async {
    // Note: just for demo, so do not call I18n.delegate(...).load(...) directly
    return await I18n.delegate(
      basePath: 'https://raw.githubusercontent.com/flytreeleft/flutter_i18n/master/example/assets/i18n',
      manifestPath: 'example/remote/i18n.json',
      loader: const I18nResourceLoaderSpec(cacheable: false, showError: true),
    ).load(locale).then((ctx) => ctx.module(namespace: 'example/remote').lang(text));
  }
}
