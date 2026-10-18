import 'package:account_monopoly/provider/game_provider.dart';
import 'package:account_monopoly/provider/user_provider.dart';
import 'package:account_monopoly/screens/game_screen.dart';
import 'package:account_monopoly/screens/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:account_monopoly/configuration/init_db.dart';
import 'dart:async';

void main() {
  // Envolve a execução do app na zona protegida contra erros assíncronos de terceiros
  runZonedGuarded(() {
    WidgetsFlutterBinding.ensureInitialized();
    runApp(const AccountmonopolyApp());
  }, (error, stackTrace) {
    // --- FILTRO DO ERRO DO PEERDART ---
    // Se o erro for o fecho abrupto de stream do WebRTC/Peerdart, ignoramos silenciosamente
    if (error.toString().contains("Cannot add new events after calling close") &&
        error.toString().contains("peerdart")) {
      return; 
    }
    // Para qualquer outro erro legítimo da sua aplicação, imprime normalmente no console
    debugPrint('Erro assíncrono capturado: $error');
    debugPrintStack(stackTrace: stackTrace);
  });
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
      systemNavigationBarColor: Color.fromARGB(255, 70, 130, 180),
    ));

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => UserProvider()),
        ChangeNotifierProxyProvider<UserProvider, GameProvider>(
          create: (context) => GameProvider(
            userModelController: Provider.of<UserProvider>(context, listen: false),
          ),
          update: (context, userProvider, gameProvider) => 
            gameProvider ?? GameProvider(userModelController: userProvider),
        )
      ],
      child: MaterialApp(
        title: 'Account Monopoly',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          primaryColor: const Color(0xFF5f7887),
        ),
        debugShowCheckedModeBanner: false,
        routes: {
          'gameScreen': (context) => const GameScreen(),
        },
        home: const SplashScreen(),
      ),
    );
  }
}