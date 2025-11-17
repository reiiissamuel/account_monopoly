import 'package:account_monopoly/provider/game_provider.dart';
import 'package:account_monopoly/provider/user_provider.dart';
import 'package:account_monopoly/screens/game_screen.dart';
import 'package:account_monopoly/screens/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:account_monopoly/configuration/init_db.dart';


void main() {
  runApp(const AccountmonopolyApp());
}

class AccountmonopolyApp extends StatefulWidget {
  const AccountmonopolyApp({super.key});

  @override
  AccountmonopolyAppState createState() => AccountmonopolyAppState();
}

class AccountmonopolyAppState extends State<AccountmonopolyApp> {

  final Future _init = InitDb.initialize();

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      //statusBarColor: Color.fromARGB(255, 70, 130, 180), //or set color with: Color(0xFF0000FF)
      systemNavigationBarColor: Color.fromARGB(255, 70, 130, 180),
      //systemNavigationBarDividerColor: Colors.white,
    ));

    /*return MaterialApp(
                          title: 'Account Monopoly',
                          theme: ThemeData(
                            primarySwatch: Colors.blue,
                            primaryColor: const Color.fromARGB(
                                255, 70, 130, 180),
                          ),
                          debugShowCheckedModeBanner: false,
                          home: ConnectionExample() //SplashScreen(),
                      );*/

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => UserProvider()),
        ChangeNotifierProvider(create: (context) => GameProvider())
      ],
      child: MaterialApp(
        title: 'Account Monopoly',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          primaryColor: const Color(0xFF4682B4),
        ),
        debugShowCheckedModeBanner: false,
        routes: {
          'gameScreen': (context) => const GameScreen(),
        },
        home: const SplashScreen(),
      )
    );
  }
}

