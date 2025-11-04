import 'dart:async';

import 'package:account_monopoly/domain/model/game_model_dto.dart';
import 'package:account_monopoly/repository/user_repository.dart';
import 'package:get_it/get_it.dart';
import 'package:flutter/cupertino.dart';

class UserModelDTO{
  final int? id;
  final String name;
  final String username;
  final DateTime lastLogged;
  final List<GameModelDTO> games;

  UserModelDTO({this.id, required this.name, required this.username, required this.lastLogged, required this.games});

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'username': username,
      'lastLogged': lastLogged.toIso8601String(),
      'games': games.map((game) => game.toMap()).toList()
    };
  }

  factory UserModelDTO.fromMap(int id, Map<String, dynamic> map) {
    return UserModelDTO(
        id: id,
        name: map['name'] as String,
        username: map['username'] as String,
        lastLogged: DateTime.parse(map['lastLogged']  as String),
        games: (map['games'] as List<dynamic>).map((gameMap) => GameModelDTO.fromMap(gameMap as Map<String, dynamic>)).toList()
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
  static const String NEW_USER_SUCCESS_MSG = "Cadastro concluído: ";
  static const String NEW_USER_ERROR_MSG = "Falha ao cadastrar usuário!";
  List<UserModelDTO> allUsers = [];
  UserModelDTO? user;
  UserRepository userRepository =  GetIt.I.get();
  //static UserModelController of(BuildContext context) => ScopedModel.of<UserModelController>(context);
  bool isLoading = false;

  UserProvider(){
    _loadCurrentUser();
  }

  //logar usuario atual ao abrir o app
  /*@override
  void addListener(VoidCallback listener) {
    super.addListener(listener);
    _loadCurrentUser();
  }*/

  void notify(){
    notifyListeners();
  }

  Future<void> signUp(
      {required name, required username, required BuildContext context, required Function onSuccess, required Function onFail}
      ) async {
    isLoading = true;
    notifyListeners();

    UserModelDTO userModelDTO = UserModelDTO(
        name: name,
        username: username,
        lastLogged: DateTime.now(),
        games: []
    );

    userRepository.insertUser(userModelDTO).then((value) async {
      user = userModelDTO;
      onSuccess(NEW_USER_SUCCESS_MSG + value.toString(), context);
      isLoading = false;
      notifyListeners();
    }).catchError((e){
      onFail(NEW_USER_ERROR_MSG, context);
      isLoading = false;
      notifyListeners();
    });
  }

  Future<void> updateUser() async {
    isLoading = true;
    notifyListeners();
    await userRepository.updateUser(user!);
    isLoading = false;
    notifyListeners();
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
    if(user == null) {
      user = await userRepository.getUserWithLatestLastLogged();
      if(user == null) {
        getAllLocalUsers();
      }
    }
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