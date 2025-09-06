import 'package:exemplo/views/main_ui.dart';
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;
import '../models/pessoa_model.dart';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' show Platform;

import 'package:sqflite_common_ffi/sqflite_ffi.dart'
    show sqfliteFfiInit, databaseFactoryFfi;
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart'
    show databaseFactoryFfiWeb;

// ---------------------------
// 3) APP
// ---------------------------
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicialização específica para cada plataforma
  if (kIsWeb) {
    databaseFactory = databaseFactoryFfiWeb;
  } else if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  runApp(const PessoasApp());
}

class PessoasApp extends StatelessWidget {
  const PessoasApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Persistência Local (SQLite)',
      theme: ThemeData(useMaterial3: true),
      home: const PessoasPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}
