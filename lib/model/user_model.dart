import 'dart:async';

import 'package:account_monopoly/model/game_model.dart';
import 'package:account_monopoly/repository/user_repository.dart';
import 'package:account_monopoly/utils/string_utils.dart';
import 'package:get_it/get_it.dart';
import 'package:flutter/cupertino.dart';
import 'package:scoped_model/scoped_model.dart';

class UserModelDTO{
  final int? id;
  final String peerId;
  final String name;
  final String username;
  final DateTime lastLogged;
  final List<GameModelDTO> games;

  UserModelDTO({this.id, required this.peerId, required this.name, required this.username, required this.lastLogged, required this.games});

  Map<String, dynamic> toMap() {
    return {
      'peerId':  peerId,
      'name': name,
      'username': username,
      'lastLogged': lastLogged.toIso8601String(),
      'games': games.map((game) => game.toMap()).toList()
    };
  }

  factory UserModelDTO.fromMap(int id, Map<String, dynamic> map) {
    return UserModelDTO(
        id: id,
        peerId: map['peerId'] as String,
        name: map['name'] as String,
        username: map['username'] as String,
        lastLogged: DateTime.parse(map['lastLogged']  as String),
        games: (map['games'] as List<dynamic>).map((gameMap) => GameModelDTO.fromMap(gameMap as Map<String, dynamic>)).toList()
    );
  }

  UserModelDTO copyWith({String? name, String? peerId, String? username, DateTime? lastLogged, List<GameModelDTO>? games}){
    return UserModelDTO(
        id: id,
        peerId: peerId ?? this.peerId,
        name: name ?? this.name,
        username: username ?? this.username,
        lastLogged: lastLogged ?? this.lastLogged,
        games: games ?? this.games
    );
  }
}
class UserModelController extends Model{
  static const String NEW_USER_SUCCESS_MSG = "Cadastro concluído: ";
  static const String NEW_USER_ERROR_MSG = "Falha ao cadastrar usuário!";
  List<UserModelDTO> allUsers = [];
  UserModelDTO? user;
  UserRepository userRepository =  GetIt.I.get();
  static UserModelController of(BuildContext context) => ScopedModel.of<UserModelController>(context);
  bool isLoading = false;

  //logar usuario atual ao abrir o app
  @override
  void addListener(VoidCallback listener) {
    super.addListener(listener);
    _loadCurrentUser();
  }

  void notify(){
    notifyListeners();
  }

  Future<void> signUp(
      {required name, required username, required BuildContext context, required Function onSuccess, required Function onFail}
      ) async {
    isLoading = true;
    notifyListeners();

    UserModelDTO userModelDTO = UserModelDTO(
        peerId: StringUtils().generateUUID(),
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

  Future<void> updateUser()async {
    isLoading = true;
    notifyListeners();
    userRepository.updateUser(user!);
    isLoading = false;
    notifyListeners();
  }

  getAllLocalUsers() async {
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

  Future<Null> deleteGame(String gameCode) async {
    /*isLoading = true;
    notifyListeners();
    var db = Firestore.instance;
    var batch = db.batch();
    QuerySnapshot query = await Firestore.instance.collection("games").document(gameCode).collection("players").getDocuments();

    //verifiry if the currety player.dart is the last at game wich ill be excluded
    if(query.documents.length ==1)
      batch.delete(db.collection("games").document(gameCode));
    batch.delete(db.collection("games").document(gameCode).collection("players").document(firebaseUser.uid));
    batch.delete(db.collection("users").document(firebaseUser.uid).collection("games").document(gameCode));

    return batch.commit().then((value){
      games.removeWhere((game) => game["gameCode"] == gameCode);
      isLoading = false;
      notifyListeners();
    }).catchError((e){
      isLoading = false;
      notifyListeners();
    });*/

  }

}