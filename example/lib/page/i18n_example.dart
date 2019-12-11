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

import './i18n_example_basic.dart';
import './i18n_example_advance.dart';
import './i18n_example_special.dart';

final I18n _i18n = I18n.build(namespace: 'example');

class I18nExamplePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: TabBar(
          labelColor: Theme.of(context).primaryColor,
          unselectedLabelColor: Colors.grey,
          tabs: [
            Tab(
              text: _i18n.of(context).lang('Basic'),
            ),
            Tab(
              text: _i18n.of(context).lang('Advance'),
            ),
            Tab(
              text: _i18n.of(context).lang('Special'),
            ),
          ],
        ),
        body: TabBarView(
          children: [
            this.createTabPage(context, (context) => I18nExampleBasicPage()),
            this.createTabPage(context, (context) => I18nExampleAdvancePage()),
            this.createTabPage(context, (context) => I18nExampleSpecialPage()),
          ],
        ),
      ),
    );
  }

  Widget createTabPage(BuildContext context, WidgetBuilder builder) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 12.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          builder(context),
        ],
      ),
    );
  }
}
