import 'dart:async';
import 'dart:developer';

import 'package:account_monopoly/domain/model/game.dart';
import 'package:account_monopoly/domain/model/property.dart';
import 'package:account_monopoly/exception/domain_exception.dart';
import 'package:account_monopoly/repository/user_repository.dart';
import 'package:account_monopoly/utils/configs_constants.dart';
import 'package:get_it/get_it.dart';
import 'package:flutter/cupertino.dart';

class UserModelDTO{
  final int? id;
  final String name;
  final String username;
  final DateTime lastLogged;
  final List<GameModelDTO> games;
  Map<String, List<Property>>? propertiesVersion;

  UserModelDTO({this.id, required this.name, required this.username, required this.lastLogged, required this.games, this.propertiesVersion});

// Método de SERIALIZAÇÃO (toDoMap) - NOVO E CORRIGIDO
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'username': username,
      'lastLogged': lastLogged.toIso8601String(),
      
      'games': games.map((game) => game.toMap()).toList(),
      
      'propertiesVersion': propertiesVersion?.map(
        (key, propertyList) => MapEntry(
          key,
          // Mapeia cada Property dentro da lista para Map<String, dynamic>
          propertyList.map((property) => property.toMap()).toList(),
        ),
      ),
    };
  }

factory UserModelDTO.fromMap(int id, Map<String, dynamic> map) {
    // 1. Acesso Seguro e Verificação de Tipo (Correção Principal)
    final dynamic rawPropertiesVersion = map['propertiesVersion'];
    Map<String, dynamic> propertiesVersionMap = {};

    // Se o tipo for realmente um Map, usamos ele.
    // Caso contrário (se for List, null, ou outro tipo inesperado), usamos o mapa vazio {}.
    if (rawPropertiesVersion is Map) {
      propertiesVersionMap = Map<String, dynamic>.from(rawPropertiesVersion);
    } else {
      // Opcional: Adicione um log para rastrear dados corrompidos
      print('Warning: propertiesVersion expected Map but found ${rawPropertiesVersion.runtimeType}. Treating as empty map.');
    }

    return UserModelDTO(
      id: id,
      name: map['name'] as String,
      username: map['username'] as String,
      lastLogged: DateTime.parse(map['lastLogged'] as String),
      games: (map['games'] as List<dynamic>)
          .map((gameMap) =>
              GameModelDTO.fromMap(gameMap as Map<String, dynamic>))
          .toList(),
      
      // 2. Mapeamento do propertiesVersionMap (agora garantido ser um Map)
      propertiesVersion: propertiesVersionMap.map(
        (key, value) {
          // Garantindo que 'value' é uma lista (fallback para [])
          final List<dynamic> propertyList = (value is List) ? value : [];

          return MapEntry(
            key,
            propertyList
                .map((p) => Property.fromMap(p as Map<String, dynamic>))
                .toList(),
          );
        },
      ),
    );
  }

  UserModelDTO copyWith({String? name, String? peerId, String? username, DateTime? lastLogged, List<GameModelDTO>? games}){
    return UserModelDTO(
        id: id,
        name: name ?? this.name,
        username: username ?? this.username,
        lastLogged: lastLogged ?? this.lastLogged,
        games: games ?? this.games
    );
  }
}
class UserProvider extends ChangeNotifier{
  List<UserModelDTO> allUsers = [];
  UserModelDTO? user;
  UserRepository userRepository =  GetIt.I.get();
  //static UserModelController of(BuildContext context) => ScopedModel.of<UserModelController>(context);
  bool isLoading = false;

  UserProvider() {
    _loadCurrentUser();
  }

  void notify(){
    notifyListeners();
  }

  Future<void> signUp(
      {required String name, required String username}
      ) async {
    try{
      isLoading = true;
      notifyListeners();

      UserModelDTO userModelDTO = UserModelDTO(
          name: name,
          username: username,
          lastLogged: DateTime.now(),
          games: []
      );

      await userRepository.insertUser(userModelDTO);
      user = userModelDTO;
      isLoading = false;
      notifyListeners();
    } on Exception catch(e){
      isLoading = false;
      notifyListeners();
      throw Exception("${ConfigsConstants.newUserErrorMsg} ${e.toString()}");
    }
  }

  void checkUserExists(String username){
    if(allUsers.where((u) => u.username == username).isNotEmpty) throw UserExistsException(ConfigsConstants.userExistsErrorMsg);
  }

  Future<void> updateUser() async {
    try{
      isLoading = true;
      notifyListeners();
      await userRepository.updateUser(user!);
    } on Exception catch(e) {
      log("Error updateUser: $e");
      rethrow;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteUser(int userId) async {
    try{
      await userRepository.deleteUser(userId);
      
    } on Exception {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> getAllLocalUsers() async {
    notifyListeners();
    isLoading = true;
    allUsers = await userRepository.getAllUsers();
    isLoading = false;
    notifyListeners();
  }

  void signIn({required UserModelDTO userModelDTO}) {
    isLoading = true;
    notifyListeners();

    user = userModelDTO;

    isLoading = false;
    notifyListeners();
  }

  Future<void> signOut() async {
    isLoading = true;
    notifyListeners();

    user = null;
    await getAllLocalUsers();

    isLoading = false;
    notifyListeners();
  }

  /*void recoverPass(String email){

  }*/

  bool isLoggedIn(){
    return user != null;
  }

  /*Future<bool> usernameCheck(String username) async {

  }*/

  Future<void> _loadCurrentUser() async {
    isLoading = true;
    notifyListeners();
    getAllLocalUsers();
    user ??= await userRepository.getUserWithLatestLastLogged();
    isLoading = false;
    notifyListeners();
  }

  Future<void> deleteGame(String gameId) async {
    isLoading = true;
    notifyListeners();
    user!.games.removeWhere((game) => game.id == gameId);
    await userRepository.updateUser(user!);
    isLoading = false;
    notifyListeners();
  }

  Future<void> newProperty(String versionId, Property property) async {
    var propertiesVersion = user!.propertiesVersion!;
    try{
      notifyListeners();
      if(propertiesVersion.containsKey(versionId)){
        if(propertiesVersion[versionId]!.any((p) => p.id == property.id)){
          final int index = propertiesVersion[versionId]!.indexWhere((p) => p.id == property.id);
          propertiesVersion[versionId]![index] = property;
        } else {
          propertiesVersion[versionId]!.add(property);
        }  
      } else {
        propertiesVersion[versionId] = [property];
      }
      updateUser();
      notify();
    } on Exception {
      notifyListeners();
      rethrow;
    } 
  }

  Future<void> deletePropertiesCollection(String versionId) async {
    isLoading = true;
    notifyListeners();
    user!.propertiesVersion!.remove(versionId);
    await userRepository.updateUser(user!);
    isLoading = false;
    notifyListeners();
  }

  Future<void> deleteProperty(String versionId, String propertyid) async {
    isLoading = true;
    notifyListeners();
    user!.propertiesVersion![versionId]!.removeWhere((p) => p.id == propertyid);
    await userRepository.updateUser(user!);
    isLoading = false;
    notifyListeners();
  }

  bool checkHasGameById(String gameId) {
    if (user!.games.isNotEmpty) {
      try {
        // Tenta encontrar o jogo. Se encontrar, retorna true.
        user!.games.firstWhere((game) => game.id == gameId);
        return true;
      } on StateError {
        // Se não encontrar (StateError), retorna false.
        return false;
      }
    }
    return false; 
  }

}