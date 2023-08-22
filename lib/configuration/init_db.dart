import 'package:get_it/get_it.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sembast/sembast.dart';
import 'package:sembast/sembast_io.dart';

import '../repository/user_repository.dart';

class InitDb {
  static Future initialize() async {
    await _initSembast();
    _registerRepositories();
  }

  static _registerRepositories(){
    GetIt.I.registerLazySingleton<UserRepository>(() => SembastUserRepository());
  }

  static Future _initSembast() async {
    final appDir = await getApplicationDocumentsDirectory();
    await appDir.create(recursive: true);
    final databasePath = "${appDir.path}sembast.db";
    final database = await databaseFactoryIo.openDatabase(databasePath);
    GetIt.I.registerSingleton<Database>(database);
  }
}