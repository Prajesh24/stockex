import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:stockex/app/app.dart';
import 'package:stockex/core/services/hive/hive_service.dart';
import 'package:stockex/features/auth/data/model/auth_hive_model.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final hiveService = HiveService();
  await hiveService.init();

  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

