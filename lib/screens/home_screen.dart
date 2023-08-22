import 'package:account_monopoly/dialogs/new_user_dialog.dart';
import 'package:account_monopoly/screens/my_games_screen.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:scoped_model/scoped_model.dart';

import '../dialogs/load_user_dialog.dart';
import '../model/game_model.dart';
import '../model/user_model.dart';
import 'new_game_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {

  List<String> localUsers = [];

  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant<UserModelController>(
      builder: (context, child, model) {
        if(model.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        return WillPopScope(
            onWillPop: () async => false,
            child: Scaffold(
              appBar: AppBar(
                  title: const Text("Home"),
                  centerTitle: true,
                  automaticallyImplyLeading: false,
                  actions: <Widget>[
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 16.0),
                      child: model.isLoggedIn()
                          ? GestureDetector(
                          child: Row(
                            children: <Widget>[
                              const Icon(Icons.person),
                              Text(model.user!.username)
                            ],
                          ),
                          onTap: () => _userOptionsDialog(context))
                          : GestureDetector(
                            child: Text(
                                model.allUsers.isEmpty
                                    ? "Novo usuário"
                                    : "Entrar",
                                style: const TextStyle(
                                fontSize: 17.0, fontWeight: FontWeight.bold)
                            ),
                            onTap: () {
                              if(model.allUsers.isEmpty){
                                model.signOut();
                                showDialog(context: context, builder: (BuildContext context){
                                  return const NewUserDialog();
                                });
                              } else {
                                model.getAllLocalUsers();
                                showDialog(context: context, builder: (BuildContext context){
                                  return const LoadUserDialog();
                                }
                            );
                              }
                            }
                          ),
                    ),
                  ]
                    ),
              backgroundColor: Colors.black,
              body: Stack(
                children: <Widget>[
                  Column(
                    children: <Widget>[
                      Expanded(
                        flex: 1,
                        child: Container(
                          color: Colors.black,
                          child: Center(
                              child: SizedBox(
                                height: 60.0,
                                width: 60.0,
                                child: Image.asset("icons/apptheme.png",
                                    fit: BoxFit.cover),
                              )),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: const BorderRadius.only(topLeft: Radius.circular(35.0), topRight: Radius.circular(35.0)),
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                      )
                    ],
                  ),
                  Center(
                      child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 100.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: <Widget>[
                              SizedBox(
                                height: 50.0,
                                width: 200.0,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Theme.of(context).primaryColor,
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(20.0)
                                    ),
                                    splashFactory: InkRipple.splashFactory,
                                  ),
                                  child: const Text("Criar novo jogo",
                                      style: TextStyle(
                                          fontWeight: FontWeight.w500,
                                          fontSize: 20.0,
                                        color: Colors.white
                                      )),
                                  onPressed: () {
                                    if (!model.isLoggedIn()) {
                                      return _showNonLoggedDialog(context);
                                    }
                                   // Navigator.of(context).push(MaterialPageRoute(builder: (context) => NewGameScreen()));
                                  },
                                ),
                              ),
                              SizedBox(
                                height: 50.0,
                                width: 200.0,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(20.0)
                                    ),
                                    backgroundColor: Colors.black,
                                    splashFactory: InkRipple.splashFactory,
                                  ),
                                  child: const Text("Entrar com código",
                                      style: TextStyle(
                                          fontWeight: FontWeight.w500,
                                          fontSize: 20.0,
                                          color: Colors.white)),
                                  onPressed: () {
                                    if (!model.isLoggedIn()) {
                                      return _showNonLoggedDialog(context);
                                    }
                                    return _showEnterCodeDialog(context);
                                  },
                                ),
                              ),
                              SizedBox(
                                  height: 50.0,
                                  width: 200.0,
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(20.0)
                                      ),
                                      backgroundColor: Colors.black,
                                      splashFactory: InkRipple.splashFactory,
                                    ),
                                    child: const Text("Jogos ativos",
                                        style: TextStyle(
                                            fontWeight: FontWeight.w500,
                                            fontSize: 20.0,
                                            color: Colors.white)),
                                    onPressed: () {
                                      if (!model.isLoggedIn()) {
                                        return _showNonLoggedDialog(context);
                                      }
                                      //Navigator.push(context, MaterialPageRoute(builder: (context) => MyGamesScreen()));
                                    },
                                  ))
                            ],
                          )))
                ],
              ),
            ));
      },
    );
  }

  _showNonLoggedDialog(BuildContext context) {
    showDialog(context: context,
      builder: (BuildContext context) {
        return const LoadUserDialog();
      },
    );
  }

  _showEnterCodeDialog(BuildContext context) {
    final controller = TextEditingController();

    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0)),
            backgroundColor: Colors.black,
            title:
            const Text("Insira o código!", style: TextStyle(color: Colors.white)),
            content: TextField(
                controller: controller,
                autofocus: true,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                    fontSize: 20.0),
                decoration: const InputDecoration(
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(20))),
                    helperText: "Código",
                    helperStyle: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                        fontSize: 13.0))),
            actions: <Widget>[
              TextButton(
                child: const Text("Cancelar", style: TextStyle(fontSize: 17.0)),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              TextButton(
                child: const Text("Prosseguir", style: TextStyle(fontSize: 17.0)),
                onPressed: () {
                  //GameModel.of(context).enterNewGameById(gameCode: controller.text, onFail: _onFail, onSuccess: _onSuccess);
                },
              ),
            ],
          );
        });
  }

  _userOptionsDialog(BuildContext context) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return Dialog(
            backgroundColor: Colors.black,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0)),
            child: Container(
              height: 300.0,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  const Text(
                    "Opções",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 18.0,
                        fontWeight: FontWeight.w500),
                  ),
                  SizedBox(
                    height: 50.0,
                    width: 200.0,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).primaryColor,
                      ),
                      child: const Text("Usar outra conta",
                          style: TextStyle(
                              fontWeight: FontWeight.w500,
                              color: Colors.white)),
                      onPressed: () async {
                        await UserModelController.of(context).signOut();
                        Navigator.of(context).pop();
                        _showNonLoggedDialog(context);
                      },
                    ),
                  ),
                  SizedBox(
                    height: 50.0,
                    width: 200.0,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).primaryColor,
                      ),
                      child: const Text("Log Out",
                          style: TextStyle(
                              fontWeight: FontWeight.w500,
                              color: Colors.white)),
                      onPressed: () {
                        UserModelController.of(context).signOut();
                        Navigator.of(context).pop();
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        });
  }

  void _onFail(String msg){
    Navigator.of(context).pop();
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

  void _onSuccess(){
    //Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => GameScreen())).then((value) => GameModel.of(context).exitGame());;
  }

}
