import 'dart:async';
import 'dart:developer';

import 'package:account_monopoly/domain/model/game.dart';
import 'package:account_monopoly/domain/model/property.dart';
import 'package:account_monopoly/exception/domain_exception.dart';
import 'package:account_monopoly/repository/user_repository.dart';
import 'package:account_monopoly/utils/configs_constants.dart';
import 'package:account_monopoly/utils/string_utils.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:flutter/cupertino.dart';

class UserModelDTO{
  final int? id;
  final String name;
  final String username;
  final DateTime lastLogged;
  final List<GameModelDTO> games;
  Map<String, List<Property>>? propertiesVersion;

  int primaryColorValue;

  bool isHomeScreenOnBoarded;
  bool isGameScreenOnBoarded;
  bool isMarketScreenOnBoarded;
  bool isMyPortfolioScreenOnBoarded;

  UserModelDTO({this.id, required this.name, required this.username, required this.lastLogged,
   required this.games, this.propertiesVersion, this.primaryColorValue = ConfigsConstants.defaultPrimaryColorValue,
    this.isGameScreenOnBoarded = false, this.isHomeScreenOnBoarded = false, this.isMarketScreenOnBoarded = false, this.isMyPortfolioScreenOnBoarded = false});

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
      'primaryColorValue': primaryColorValue,
      'isGameScreenOnBoarded': isGameScreenOnBoarded,
      'isHomeScreenOnBoarded': isHomeScreenOnBoarded,
      'isMarketScreenOnBoarded': isMarketScreenOnBoarded
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
        }
      ),
      primaryColorValue: map['primaryColorValue'] as int? ?? ConfigsConstants.defaultPrimaryColorValue,
      isGameScreenOnBoarded: map['isGameScreenOnBoarded'] as bool? ?? false,
      isHomeScreenOnBoarded: map['isHomeScreenOnBoarded'] as bool? ?? false,
      isMarketScreenOnBoarded: map['isMarketScreenOnBoarded'] as bool? ?? false,
      isMyPortfolioScreenOnBoarded: map['isMyPortfolioScreenOnBoarded'] as bool? ?? false,
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

   void notifyChanges(bool isLoading) {
    this.isLoading = isLoading;
    notifyListeners();
  }

  void setOnBoardedOnScreen({bool? isGameScreenOnBoarded, bool? isHomeScreenOnBoarded, bool? isMarketScreenOnBoarded, bool? isMyPortfolioScreenOnBoarded}) {
    if (user == null) return;
    user!.isGameScreenOnBoarded = isGameScreenOnBoarded ?? user!.isGameScreenOnBoarded;
    user!.isHomeScreenOnBoarded = isHomeScreenOnBoarded ?? user!.isHomeScreenOnBoarded;
    user!.isMarketScreenOnBoarded = isMarketScreenOnBoarded ?? user!.isMarketScreenOnBoarded;
    user!.isMyPortfolioScreenOnBoarded = isMyPortfolioScreenOnBoarded ?? user!.isMyPortfolioScreenOnBoarded;
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
      await _getAllLocalUsers();
      user = userModelDTO;
    } on Exception catch(e){
      throw Exception("${ConfigsConstants.newUserErrorMsg} ${e.toString()}");
    } finally {
      isLoading = false;
      notifyListeners();
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
    isLoading = true;
    notifyListeners();
    try {
      await userRepository.deleteUser(userId);
      await _getAllLocalUsers();
    } on Exception {
      rethrow;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _getAllLocalUsers() async {
    allUsers = await userRepository.getAllUsers();
  }

  void signIn({required UserModelDTO userModelDTO}) {
    isLoading = true;
    notifyListeners();

    user = userModelDTO;

    isLoading = false;
    notifyListeners();
  }

  Future<void> signOut() async {
    try{
      isLoading = true;
      notifyListeners();

      user = null;
      await _getAllLocalUsers();
    }  on Exception {
      rethrow;
    } finally {
      notifyListeners();
      isLoading = false;
    }
  }

  bool isLoggedIn(){
    return user != null;
  }

  Future<void> _loadCurrentUser() async {
    try{
      isLoading = true;
      notifyListeners();
      _getAllLocalUsers();
      user ??= await userRepository.getUserWithLatestLastLogged();
    } on Exception {
      rethrow;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteGame(String gameId) async {
    isLoading = true;
    notifyListeners();
    user!.games.removeWhere((game) => game.id == gameId);
    await userRepository.updateUser(user!);
    isLoading = false;
    notifyListeners();
  }

  String checkPropertyIdExistsByIdThenChange(String versionId, String propertyId){
    if(user!.propertiesVersion![versionId] != null) {
      List<Property> properties = user!.propertiesVersion![versionId]!;
      if(properties.any((p) => p.id == propertyId)) {
        return "${propertyId.substring(0, 2)}${StringUtils.generateUUID(size: 2).toUpperCase()}";
      }
    }

    return propertyId;
  }

  Future<void> newProperty(String versionId, Property property) async {
    var propertiesVersion = user!.propertiesVersion!;
    try{
      isLoading = true;
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
      await updateUser();
    } on Exception {
      notifyListeners();
      rethrow;
    } finally {
      isLoading = false;
      notifyListeners();
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

  GameModelDTO getGameById(String gameId) {
    return user!.games.firstWhere((g) => g.id == gameId, orElse: () => GameModelDTO.empty());
  }

  // Getter facilitador para recuperar a cor ativa em qualquer tela
  Color get primaryColor {
    if (user == null) return const Color(ConfigsConstants.defaultPrimaryColorValue); // Cor padrão se não houver usuário logado
    return Color(user!.primaryColorValue);
  }

  Future<void> updatePrimaryColor(Color newColor) async {
    if (user == null) return;
    
    // Atualiza o valor no modelo
    user!.primaryColorValue = newColor.value;
    notifyListeners(); // Notifica o app inteiro para redesenhar com a nova cor

    // Persiste a alteração no backend/banco de dados
    await updateUser(); 
  }

}