import 'package:account_monopoly/model/user_model.dart';
import 'package:account_monopoly/screens/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:account_monopoly/configuration/init_db.dart';

import 'model/game_model.dart';

void main() {
  runApp(AccountmonopolyApp());
}

class AccountmonopolyApp extends StatefulWidget {
  @override
  _AccountmonopolyAppState createState() => _AccountmonopolyAppState();
}

class _AccountmonopolyAppState extends State<AccountmonopolyApp> {

  final Future _init = InitDb.initialize();

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      //statusBarColor: Color.fromARGB(255, 70, 130, 180), //or set color with: Color(0xFF0000FF)
      systemNavigationBarColor: Color.fromARGB(255, 70, 130, 180),
      //systemNavigationBarDividerColor: Colors.white,
    ));

    return FutureBuilder(
      future: _init,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return ScopedModel<UserModelController>(
              model: UserModelController(),
              child: ScopedModelDescendant<UserModelController>(
                builder: (context, child, model) {
                  return ScopedModel(model: GameModelController(userModelController: model),
                      child: MaterialApp(
                          title: 'Account Monopoly',
                          theme: ThemeData(
                            primarySwatch: Colors.blue,
                            primaryColor: const Color.fromARGB(
                                255, 70, 130, 180),
                          ),
                          debugShowCheckedModeBanner: false,
                          home: SplashScreen() //SplashScreen(),
                      ));
                },
              ));
        } else {
          return const Material(
            child: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
      },
    );
  }
}