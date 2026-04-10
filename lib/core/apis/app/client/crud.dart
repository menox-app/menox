import 'package:flutter_core/core/apis/base/client/crud.dart';
import 'package:flutter_core/core/apis/base/interfaces/record.dart';

abstract class AppCrudApiClient<T extends BaseRecord>
    extends BaseCrudApiClient<T> {
  final String resource;

  AppCrudApiClient(super.client, {required this.resource});

  @override
  String get resourcePath => '/$resource';
}
