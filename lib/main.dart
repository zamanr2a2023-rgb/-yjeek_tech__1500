import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:yjeek_app/app.dart';
import 'package:yjeek_app/core/network/api_client.dart';
import 'package:yjeek_app/core/services/storage_service.dart';
import 'package:yjeek_app/core/utils/app_logger.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GoogleFonts.pendingFonts([GoogleFonts.inter()]);

  final storage = await StorageService.init();
  Get.put<StorageService>(storage, permanent: true);
  Get.put<ApiClient>(ApiClient(), permanent: true);

  appLogger.i('Yjeek app starting');

  runApp(
    const ProviderScope(
      child: YjeekApp(),
    ),
  );
}
