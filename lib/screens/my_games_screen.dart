
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:scoped_model/scoped_model.dart';

import '../dialogs/confirm_action_dialog.dart';
import '../model/game_model.dart';
import '../model/user_model.dart';
import '../utils/string_utils.dart';


class MyGamesScreen extends StatelessWidget {


  final _scafoldKey = GlobalKey<ScaffoldState>();

  MyGamesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant<UserModelController>(
      builder: (context, child, model) {
        if (model.isLoading && GameModelController.of(context).isLoading) return const Center(child: CircularProgressIndicator());
        return Scaffold(
            key: _scafoldKey,
            appBar: AppBar(
              title: const Text("Jogos Ativo", style: TextStyle(letterSpacing: 2)),
              centerTitle: true,
              actions: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 16.0),
                  child: GestureDetector(
                      child: const Icon(Icons.question_mark_rounded, color: Colors.white),
                      onTap: () => {}))
              ],
            ),
            backgroundColor: Colors.black,
            body: model.user?.games != null || model.user!.games.isNotEmpty
                ?
            ListView.builder(
                padding: const EdgeInsets.all(10.0),
                itemCount: model.user!.games.length,
                itemBuilder: (context, index) {
                  return _gameTile(context, model.user!.games[index]);
                })
                :
            Center(
              child: Icon(Icons.save, color: Theme.of(context).primaryColor, size: 100.0),
            )
        );
      },
    );
  }

  Widget _gameTile(BuildContext context, GameModelDTO game){

    return Container(
      margin: const EdgeInsets.only(bottom: 8.0),
      height: 210.0,
      decoration: const BoxDecoration(
        color:  Color(0xff0087a8),
        borderRadius: BorderRadius.all(Radius.circular(15.0)),
      ),
      child: Container(
        padding: const EdgeInsets.all(20.0),
        margin: const EdgeInsets.all(10.0),
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.all(Radius.circular(15.0)),
          color: Theme.of(context).primaryColor,
        ),
        child: Stack(
          children: <Widget>[
            Text(
              'Criador: ${game.player.username}',
              style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Saldo Inicial: ${StringUtils.currencyFormat(game.initalGameBalance.toString())} R\$",
                style: const TextStyle(color: Colors.white, fontSize: 20.0),
              ),
            ),
            Align(
                alignment: Alignment.bottomRight,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        shape: const CircleBorder(),
                        backgroundColor: Colors.white,
                      ),
                      onPressed: () {
                        GameModelController.of(context).getGameById( onFail: _onFail, onSuccess: _onSuccess, gameModelDTO: game);
                      },
                      child: const Icon(
                        Icons.arrow_forward,
                        color: Colors.green,
                        size: 50.0,
                      ),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        shape: const CircleBorder(),
                        backgroundColor: Colors.white,
                      ),
                      onPressed: () {
                        showDialog(context: context, builder: (BuildContext context){
                          return ConfirmActionDialog(title: "Alerta de Exclusão!", textContent: "As informações referentes a essa partida "
                              "serão excluídas permanentemente", onConfirm: () async {
                            UserModelController.of(context).deleteGame(game.id);
                            Navigator.pop(context);
                          });
                        });
                      },
                      child: const Icon(
                        Icons.delete,
                        color: Colors.red,
                        size: 50.0,
                      ),
                    ),
                  ],
                )
            )
          ],
        ),
      ),
    );
  }

  void _onFail(String msg){
    Navigator.of(_scafoldKey.currentState!.context).pop();
    Fluttertoast.showToast(
        msg: msg,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 2,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0
    );
  }

  Future<void> _onSuccess() async {
    Navigator.of(_scafoldKey.currentState!.context).pop();
    //Navigator.pushReplacement(_scafoldKey.currentState!.context, MaterialPageRoute(builder: (context) => GameScreen()))
     //   .then((value) => GameModel.of(_scafoldKey.currentState!.context).exitGame());
  }
}
