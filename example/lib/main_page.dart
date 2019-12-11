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

import 'package:flutter_arc_speed_dial/flutter_speed_dial_menu_button.dart';
import 'package:flutter_arc_speed_dial/main_menu_floating_action_button.dart';

import 'package:flutter_i18n/flutter_i18n.dart';

import './app_state.dart';
import './locale_icon.dart';
import './locale_controller.dart';
import './page/i18n_example.dart';

final I18n _i18n = I18n.build(namespace: 'page');

class MainPage extends StatefulWidget {
  final String title;
  final Function onGenerateTitle;
  final AppState appState;
  final LocaleController localeController;

  MainPage({Key key, @required this.localeController, this.title, this.onGenerateTitle, this.appState})
      : super(key: key);

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  bool _isShowDial = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(this.widget.onGenerateTitle != null ? this.widget.onGenerateTitle(context) : this.widget.title),
      ),
      body: Center(
        child: I18nExamplePage(),
      ),
      floatingActionButton: this.createFloatingActionButton(context),
    );
  }

  void _changeLocale(Locale locale) {
    this._isShowDial = false;
    if (this.widget.localeController.value == locale) {
      setState(() {});
    } else {
      this.widget.localeController.value = locale;
    }
  }

  Widget createFloatingActionButton(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    // https://pub.dev/packages/flutter_arc_speed_dial#example
    return SpeedDialMenuButton(
      isShowSpeedDial: _isShowDial,
      isMainFABMini: false,
      isSpeedDialFABsMini: true,
      paddingBtwSpeedDialButton: 30.0,
      updateSpeedDialStatus: (isShow) {
        setState(() {
          this._isShowDial = isShow;
        });
      },
      mainMenuFloatingActionButton: MainMenuFloatingActionButton(
        mini: false,
        tooltip: _i18n.of(context).lang('Change Language'),
        child: this.createLocaleWidget(this.widget.appState.locale),
        onPressed: () {},
        closeMenuChild: Icon(Icons.close),
        closeMenuForegroundColor: Colors.white,
        closeMenuBackgroundColor: Colors.red,
      ),
      floatingActionButtonWidgetChildren: this
          .widget
          .appState
          .supportedLocales
          .map<FloatingActionButton>((locale) => FloatingActionButton(
                mini: false,
                child: this.createLocaleWidget(locale),
                onPressed: () => this._changeLocale(locale),
                backgroundColor: theme.primaryColor,
              ))
          .toList(),
    );
  }

  Widget createLocaleWidget(Locale locale) {
    final LocaleIcon icon = LocaleIcons.get(locale);

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        icon.img,
        Text(
          icon.text,
          style: TextStyle(
            fontSize: 6,
          ),
        ),
      ],
    );
  }
}
