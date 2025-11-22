import 'package:get_it/get_it.dart';
import 'package:sembast/sembast_io.dart';
import 'package:sembast/sembast.dart';// Para desktop/mobile
import 'package:sembast_web/sembast_web.dart'; // Para web
import 'package:path_provider/path_provider.dart'; // Para getApplicationDocumentsDirectory
import 'package:flutter/foundation.dart'; // Para kIsWeb
import 'package:account_monopoly/repository/user_repository.dart'; // Presumindo que seu repositório está aqui
// ... (outras imports)

class InitDb {
  static Future initialize() async {
    await _initSembast();
    _registerRepositories();
  }

  static void _registerRepositories(){
    // Use registerLazySingleton para o UserRepository, como você já faz
    GetIt.I.registerLazySingleton<UserRepository>(() => SembastUserRepository());
  }

  static Future _initSembast() async {
    const dbName = "sembast.db";
    Database database;

    if (kIsWeb) {
      // 🌐 Inicialização para a Web (usa IndexedDB)
      final factory = databaseFactoryWeb;
      database = await factory.openDatabase(dbName);

    } else {
      // 🖥️ Inicialização para Desktop/Mobile (usa I/O de arquivos)
      final appDir = await getApplicationDocumentsDirectory();
      await appDir.create(recursive: true);
      final databasePath = "${appDir.path}/$dbName"; // Adicionei '/' para segurança
      final factory = databaseFactoryIo;
      database = await factory.openDatabase(databasePath);
    }

    GetIt.I.registerSingleton<Database>(database);
  }
}