
import 'package:account_monopoly/domain/model/game_model_dto.dart';
import 'package:account_monopoly/provider/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';

import 'package:account_monopoly/dialogs/confirm_action_dialog.dart';
import 'package:account_monopoly/provider/game_provider.dart';
import 'package:account_monopoly/utils/string_utils.dart';
import 'package:account_monopoly/screens/game_screen.dart';


class MyGamesScreen extends StatelessWidget {


  final _scafoldKey = GlobalKey<ScaffoldState>();
  MyGamesScreen({super.key});

  @override
  Widget build(BuildContext context) {

    return Scaffold(
        key: _scafoldKey,
        appBar: AppBar(
          backgroundColor: Theme.of(context).primaryColor,
          title: const Text("Jogos Ativo", style: TextStyle(
            color: Colors.white,
              fontWeight: FontWeight.bold,
              letterSpacing: 2)),
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
        body: Consumer<UserProvider>(
          builder: (context, userProvider, Widget? child) {
            if(userProvider.isLoading){
              return const Center(child: CircularProgressIndicator());
            } else {
              return userProvider.user!.games.isNotEmpty ? ListView.builder(
                  padding: const EdgeInsets.all(10.0),
                  itemCount: userProvider.user!.games.length,
                  itemBuilder: (context, index) {
                    return _gameTile(context, userProvider.user!.games[index]);
                  }) : const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32.0),
                      child: Text(
                        "Você não tem jogos ativos no momento. Crie um novo jogo para começar!", 
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white70, // Cor clara para contraste no fundo preto
                          fontSize: 18.0,
                          fontWeight: FontWeight.w500
                        ),
                      ),
                    ),
                  );;
            }
          })
    );
  }

  Widget _gameTile(BuildContext context, GameModelDTO game){
    UserProvider userProvider = Provider.of<UserProvider>(context, listen: false);
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
              'Id: ${game.id}',
              style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Saldo atual: ${StringUtils.currencyFormat(game.player.currentCredit)} R\$",
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
                        Provider.of<GameProvider>(context, listen: false).getGameById( onFail: _onFail, onSuccess: _onSuccess, gameModelDTO: game);
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
                      onPressed: () async {
                        showDialog(context: context, builder: (BuildContext context){
                          return ConfirmActionDialog(title: "Alerta de Exclusão!", textContent: "As informações referentes a essa partida "
                              "serão excluídas permanentemente", onConfirm: () async {
                            userProvider.deleteGame(game.id);
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
    Navigator.pushReplacement(_scafoldKey.currentState!.context, MaterialPageRoute(builder: (context) => const GameScreen()));
        //.then((value) => GameModel.of(_scafoldKey.currentState!.context).exitGame());
  }
}
