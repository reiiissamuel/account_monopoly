import 'package:account_monopoly/provider/game_provider.dart';
import 'package:account_monopoly/provider/user_provider.dart';
import 'package:account_monopoly/screens/game_screen.dart';
import 'package:account_monopoly/screens/splash_screen.dart';
import 'package:account_monopoly/utils/configs_constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:account_monopoly/configuration/init_db.dart';
import 'dart:async';

void main() {
  runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();
    
    // 1. Garante que a inicialização do DB / GetIt ocorra ANTES de rodar o app
    await InitDb.initialize();

    runApp(const AccountmonopolyApp());
  }, (error, stackTrace) {
    if (error.toString().contains("Cannot add new events after calling close") &&
        error.toString().contains("peerdart")) {
      return; 
    }
    debugPrint('Erro assíncrono capturado: $error');
    debugPrintStack(stackTrace: stackTrace);
  });
}

class AccountmonopolyApp extends StatelessWidget {
  const AccountmonopolyApp({super.key});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      systemNavigationBarColor: Color.fromARGB(255, 70, 130, 180),
    ));

    return MultiProvider(
      providers: [
        // Se o seu UserProvider é obtido via GetIt, use GetIt.instance<UserProvider>()
        // Ou mantenha a instância limpa caso ele busque o repositório internamente:
        ChangeNotifierProvider(create: (context) => UserProvider()),
        
        ChangeNotifierProxyProvider<UserProvider, GameProvider>(
          create: (context) => GameProvider(
            userModelController: Provider.of<UserProvider>(context, listen: false),
          ),
          update: (context, userProvider, gameProvider) => 
            gameProvider ?? GameProvider(userModelController: userProvider),
        )
      ],
      child: Consumer<UserProvider>(
        builder: (context, userProvider, child) {
          final Color activePrimaryColor = userProvider.user != null
              ? Color(userProvider.user!.primaryColorValue)
              : const Color(ConfigsConstants.defaultPrimaryColorValue);

          return MaterialApp(
            title: 'Account Monopoly',
            theme: ThemeData(
              useMaterial3: true,
              colorScheme: ColorScheme.fromSeed(seedColor: activePrimaryColor),
              primaryColor: activePrimaryColor,
            ),
            debugShowCheckedModeBanner: false,
            routes: {
              'gameScreen': (context) => const GameScreen(),
            },
            home: const SplashScreen(),
          );
        },
      ),
    );
  }
}