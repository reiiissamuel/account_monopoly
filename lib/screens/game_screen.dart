import 'dart:async';
import 'package:account_monopoly/dialogs/gamescreen_tutorial_dialog.dart';
import 'package:account_monopoly/dialogs/loan_dialog.dart';
import 'package:account_monopoly/dialogs/more_options_dialog.dart';
import 'package:account_monopoly/dialogs/pay_rent_dialog.dart';
import 'package:account_monopoly/domain/enums/event_type.dart';
import 'package:account_monopoly/domain/enums/tutorial_item_type.dart';
import 'package:account_monopoly/provider/user_provider.dart';
import 'package:account_monopoly/screens/game_balance_screen.dart';
import 'package:account_monopoly/screens/market_screen.dart';
import 'package:account_monopoly/screens/my_portfolio_screen.dart';
import 'package:account_monopoly/screens/player_summary_screen.dart';
import 'package:account_monopoly/utils/tutorial_manager.dart';
import 'package:flutter/material.dart';
import 'package:account_monopoly/dialogs/winner_dialog.dart';
import 'package:account_monopoly/utils/string_utils.dart';
import 'package:provider/provider.dart';

import 'package:account_monopoly/dialogs/chance_dialog.dart';
import 'package:account_monopoly/dialogs/confirm_action_dialog.dart';
import 'package:account_monopoly/dialogs/table_info_dialog.dart';
import 'package:account_monopoly/domain/model/chance.dart';
import 'package:account_monopoly/provider/game_provider.dart';
import 'package:account_monopoly/widgets/game_icon_button_builder.dart';
import 'package:account_monopoly/screens/beneficiaries_screen.dart';
import 'package:account_monopoly/screens/home_screen.dart';
import 'package:showcaseview/showcaseview.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  GameScreenState createState() => GameScreenState();
}

class GameScreenState extends State<GameScreen> {
  final TutorialManager _gameScreenTutorialManager = TutorialManager.game();
  int eventDeckCount = 0;
  List<Chance> _chances = [];

  bool _balanceVisibility = false;
  late UserProvider userProvider;

  @override
  void initState() {
    super.initState();

    Future.delayed(Duration.zero, () {
      final gameProvider = Provider.of<GameProvider>(context, listen: false);
      /*if (gameProvider.gameModelDTO!.chancesEnabled) {
        //_getAllEvents();
      }*/
    });
  }

