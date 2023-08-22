import 'package:account_monopoly/model/user_model.dart';
import 'package:get_it/get_it.dart';
import 'package:sembast/sembast.dart';

abstract class UserRepository {

  Future<int> insertUser(UserModelDTO user);

  Future updateUser(UserModelDTO user);

  Future deleteUser(int userId);

  Future<List<UserModelDTO>> getAllUsers();

  Future<UserModelDTO?> getUserWithLatestLastLogged();
}

class SembastUserRepository extends UserRepository {
  final Database _database = GetIt.I.get();
  final StoreRef _store = intMapStoreFactory.store("user_store");

  @override
  Future<int> insertUser(UserModelDTO user) async {
    return await _store.add(_database, user.toMap()) as int;
  }

  @override
  Future updateUser(UserModelDTO user) async {
    await _store.record(user.id).update(_database, user.toMap());
  }

  @override
  Future deleteUser(int userId) async{
    await _store.record(userId).delete(_database);
  }

  @override
  Future<List<UserModelDTO>> getAllUsers() async {
    final snapshots = await _store.find(_database);
    return snapshots
        .map((snapshot) => UserModelDTO.fromMap(snapshot.key as int, snapshot.value as Map<String, dynamic>)) // Correção aqui
        .toList(growable: false); // Convertendo o Iterable para List
  }

  @override
  Future<UserModelDTO?> getUserWithLatestLastLogged() async {
    final snapshots = await _store.find(_database, finder: Finder(sortOrders: [SortOrder('lastLogged', false)]));

    if (snapshots.isNotEmpty) {
      final latestUserSnapshot = snapshots.first;
      return UserModelDTO.fromMap(latestUserSnapshot.key as int, latestUserSnapshot.value as Map<String, dynamic>);
    }

    return null; // Retorna null se não houver usuários
  }


}
