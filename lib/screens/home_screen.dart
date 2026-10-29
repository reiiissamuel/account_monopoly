import 'dart:async';
import 'dart:developer';

import 'package:account_monopoly/dialogs/new_user_dialog.dart';
import 'package:account_monopoly/dialogs/tip_alert_dialog.dart';
import 'package:account_monopoly/exception/game_not_exists_exception.dart';
import 'package:account_monopoly/provider/game_provider.dart';
import 'package:account_monopoly/screens/game_screen.dart';
import 'package:account_monopoly/screens/my_games_screen.dart';
import 'package:account_monopoly/screens/all_properties_versions_screen.dart';
import 'package:account_monopoly/utils/tips_resourse.dart';
import 'package:flutter/material.dart';
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
  @override
  Widget build(BuildContext context) {
    return Consumer<UserProvider>(
      builder: (context, userProvider, child) {
        return PopScope(
          canPop: false,
          child: Scaffold(
            appBar: AppBar(
              backgroundColor: Theme.of(context).primaryColor,
              title: Text(
                "Meu Monopólio",
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onInverseSurface,
                  fontWeight: FontWeight.bold,
                ),
              ),
              centerTitle: true,
              automaticallyImplyLeading: false,
              actions: <Widget>[
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8.0,
                    vertical: 16.0,
                  ),
                  child: GestureDetector(
                    child: Icon(
                      Icons.question_mark_rounded,
                      color: Theme.of(context).colorScheme.onInverseSurface,
                    ),
                    onTap: () => {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return const TipDialog(
                            tip: TipsResourse.HOME_SCREEN_TIP,
                            title: "Tela inicial",
                          );
                        },
                      ),
                    },
                  ),
                ),
              ],
            ),
            floatingActionButton: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 18.0,
                vertical: 16.0,
              ),
              child: userProvider.isLoggedIn()
                  ? IconButton(
                      icon: const Icon(Icons.supervised_user_circle_rounded),
                      color: Theme.of(context).colorScheme.onInverseSurface,
                      iconSize: 30,
                      onPressed: () => _userOptionsDialog(context),
                    )
                  : TextButton(
                      child: Text(
                        userProvider.allUsers.isEmpty
                            ? "Novo usuário"
                            : "Entrar",
                        style: TextStyle(
                          fontSize: 13.0,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onInverseSurface,
                        ),
                      ),
                      onPressed: () {
                        if (userProvider.allUsers.isEmpty) {
                          userProvider.signOut();
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return const NewUserDialog();
                            },
                          );
                        } else {
                          _showNonLoggedDialog(context);
                        }
                      },
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
                            child: Image.asset(
                              "icons/apptheme.png",
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(35.0),
                            topRight: Radius.circular(35.0),
                          ),
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                    ),
                  ],
                ),
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 40.0),
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
                                borderRadius: BorderRadius.circular(20.0),
                              ),
                              splashFactory: InkRipple.splashFactory,
                              shadowColor: Colors.black87,
                              elevation: 10,
                            ),
                            child: const Text(
                              "Novo Jogo",
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 20.0,
                                color: Colors.black,
                              ),
                            ),
                            onPressed: () {
                              if (!userProvider.isLoggedIn()) {
                                return _showNonLoggedDialog(context);
                              }
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => const NewGameScreen(),
                                ),
                              );
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
                              backgroundColor: Theme.of(context).primaryColor,
                              splashFactory: InkRipple.splashFactory,
                              shadowColor: Colors.black87,
                              elevation: 10,
                            ),
                            child: Text(
                              "Entrar com Código",
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 15.0,
                                color: Theme.of(context).colorScheme.onInverseSurface,
                              ),
                            ),
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
                                borderRadius: BorderRadius.circular(20.0),
                              ),
                              backgroundColor: Theme.of(context).primaryColor,
                              splashFactory: InkRipple.splashFactory,
                              shadowColor: Colors.black87,
                              elevation: 10,
                            ),
                            child: Text(
                              "Jogos Ativos",
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 20.0,
                                color: Theme.of(context).colorScheme.onInverseSurface,
                              ),
                            ),
                            onPressed: () {
                              if (!userProvider.isLoggedIn()) {
                                return _showNonLoggedDialog(context);
                              }
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => MyGamesScreen(),
                                ),
                              );
                            },
                          ),
                        ),
                        SizedBox(
                          height: 50.0,
                          width: 200.0,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20.0),
                              ),
                              backgroundColor: Theme.of(context).primaryColor,
                              splashFactory: InkRipple.splashFactory,
                              shadowColor: Colors.black87,
                              elevation: 10,
                            ),
                            child: Text(
                              "Propriedades",
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 20.0,
                                color: Theme.of(context).colorScheme.onInverseSurface,
                              ),
                            ),
                            onPressed: () {
                              if (!userProvider.isLoggedIn()) {
                                return _showNonLoggedDialog(context);
                              }
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      AllPropertiesVesionsScreen(),
                                ),
                              );
                            },
                          ),
                        ),
                        // Seletor de cores do tema integrado abaixo dos botões
                        Container(
                          height: 50.0,
                          width: 200.0,
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.6),
                            borderRadius: BorderRadius.circular(20.0),
                            border: Border.all(
                              color: Theme.of(
                                context,
                              ).primaryColor.withValues(alpha: 0.5),
                              width: 1.5,
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children:
                                const [
                                  Color(0xFF5f7887), // Azul acinzentado original
                                  Color(0xFFB71C1C), // Vermelho Pastel Escuro (ou Color(0xFFC62828))
                                  Color(0xFF2E7D32), // Verde Pastel Escuro (ou Color(0xFF388E3C))
                                  Color(0xFFF57F17), // Amarelo/Dourado Pastel Escuro
                                  Color(0xFF6A1B9A), // Roxo Pastel Escuro (ou Color(0xFF7B1FA2))
                                  Color(0xFFE65100), // Laranja Pastel Escuro (ou Color(0xFFEF6C00))
                                  Color(0xFF558B2F), // Outro Verde Pastel Escuro (Tom Oliva)
                                  Color(0xFF4527A0), // Outro Roxo Pastel Escuro (Tom Índigo/Lavanda profunda)
                                  Color(0xFF37474F), // Cinza Pastel Escuro (Slate escuro)
                                ].map((color) {
                                  final bool isSelected =
                                      userProvider.user?.primaryColorValue ==
                                      color.toARGB32();
                                  return GestureDetector(
                                    onTap: () {
                                      userProvider.updatePrimaryColor(color);
                                    },
                                    child: Container(
                                      width: 20.0,
                                      height: 20.0,
                                      decoration: BoxDecoration(
                                        color: color,
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: isSelected
                                              ? Colors.white
                                              : Colors.transparent,
                                          width: 2.0,
                                        ),
                                        boxShadow: isSelected
                                            ? [
                                                const BoxShadow(
                                                  color: Colors.white54,
                                                  blurRadius: 4,
                                                ),
                                              ]
                                            : [],
                                      ),
                                    ),
                                  );
                                }).toList(),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                if (userProvider.isLoading)
                  Container(
                    color: Colors.black54,
                    child: Center(
                      child: CircularProgressIndicator(
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showNonLoggedDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return const LoadUserDialog();
      },
    ).catchError((e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
      );
    });
  }

  void _showEnterCodeDialog(BuildContext context) {
    final controller = TextEditingController();
    if (Provider.of<GameProvider>(context, listen: false).gameModelDTO !=
        null) {
      Provider.of<GameProvider>(context, listen: false).cleanGameData();
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          backgroundColor: Colors.black,
          title: const Text(
            "Insira o código",
            style: TextStyle(color: Colors.white),
          ),
          content: TextField(
            controller: controller,
            autofocus: true,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w500,
              fontSize: 20.0,
            ),
            decoration: InputDecoration(
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: Theme.of(context).primaryColor,
                  width: 3.0,
                ),
              ),
              focusedBorder: const OutlineInputBorder(
                borderSide: BorderSide(color: Colors.white, width: 5.0),
                borderRadius: BorderRadius.all(Radius.circular(20)),
              ),
              helperText: "Código",
              helperStyle: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w500,
                fontSize: 13.0,
              ),
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text(
                "Cancelar",
                style: TextStyle(fontSize: 17.0, color: Colors.white),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text(
                "Prosseguir",
                style: TextStyle(fontSize: 17.0, color: Colors.white),
              ),
              onPressed: () async {
                final navigator = Navigator.of(context);
                final scaffoldMessenger = ScaffoldMessenger.of(context);
                navigator.pop();

                try {
                  var gameProvider = Provider.of<GameProvider>(
                    context,
                    listen: false,
                  );
                  gameProvider.userModelController = Provider.of<UserProvider>(
                    context,
                    listen: false,
                  );
                  await gameProvider.enterGameRequest(
                    destinationPeerId: controller.text,
                  );
                  navigator.pushReplacement(
                    MaterialPageRoute(builder: (context) => const GameScreen()),
                  );
                } on GameNotExistsException catch (g) {
                  scaffoldMessenger.showSnackBar(
                    SnackBar(
                      content: Text(g.toString()),
                      backgroundColor: Colors.red,
                    ),
                  );
                } on TimeoutException catch (e) {
                  scaffoldMessenger.showSnackBar(
                    SnackBar(
                      content: Text(e.toString()),
                      backgroundColor: Colors.red,
                    ),
                  );
                } catch (e) {
                  log(e.toString());
                  scaffoldMessenger.showSnackBar(
                    SnackBar(
                      content: Text(e.toString()),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }

  void _userOptionsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.black,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
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
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(
                  height: 50.0,
                  width: 200.0,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                    ),
                    child: const Text(
                      "Usar outra conta",
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                    ),
                    onPressed: () async {
                      await Provider.of<UserProvider>(
                        context,
                        listen: false,
                      ).signOut();
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
                    child: const Text(
                      "Log Out",
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                    ),
                    onPressed: () {
                      Provider.of<UserProvider>(
                        context,
                        listen: false,
                      ).signOut();
                      Navigator.of(context).pop();
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