  @override
  Widget build(BuildContext context) {
    userProvider = Provider.of<UserProvider>(context);

    // 1. PopScope na raiz mantido exatamente como você gosta
    return PopScope(
      canPop: false,
      child: ShowCaseWidget(
        builder: (showCaseContext) {
          return Consumer<GameProvider>(
            builder: (context, gameProvider, child) {
              if (gameProvider.gameModelDTO!.winner != null) {
                return const WinnerDialog();
              }

              if (!gameProvider.isGameScreenOnBoarded &&
                  !gameProvider.isLoading &&
                  !userProvider.isLoading) {
                  gameProvider.userModelController
                      .setOnBoardedOnScreen(isGameScreenOnBoarded: true);
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (mounted) {
                    _gameScreenTutorialManager.startTutorial(showCaseContext);
                  }
                });
              }

              return Scaffold(
                appBar: AppBar(
                  backgroundColor: Theme.of(context).primaryColor,
                  automaticallyImplyLeading: false,
                  title: Text(
                    "Painel ${gameProvider.currentPlayer.username}",
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    style: TextStyle(
                      letterSpacing: 2,
                      color: Theme.of(context).colorScheme.onInverseSurface,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  centerTitle: true,
                  leading: _gameScreenTutorialManager.buildShowcase(
                    type: TutorialItemType.broadcastTableId,
                    child: Center(
                      child: IconButton(
                        icon: Icon(
                          gameProvider.isHost
                              ? Icons.broadcast_on_personal_rounded
                              : Icons.broadcast_on_personal_outlined,
                          color: Theme.of(context).colorScheme.onInverseSurface,
                        ),
                        onPressed: () {
                          _dialogCaller(context, const TableInfoDialog());
                        },
                      ),
                    ),
                  ),
                  actions: <Widget>[
                    _gameScreenTutorialManager.buildShowcase(
                      type: TutorialItemType.roundViewer,
                      child: Center(
                        child: Text(
                          gameProvider.currentRound.toString(),
                          style: TextStyle(
                            fontSize: 18.0,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(
                              context,
                            ).colorScheme.onInverseSurface,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8.0),
                    _gameScreenTutorialManager.buildShowcase(
                      type: TutorialItemType.exitButton,
                      child: IconButton(
                        icon: Icon(
                          Icons.exit_to_app,
                          color: Theme.of(context).colorScheme.onInverseSurface,
                        ),
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return ConfirmActionDialog(
                                title: "Quer mesmo sair deste jogo?",
                                textContent:
                                    "Você poderá entrar nele novamete\n"
                                    "indo até a sessão 'jogos ativos'",
                                onConfirm: () async {
                                  // No botão de sair da UI:
                                  await Provider.of<GameProvider>(
                                    context,
                                    listen: false,
                                  ).leaveGame();
                                  Navigator.of(context).pushReplacement(
                                    MaterialPageRoute(
                                      builder: (context) => const HomeScreen(),
                                    ),
                                  );
                                },
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),

                floatingActionButton: _gameScreenTutorialManager.buildShowcase(
                  type: TutorialItemType.chanceButton,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 195.0),
                    child: FloatingActionButton(
                      backgroundColor: Theme.of(context).primaryColor,
                      shape: const CircleBorder(
                        side: BorderSide(color: Colors.black),
                      ),
                      onPressed: () {
                        if (gameProvider.gameModelDTO!.chancesEnabled) {
                          /*_dialogCaller(context, ConfirmActionDialog(title: "???", textContent: "Deseja pegar uma carta evento?", onConfirm:(){
                      Navigator.of(context).pop();
                      showDialog(context: context, builder: (BuildContext context){
                        if(_chances[eventDeckCount].isbenefit) {
                          gameProvider.gameModelDTO!.chances.add(_chances[eventDeckCount]);
                        }

                        if(_chances[eventDeckCount].effect! > 0) {
                          //gameProvider.gameModelDTO!.player.roundBalance.qtdEventGain += _chances[eventDeckCount].effect!;
                        } else if(_chances[eventDeckCount].effect! < 0){
                          //gameProvider.gameModelDTO!.player.roundBalance.qtdEventPay += (-_chances[eventDeckCount].effect!);
                        }
                        return ChanceDialog(_chances[eventDeckCount++]);
                      });
                    }));

                    if(eventDeckCount == _chances.length) {
                      eventDeckCount -= eventDeckCount;
                    }*/
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Os eventos estão desabilitados."),
                              backgroundColor: Colors.grey,
                            ),
                          );
                        }
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(5.0),
                        child: SizedBox(
                          height: 50.0,
                          width: 50.0,
                          child: Image.asset(
                            "icons/events.png",
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                backgroundColor: Colors.black,
                body: Stack(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8.0,
                        vertical: 16.0,
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                flex: 2,
                                child: _gameScreenTutorialManager.buildShowcase(
                                  type: TutorialItemType.balanceViewer,
                                  child: Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    children: [
                                      !_balanceVisibility
                                          ? Text(
                                              "\$ * * * * *",
                                              style: TextStyle(
                                                fontSize: 25,
                                                letterSpacing: 2,
                                                color: Theme.of(
                                                  context,
                                                ).primaryColor,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            )
                                          : FittedBox(
                                              fit: BoxFit
                                                  .scaleDown, // Tenta ajustar o tamanho, mas mantém o alinhamento
                                              child: Text(
                                                StringUtils.currencyFormat(
                                                  gameProvider
                                                      .currentPlayer
                                                      .currentCredit,
                                                ),
                                                maxLines:
                                                    1, // Garantindo que não quebre linha
                                                style: TextStyle(
                                                  fontSize: 27.0,
                                                  color: _creditSituationColor(
                                                    gameProvider
                                                        .currentPlayer
                                                        .currentCredit,
                                                    gameProvider
                                                        .gameModelDTO!
                                                        .initalGameCredit,
                                                  ),
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ),
                                      IconButton(
                                        icon: Icon(
                                          _balanceVisibility
                                              ? Icons.visibility_off
                                              : Icons.visibility,
                                          size: 25,
                                          color: Theme.of(context).primaryColor,
                                        ),
                                        onPressed: () {
                                          setState(() {
                                            _balanceVisibility =
                                                !_balanceVisibility;
                                          });
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 2,
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  spacing: 3,
                                  children: [
                                    _gameScreenTutorialManager.buildShowcase(
                                      type: TutorialItemType.analysisButton,
                                      child: ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              20.0,
                                            ),
                                          ),
                                          backgroundColor: Theme.of(
                                            context,
                                          ).primaryColor,
                                        ),
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  const GameBalanceScreen(),
                                            ),
                                          );
                                        },
                                        child: Text(
                                          "Gráficos",
                                          style: TextStyle(
                                            fontSize: 17.0,
                                            color: Theme.of(
                                              context,
                                            ).colorScheme.onInverseSurface,
                                            letterSpacing: 2.0,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    ),
                                    _gameScreenTutorialManager.buildShowcase(
                                      type: TutorialItemType.instructionsTable,
                                      child: ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              20.0,
                                            ),
                                          ),
                                          backgroundColor: Theme.of(
                                            context,
                                          ).primaryColor,
                                        ),
                                        child: Text(
                                          "Manual de utilidade",
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            fontSize: 17.0,
                                            color: Theme.of(
                                              context,
                                            ).colorScheme.onInverseSurface,
                                            letterSpacing: 2.0,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        onPressed: () async {
                                          _dialogCaller(
                                            context,
                                            const GameScreenTutorialDialog(),
                                          );
                                          //gameProvider.eventComposer(type: EventType.closeTurn);
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),

                          Wrap(
                            crossAxisAlignment: WrapCrossAlignment.center,
                            alignment: WrapAlignment.spaceBetween,
                            children: [
                              _gameScreenTutorialManager.buildShowcase(
                                type: TutorialItemType.goMarketButton,
                                child: GameIconButtonBuilder(
                                  imgPath: "icons/buy.png",
                                  title: "Comprar",
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const MarketScreen(),
                                      ),
                                    );
                                  },
                                ),
                              ),

                              _gameScreenTutorialManager.buildShowcase(
                                type: TutorialItemType.goMyPortfolioButton,
                                child: GameIconButtonBuilder(
                                  imgPath: "icons/wallet.png",
                                  title: "Minha carteira",
                                  textFontSize: 13,
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            MyPortfolioScreen(),
                                      ),
                                    );
                                  },
                                ),
                              ),

                              _gameScreenTutorialManager.buildShowcase(
                                type: TutorialItemType.goPlayersButton,
                                child: GameIconButtonBuilder(
                                  imgPath: "icons/pay.png",
                                  textFontSize: 13,
                                  title: "Jogador",
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const BeneficiariesScreen(),
                                      ),
                                    );
                                  },
                                ),
                              ),

                              _gameScreenTutorialManager.buildShowcase(
                                type: TutorialItemType.goPayRentButton,
                                child: GameIconButtonBuilder(
                                  imgPath: "icons/rent.png",
                                  textFontSize: 13,
                                  title: "Aluguel",
                                  onPressed: () => _dialogCaller(
                                    context,
                                    PayRentDialog(
                                      properties: gameProvider
                                          .ledger
                                          .properties
                                          .values
                                          .toList(),
                                      provider: gameProvider,
                                    ),
                                  ),
                                ),
                              ),

                              _gameScreenTutorialManager.buildShowcase(
                                type:
                                    TutorialItemType.goMyFinancialHealthButton,
                                child: GameIconButtonBuilder(
                                  imgPath: "icons/client.png",
                                  textFontSize: 13,
                                  title: "Saúde Financeira",
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const PlayerSummaryScreen(),
                                      ),
                                    );
                                  },
                                ),
                              ),

                              _gameScreenTutorialManager.buildShowcase(
                                type: TutorialItemType.goLoanButton,
                                child: AbsorbPointer(
                                  // Se a condição for falsa, o AbsorbPointer impede qualquer clique/toque no botão
                                  absorbing:
                                      !(gameProvider
                                              .currentPlayer
                                              .portfolio
                                              .values
                                              .isNotEmpty &&
                                          gameProvider
                                              .gameModelDTO!
                                              .loanEnabled),
                                  child: Opacity(
                                    // Se estiver indisponível, fica com 40% de opacidade (opaco). Se disponível, 100% (1.0)
                                    opacity:
                                        (gameProvider
                                                .currentPlayer
                                                .portfolio
                                                .values
                                                .isNotEmpty &&
                                            gameProvider
                                                .gameModelDTO!
                                                .loanEnabled)
                                        ? 1.0
                                        : 0.4,
                                    child: GameIconButtonBuilder(
                                      imgPath: "icons/loan.png",
                                      title: "Empréstimo",
                                      onPressed: () => _dialogCaller(
                                        context,
                                        const LoanDialog(),
                                      ),
                                    ),
                                  ),
                                ),
                              ),

                              _gameScreenTutorialManager.buildShowcase(
                                type: TutorialItemType.goMoreOptionsButton,
                                child: GameIconButtonBuilder(
                                  imgPath: "icons/more.png",
                                  title: "Mais",
                                  onPressed: () {
                                    _dialogCaller(
                                      context,
                                      const MoreOptionsDialog(),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),

                          Expanded(
                            child: _gameScreenTutorialManager.buildShowcase(
                              type: TutorialItemType.logScreen,
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20.0),
                                  color: Theme.of(context).primaryColor,
                                ),
                                padding: const EdgeInsets.all(8.0),
                                child: /*_streamBuilder,*/ ListView.builder(
                                  reverse: true,
                                  itemCount:
                                      gameProvider.gameModelDTO!.logs.length,
                                  itemBuilder: (context, index) {
                                    List r = gameProvider
                                        .gameModelDTO!
                                        .logs
                                        .reversed
                                        .toList();
                                    return Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(
                                          20.0,
                                        ),
                                        color: r[index].contains("Sua empresa")
                                            ? Colors.green
                                            : Colors.black,
                                      ),
                                      padding: const EdgeInsets.all(5.0),
                                      margin: const EdgeInsets.only(top: 5.0),
                                      child: Text(
                                        r[index],
                                        style: TextStyle(
                                          fontSize: 15.0,
                                          color:
                                              r[index].contains("Sua empresa")
                                              ? Colors.white
                                              : Colors.white,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (gameProvider.isLoading ||
                        userProvider.isLoading ||
                        gameProvider.gameModelDTO == null)
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
              );
            },
          );
        },
      ),
    );
  }

  Future _dialogCaller(BuildContext context, Widget dialog) {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return dialog;
      },
    );
  }

  Color _creditSituationColor(num value, double initialCredit) {
    if (value >= (initialCredit * .6)) {
      //60%
      return Colors.green;
    } else if (value >= (initialCredit * .5)) {
      return Colors.yellow;
    } else if (value >= (initialCredit * .3)) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }

  void _getAllEvents() {
    ChanceController chanceController = ChanceController();
    chanceController.getAllEvents().then((list) {
      setState(() {
        (_chances = list.cast()).shuffle();
      });
    });
  }
}
