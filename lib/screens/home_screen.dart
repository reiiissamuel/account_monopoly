import 'package:account_monopoly/dialogs/new_user_dialog.dart';
import 'package:account_monopoly/provider/game_provider.dart';
import 'package:account_monopoly/screens/my_games_screen.dart';
import 'package:account_monopoly/screens/all_properties_versions_screen.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';

import 'package:account_monopoly/dialogs/load_user_dialog.dart';
import 'package:account_monopoly/provider/user_provider.dart';
import 'package:account_monopoly/screens/new_game_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {

  List<String> localUsers = [];

  @override
  Widget build(BuildContext context) {
    if(Provider.of<UserProvider>(context).isLoading) {
      return Center(child: CircularProgressIndicator(color: Theme.of(context).primaryColor));
    }
    return Consumer<UserProvider>(
        builder: (context, userProvider, child){
          if(userProvider.isLoading){
            return CircularProgressIndicator(color: Theme.of(context).primaryColor);
          }
          return PopScope(
              canPop: false,
              child: Scaffold(
                appBar: AppBar(
                    backgroundColor: Theme.of(context).primaryColor,
                    title: const Text("Conta Móvel", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    centerTitle: true,
                    automaticallyImplyLeading: false,
                    actions: <Widget>[
                      Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 16.0),
                          child: GestureDetector(
                              child: const Icon(Icons.question_mark_rounded, color: Colors.white),
                              onTap: () => {
                              }))
                    ]
                ),
                floatingActionButton: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 16.0),
                  child: userProvider.isLoggedIn()
                      ? IconButton(
                    icon: const Icon(Icons.supervised_user_circle_rounded), color: Colors.white, iconSize: 30, onPressed: () => _userOptionsDialog(context),
                  )
                      : TextButton(
                      child: Text(
                          userProvider.allUsers.isEmpty
                              ? "Novo usuário"
                              : "Entrar",
                          style: const TextStyle(fontSize: 13.0, fontWeight: FontWeight.bold, color: Colors.white)
                      ),
                      onPressed: () {
                        if(userProvider.allUsers.isEmpty){
                          userProvider.signOut();
                          showDialog(context: context, builder: (BuildContext context){
                            return const NewUserDialog();
                          });
                        } else {
                          userProvider.getAllLocalUsers();
                          showDialog(context: context, builder: (BuildContext context){
                            return const LoadUserDialog();
                          }
                          );
                        }
                      }
                  ),
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
                                      backgroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(20.0)
                                      ),
                                      splashFactory: InkRipple.splashFactory,
                                      shadowColor: Theme.of(context).primaryColor,
                                      elevation: 10,
                                    ),
                                    child: const Text("Novo Jogo",
                                        style: TextStyle(
                                            fontWeight: FontWeight.w500,
                                            fontSize: 20.0,
                                            color: Colors.black
                                        )),
                                    onPressed: () {
                                      if (!userProvider.isLoggedIn()) {
                                        return _showNonLoggedDialog(context);
                                      }
                                      Navigator.of(context).push(MaterialPageRoute(builder: (context) => const NewGameScreen()));
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
                                      shadowColor: Theme.of(context).primaryColor,
                                      elevation: 10,
                                    ),
                                    child: const Text("Entrar com Código",
                                        style: TextStyle(
                                            fontWeight: FontWeight.w500,
                                            fontSize: 15.0,
                                            color: Colors.white)),
                                    onPressed: () {
                                      if (!userProvider.isLoggedIn()) {
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
                                        shadowColor: Theme.of(context).primaryColor,
                                        elevation: 10,
                                      ),
                                      child: const Text("Jogos Ativos",
                                          style: TextStyle(
                                              fontWeight: FontWeight.w500,
                                              fontSize: 20.0,
                                              color: Colors.white)),
                                      onPressed: () {
                                        if (!userProvider.isLoggedIn()) {
                                          return _showNonLoggedDialog(context);
                                        }
                                        Navigator.push(context, MaterialPageRoute(builder: (context) => MyGamesScreen()));
                                      },
                                    )),
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
                                        shadowColor: Theme.of(context).primaryColor,
                                      ),
                                      child: const Text("Propriedades",
                                          style: TextStyle(
                                              fontWeight: FontWeight.w500,
                                              fontSize: 20.0,
                                              color: Colors.white)),
                                      onPressed: () {
                                        if (!userProvider.isLoggedIn()) {
                                          return _showNonLoggedDialog(context);
                                        }
                                        Navigator.push(context, MaterialPageRoute(builder: (context) => AllPropertiesVesionsScreen()));
                                      },
                                    ))
                              ],
                            )))
                  ],
                ),
              ));
        });
  }

  void _showNonLoggedDialog(BuildContext context) {
    showDialog(context: context,
      builder: (BuildContext context) {
        return const LoadUserDialog();
      },
    );
  }

  void _showEnterCodeDialog(BuildContext context) {
    final controller = TextEditingController();

    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0)),
            backgroundColor: Colors.black,
            title:
            const Text("Insira o código", style: TextStyle(color: Colors.white)),
            content: TextField(
                controller: controller,
                autofocus: true,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                    fontSize: 20.0),
                decoration: InputDecoration(
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 3.0),
                    ),
                    focusedBorder: const OutlineInputBorder(
                        borderSide: BorderSide(
                            color: Colors.white, width: 5.0
                        ),
                        borderRadius: BorderRadius.all(Radius.circular(20))
                    ),
                    helperText: "Código",
                    helperStyle: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                        fontSize: 13.0))),
            actions: <Widget>[
              TextButton(
                child: const Text("Cancelar", style: TextStyle(fontSize: 17.0, color: Colors.white)),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              TextButton(
                child: const Text("Prosseguir", style: TextStyle(fontSize: 17.0, color: Colors.white)),
                onPressed: () {

                  Provider.of<GameProvider>(context, listen: false).enterNewGameByIdRequest(destinationPeerId: controller.text, context: context, onFail: _onFail, onSuccess: _onSuccess);
                },
              ),
            ],
          );
        });
  }

  void _userOptionsDialog(BuildContext context) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return Dialog(
            backgroundColor: Colors.black,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0)),
            child: SizedBox(
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
                        await Provider.of<UserProvider>(context, listen: false).signOut();
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
                        Provider.of<UserProvider>(context, listen: false).signOut();
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
    //Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => GameScreen())).then((value) => GameModel.of(context).exitGame());
  }

}
