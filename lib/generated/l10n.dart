// GENERATED CODE - DO NOT MODIFY BY HAND
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'intl/messages_all.dart';

// **************************************************************************
// Generator: Flutter Intl IDE plugin
// Made by Localizely
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, lines_longer_than_80_chars
// ignore_for_file: join_return_with_assignment, prefer_final_in_for_each
// ignore_for_file: avoid_redundant_argument_values, avoid_escaping_inner_quotes

class S {
  S();

  static S? _current;

  static S get current {
    assert(_current != null,
        'No instance of S was loaded. Try to initialize the S delegate before accessing S.current.');
    return _current!;
  }

  static const AppLocalizationDelegate delegate = AppLocalizationDelegate();

  static Future<S> load(Locale locale) {
    final name = (locale.countryCode?.isEmpty ?? false)
        ? locale.languageCode
        : locale.toString();
    final localeName = Intl.canonicalizedLocale(name);
    return initializeMessages(localeName).then((_) {
      Intl.defaultLocale = localeName;
      final instance = S();
      S._current = instance;

      return instance;
    });
  }

  static S of(BuildContext context) {
    final instance = S.maybeOf(context);
    assert(instance != null,
        'No instance of S present in the widget tree. Did you add S.delegate in localizationsDelegates?');
    return instance!;
  }

  static S? maybeOf(BuildContext context) {
    return Localizations.of<S>(context, S);
  }

  /// `Targets`
  String get targets {
    return Intl.message(
      'Targets',
      name: 'targets',
      desc: '',
      args: [],
    );
  }

  /// `Strategy`
  String get strategy {
    return Intl.message(
      'Strategy',
      name: 'strategy',
      desc: '',
      args: [],
    );
  }

  /// `Pick Stock`
  String get pick_stock {
    return Intl.message(
      'Pick Stock',
      name: 'pick_stock',
      desc: '',
      args: [],
    );
  }

  /// `TSE`
  String get tse {
    return Intl.message(
      'TSE',
      name: 'tse',
      desc: '',
      args: [],
    );
  }

  /// `Balance`
  String get balance {
    return Intl.message(
      'Balance',
      name: 'balance',
      desc: '',
      args: [],
    );
  }

  /// `Settings`
  String get settings {
    return Intl.message(
      'Settings',
      name: 'settings',
      desc: '',
      args: [],
    );
  }

  /// `Search`
  String get search {
    return Intl.message(
      'Search',
      name: 'search',
      desc: '',
      args: [],
    );
  }

  /// `Stock Number`
  String get stock_number {
    return Intl.message(
      'Stock Number',
      name: 'stock_number',
      desc: '',
      args: [],
    );
  }

