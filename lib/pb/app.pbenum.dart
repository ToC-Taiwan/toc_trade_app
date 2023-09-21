//
//  Generated code. Do not modify.
//  source: app.proto
//
// @dart = 2.12

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_final_fields
// ignore_for_file: unnecessary_import, unnecessary_this, unused_import

import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

class WSType extends $pb.ProtobufEnum {
  static const WSType TYPE_FUTURE_TICK = WSType._(0, _omitEnumNames ? '' : 'TYPE_FUTURE_TICK');
  static const WSType TYPE_FUTURE_ORDER = WSType._(1, _omitEnumNames ? '' : 'TYPE_FUTURE_ORDER');
  static const WSType TYPE_TRADE_INDEX = WSType._(2, _omitEnumNames ? '' : 'TYPE_TRADE_INDEX');
  static const WSType TYPE_FUTURE_POSITION = WSType._(3, _omitEnumNames ? '' : 'TYPE_FUTURE_POSITION');
  static const WSType TYPE_ASSIST_STATUS = WSType._(4, _omitEnumNames ? '' : 'TYPE_ASSIST_STATUS');
  static const WSType TYPE_ERR_MESSAGE = WSType._(5, _omitEnumNames ? '' : 'TYPE_ERR_MESSAGE');
  static const WSType TYPE_KBAR_ARR = WSType._(6, _omitEnumNames ? '' : 'TYPE_KBAR_ARR');
  static const WSType TYPE_FUTURE_DETAIL = WSType._(7, _omitEnumNames ? '' : 'TYPE_FUTURE_DETAIL');

  static const $core.List<WSType> values = <WSType> [
    TYPE_FUTURE_TICK,
    TYPE_FUTURE_ORDER,
    TYPE_TRADE_INDEX,
    TYPE_FUTURE_POSITION,
    TYPE_ASSIST_STATUS,
    TYPE_ERR_MESSAGE,
    TYPE_KBAR_ARR,
    TYPE_FUTURE_DETAIL,
  ];

  static final $core.Map<$core.int, WSType> _byValue = $pb.ProtobufEnum.initByValue(values);
  static WSType? valueOf($core.int value) => _byValue[value];

  const WSType._($core.int v, $core.String n) : super(v, n);
}


const _omitEnumNames = $core.bool.fromEnvironment('protobuf.omit_enum_names');
