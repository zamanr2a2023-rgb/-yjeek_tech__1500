import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:yjeek_app/app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GoogleFonts.pendingFonts([GoogleFonts.inter()]);
  runApp(const YjeekApp());
}
