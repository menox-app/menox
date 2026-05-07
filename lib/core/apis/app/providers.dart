import 'package:flutter_core/core/apis/app/index.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'providers.g.dart';

@Riverpod(keepAlive: true)
AppApi appApi(AppApiRef ref) => AppApi.instance;