  /// `Delete All Pick Stock`
  String get delete_all_pick_stock {
    return Intl.message(
      'Delete All Pick Stock',
      name: 'delete_all_pick_stock',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure you want to delete all pick stock?`
  String get delete_all_pick_stock_confirm {
    return Intl.message(
      'Are you sure you want to delete all pick stock?',
      name: 'delete_all_pick_stock_confirm',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure you want to delete this stock`
  String get delete_pick_stock_confirm {
    return Intl.message(
      'Are you sure you want to delete this stock',
      name: 'delete_pick_stock_confirm',
      desc: '',
      args: [],
    );
  }

  /// `Add`
  String get add {
    return Intl.message(
      'Add',
      name: 'add',
      desc: '',
      args: [],
    );
  }

  /// `Cancel`
  String get cancel {
    return Intl.message(
      'Cancel',
      name: 'cancel',
      desc: '',
      args: [],
    );
  }

  /// `Delete`
  String get delete {
    return Intl.message(
      'Delete',
      name: 'delete',
      desc: '',
      args: [],
    );
  }

  /// `No Pick Stock`
  String get no_pick_stock {
    return Intl.message(
      'No Pick Stock',
      name: 'no_pick_stock',
      desc: '',
      args: [],
    );
  }

  /// `Click + to add stock`
  String get click_plus_to_add_stock {
    return Intl.message(
      'Click + to add stock',
      name: 'click_plus_to_add_stock',
      desc: '',
      args: [],
    );
  }

  /// `Type Stock Number`
  String get type_stock_number {
    return Intl.message(
      'Type Stock Number',
      name: 'type_stock_number',
      desc: '',
      args: [],
    );
  }

  /// `Warning`
  String get warning {
    return Intl.message(
      'Warning',
      name: 'warning',
      desc: '',
      args: [],
    );
  }

  /// `Input is empty`
  String get input_must_not_empty {
    return Intl.message(
      'Input is empty',
      name: 'input_must_not_empty',
      desc: '',
      args: [],
    );
  }

  /// `OK`
  String get ok {
    return Intl.message(
      'OK',
      name: 'ok',
      desc: '',
      args: [],
    );
  }

  /// `Stock dose not exist`
  String get stock_dose_not_exist {
    return Intl.message(
      'Stock dose not exist',
      name: 'stock_dose_not_exist',
      desc: '',
      args: [],
    );
  }

  /// `Language`
  String get language {
    return Intl.message(
      'Language',
      name: 'language',
      desc: '',
      args: [],
    );
  }

  /// `Version`
  String get version {
    return Intl.message(
      'Version',
      name: 'version',
      desc: '',
      args: [],
    );
  }

  /// `Remove Ads`
  String get remove_ads {
    return Intl.message(
      'Remove Ads',
      name: 'remove_ads',
      desc: '',
      args: [],
    );
  }

  /// `About Me`
  String get about_me {
    return Intl.message(
      'About Me',
      name: 'about_me',
      desc: '',
      args: [],
    );
  }

  /// `Terms and Conditions of Use`
  String get terms_and_conditions_of_use {
    return Intl.message(
      'Terms and Conditions of Use',
      name: 'terms_and_conditions_of_use',
      desc: '',
      args: [],
    );
  }

  /// `Notification`
  String get notification {
    return Intl.message(
      'Notification',
      name: 'notification',
      desc: '',
      args: [],
    );
  }

  /// `Settings of Notification`
  String get settings_of_notification {
    return Intl.message(
      'Settings of Notification',
      name: 'settings_of_notification',
      desc: '',
      args: [],
    );
  }

  /// `Trade Configuration`
  String get trade_configuration {
    return Intl.message(
      'Trade Configuration',
      name: 'trade_configuration',
      desc: '',
      args: [],
    );
  }

  /// `Group`
  String get group {
    return Intl.message(
      'Group',
      name: 'group',
      desc: '',
      args: [],
    );
  }

  /// `Date`
  String get date {
    return Intl.message(
      'Date',
      name: 'date',
      desc: '',
      args: [],
    );
  }

  /// `Close`
  String get close {
    return Intl.message(
      'Close',
      name: 'close',
      desc: '',
      args: [],
    );
  }

  /// `Open`
  String get open {
    return Intl.message(
      'Open',
      name: 'open',
      desc: '',
      args: [],
    );
  }

  /// `High`
  String get high {
    return Intl.message(
      'High',
      name: 'high',
      desc: '',
      args: [],
    );
  }

  /// `Low`
  String get low {
    return Intl.message(
      'Low',
      name: 'low',
      desc: '',
      args: [],
    );
  }

  /// `Change Type`
  String get change_type {
    return Intl.message(
      'Change Type',
      name: 'change_type',
      desc: '',
      args: [],
    );
  }

  /// `Percent Change`
  String get percent_change {
    return Intl.message(
      'Percent Change',
      name: 'percent_change',
      desc: '',
      args: [],
    );
  }

  /// `Price Change`
  String get price_change {
    return Intl.message(
      'Price Change',
      name: 'price_change',
      desc: '',
      args: [],
    );
  }

  /// `Refresh`
  String get refresh {
    return Intl.message(
      'Refresh',
      name: 'refresh',
      desc: '',
      args: [],
    );
  }

  /// `Latest`
  String get latest {
    return Intl.message(
      'Latest',
      name: 'latest',
      desc: '',
      args: [],
    );
  }

  /// `Total`
  String get total {
    return Intl.message(
      'Total',
      name: 'total',
      desc: '',
      args: [],
    );
  }

  /// `No Data`
  String get no_data {
    return Intl.message(
      'No Data',
      name: 'no_data',
      desc: '',
      args: [],
    );
  }

  /// `Trade Count`
  String get trade_count {
    return Intl.message(
      'Trade Count',
      name: 'trade_count',
      desc: '',
      args: [],
    );
  }

  /// `Try Again`
  String get try_again {
    return Intl.message(
      'Try Again',
      name: 'try_again',
      desc: '',
      args: [],
    );
  }

  /// `Display`
  String get display {
    return Intl.message(
      'Display',
      name: 'display',
      desc: '',
      args: [],
    );
  }

  /// `My Web Site`
  String get my_web_site {
    return Intl.message(
      'My Web Site',
      name: 'my_web_site',
      desc: '',
      args: [],
    );
  }

  /// `Restart to apply changes`
  String get restart_to_apply_changes {
    return Intl.message(
      'Restart to apply changes',
      name: 'restart_to_apply_changes',
      desc: '',
      args: [],
    );
  }

  /// `Product List Abnormal`
  String get product_list_abnormal {
    return Intl.message(
      'Product List Abnormal',
      name: 'product_list_abnormal',
      desc: '',
      args: [],
    );
  }

  /// `Developing`
  String get developing {
    return Intl.message(
      'Developing',
      name: 'developing',
      desc: '',
      args: [],
    );
  }

  /// `Restore`
  String get restore {
    return Intl.message(
      'Restore',
      name: 'restore',
      desc: '',
      args: [],
    );
  }

  /// `Already Purchased?`
  String get already_purchased {
    return Intl.message(
      'Already Purchased?',
      name: 'already_purchased',
      desc: '',
      args: [],
    );
  }

  /// `Read Only`
  String get read_only {
    return Intl.message(
      'Read Only',
      name: 'read_only',
      desc: '',
      args: [],
    );
  }

  /// `Restore Purchases`
  String get restore_purchase {
    return Intl.message(
      'Restore Purchases',
      name: 'restore_purchase',
      desc: '',
      args: [],
    );
  }

  /// `Success`
  String get success {
    return Intl.message(
      'Success',
      name: 'success',
      desc: '',
      args: [],
    );
  }

  /// `Loading`
  String get loading {
    return Intl.message(
      'Loading',
      name: 'loading',
      desc: '',
      args: [],
    );
  }

  /// `Future Trade`
  String get future_trade {
    return Intl.message(
      'Future Trade',
      name: 'future_trade',
      desc: '',
      args: [],
    );
  }

  /// `Stock`
  String get stock {
    return Intl.message(
      'Stock',
      name: 'stock',
      desc: '',
      args: [],
    );
  }

  /// `Future`
  String get future {
    return Intl.message(
      'Future',
      name: 'future',
      desc: '',
      args: [],
    );
  }

  /// `Buy`
  String get buy {
    return Intl.message(
      'Buy',
      name: 'buy',
      desc: '',
      args: [],
    );
  }

  /// `Sell`
  String get sell {
    return Intl.message(
      'Sell',
      name: 'sell',
      desc: '',
      args: [],
    );
  }

  /// `Quantity`
  String get quantity {
    return Intl.message(
      'Quantity',
      name: 'quantity',
      desc: '',
      args: [],
    );
  }

  /// `Enter Quantity`
  String get enter_quantity {
    return Intl.message(
      'Enter Quantity',
      name: 'enter_quantity',
      desc: '',
      args: [],
    );
  }

  /// `Edit`
  String get edit {
    return Intl.message(
      'Edit',
      name: 'edit',
      desc: '',
      args: [],
    );
  }

  /// `Pending Submit`
  String get pending_submit {
    return Intl.message(
      'Pending Submit',
      name: 'pending_submit',
      desc: '',
      args: [],
    );
  }

  /// `Pre Submitted`
  String get pre_submitted {
    return Intl.message(
      'Pre Submitted',
      name: 'pre_submitted',
      desc: '',
      args: [],
    );
  }

  /// `Submitted`
  String get submitted {
    return Intl.message(
      'Submitted',
      name: 'submitted',
      desc: '',
      args: [],
    );
  }

  /// `Failed`
  String get failed {
    return Intl.message(
      'Failed',
      name: 'failed',
      desc: '',
      args: [],
    );
  }

  /// `Cancelled`
  String get cancelled {
    return Intl.message(
      'Cancelled',
      name: 'cancelled',
      desc: '',
      args: [],
    );
  }

  /// `Filled`
  String get filled {
    return Intl.message(
      'Filled',
      name: 'filled',
      desc: '',
      args: [],
    );
  }

  /// `Part Filled`
  String get part_filled {
    return Intl.message(
      'Part Filled',
      name: 'part_filled',
      desc: '',
      args: [],
    );
  }

  /// `Position`
  String get position {
    return Intl.message(
      'Position',
      name: 'position',
      desc: '',
      args: [],
    );
  }

  /// `Avg`
  String get avg {
    return Intl.message(
      'Avg',
      name: 'avg',
      desc: '',
      args: [],
    );
  }

  /// `Error`
  String get error {
    return Intl.message(
      'Error',
      name: 'error',
      desc: '',
      args: [],
    );
  }

  /// `Time Period`
  String get time_period {
    return Intl.message(
      'Time Period',
      name: 'time_period',
      desc: '',
      args: [],
    );
  }

  /// `Now is not trade time`
  String get err_not_trade_time {
    return Intl.message(
      'Now is not trade time',
      name: 'err_not_trade_time',
      desc: '',
      args: [],
    );
  }

  /// `Please wait for previous order to be filled`
  String get err_not_filled {
    return Intl.message(
      'Please wait for previous order to be filled',
      name: 'err_not_filled',
      desc: '',
      args: [],
    );
  }

  /// `Assist only support qty = 1`
  String get err_assist_not_support {
    return Intl.message(
      'Assist only support qty = 1',
      name: 'err_assist_not_support',
      desc: '',
      args: [],
    );
  }

  /// `Unmarshal error`
  String get err_unmarshal {
    return Intl.message(
      'Unmarshal error',
      name: 'err_unmarshal',
      desc: '',
      args: [],
    );
  }

  /// `Get snapshot error`
  String get err_get_snapshot {
    return Intl.message(
      'Get snapshot error',
      name: 'err_get_snapshot',
      desc: '',
      args: [],
    );
  }

  /// `Get position error`
  String get err_get_position {
    return Intl.message(
      'Get position error',
      name: 'err_get_position',
      desc: '',
      args: [],
    );
  }

  /// `Place order error`
  String get err_place_order {
    return Intl.message(
      'Place order error',
      name: 'err_place_order',
      desc: '',
      args: [],
    );
  }

  /// `Cancel order failed`
  String get err_cancel_order_failed {
    return Intl.message(
      'Cancel order failed',
      name: 'err_cancel_order_failed',
      desc: '',
      args: [],
    );
  }

  /// `Assisting is full`
  String get err_assiting_is_full {
    return Intl.message(
      'Assisting is full',
      name: 'err_assiting_is_full',
      desc: '',
      args: [],
    );
  }

  /// `Assist is done`
  String get assist_is_done {
    return Intl.message(
      'Assist is done',
      name: 'assist_is_done',
      desc: '',
      args: [],
    );
  }

  /// `Earn`
  String get earn {
    return Intl.message(
      'Earn',
      name: 'earn',
      desc: '',
      args: [],
    );
  }

  /// `Loss`
  String get loss {
    return Intl.message(
      'Loss',
      name: 'loss',
      desc: '',
      args: [],
    );
  }

  /// `Assist`
  String get assisting {
    return Intl.message(
      'Assist',
      name: 'assisting',
      desc: '',
      args: [],
    );
  }
}

class AppLocalizationDelegate extends LocalizationsDelegate<S> {
  const AppLocalizationDelegate();

  List<Locale> get supportedLocales {
    return const <Locale>[
      Locale.fromSubtags(languageCode: 'en'),
      Locale.fromSubtags(
          languageCode: 'zh', scriptCode: 'Hans', countryCode: 'CN'),
      Locale.fromSubtags(
          languageCode: 'zh', scriptCode: 'Hant', countryCode: 'TW'),
    ];
  }

  @override
  bool isSupported(Locale locale) => _isSupported(locale);
  @override
  Future<S> load(Locale locale) => S.load(locale);
  @override
  bool shouldReload(AppLocalizationDelegate old) => false;

  bool _isSupported(Locale locale) {
    for (var supportedLocale in supportedLocales) {
      if (supportedLocale.languageCode == locale.languageCode) {
        return true;
      }
    }
    return false;
  }
}
