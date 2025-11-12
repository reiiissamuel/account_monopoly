import 'dart:async';
import 'package:account_monopoly/dialogs/more_options_dialog.dart';
import 'package:account_monopoly/domain/enums/event_type.dart';
import 'package:account_monopoly/provider/user_provider.dart';
import 'package:account_monopoly/screens/market_screen.dart';
import 'package:account_monopoly/screens/my_portfolio_screen.dart';
import 'package:flutter/material.dart';
import 'package:account_monopoly/dialogs/winner_dialog.dart';
import 'package:account_monopoly/utils/string_utils.dart';
import 'package:provider/provider.dart';

import 'package:account_monopoly/dialogs/chance_dialog.dart';
import 'package:account_monopoly/dialogs/confirm_action_dialog.dart';
import 'package:account_monopoly/dialogs/custom_keyboard_dialog.dart';
import 'package:account_monopoly/dialogs/table_info_dialog.dart';
import 'package:account_monopoly/domain/model/chance.dart';
import 'package:account_monopoly/provider/game_provider.dart';
import 'package:account_monopoly/widgets/game_icon_button_builder.dart';
import 'package:account_monopoly/screens/beneficiaries_screen.dart';
import 'package:account_monopoly/screens/home_screen.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  GameScreenState createState() => GameScreenState();
}
//todo resolver limite de jogadores
//todo implementar dialog com dados da partida e menu
class GameScreenState extends State<GameScreen> {

  int eventDeckCount = 0;
  List<Chance> _chances = [];

  bool _balanceVisibility = false;

  late UserProvider userProvider;

  @override
  void initState() {
    super.initState();

    Future.delayed(Duration.zero, () {
      final gameProvider = Provider.of<GameProvider>(context, listen: false);
      if (gameProvider.gameModelDTO!.chancesEnabled) {
        //_getAllEvents();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    userProvider = Provider.of<UserProvider>(context);
    /*if(userProvider.user == null) {
      return const Center(child: CircularProgressIndicator());
    }*/
    return PopScope(
        canPop: false,
        child: Consumer<GameProvider>(builder: (context, gameProvider, child) {
          if (gameProvider.isLoading || userProvider.isLoading) {
            return Center(
                child: CircularProgressIndicator(
              color: Theme.of(context).primaryColor,
            ));
          }
          if (gameProvider.gameModelDTO!.winner != null) {
            return const WinnerDialog(); // return when context player is the winner
          }
          return Scaffold(
              appBar: AppBar(
                backgroundColor: Theme.of(context).primaryColor,
                automaticallyImplyLeading: false,
                title: const Text(
                  "My Mobile Bank",
                  style: TextStyle(
                      letterSpacing: 2,
                      color: Colors.white,
                      fontWeight: FontWeight.bold),
                ),
                centerTitle: true,
                leading: Center(
                  child: IconButton(
                          icon: const Icon(Icons.broadcast_on_personal_rounded,
                              color: Colors.green),
                          onPressed: () {
                            _dialogCaller(context, const TableInfoDialog());
                          },
                        )
                ),
                actions: <Widget>[
                  Center(
                    child: Text(
                      gameProvider.gameModelDTO!.currentRound.toString(),
                      style: const TextStyle(
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                  ),
                  const SizedBox(width: 8.0),
                  IconButton(
                    icon: const Icon(Icons.exit_to_app),
                    onPressed: () {
                      showDialog(context: context, builder:(BuildContext context){
                        return ConfirmActionDialog(
                            title: "Quer mesmo sair deste jogo?",
                            textContent: "Você poderá entrar nele novamete\n"
                            "indo até a sessão 'jogos ativos'",
                            onConfirm: (){
                              Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => const HomeScreen()));
                            }
                        );
                      });
                    },
                  )
                ],
              ),

                      floatingActionButton: gameProvider.gameModelDTO!.chancesEnabled ? Padding(
                        padding: const EdgeInsets.only(bottom: 195.0),
                        child: FloatingActionButton(
                          backgroundColor: Theme.of(context).primaryColor,
                          shape:const CircleBorder(
                              side: BorderSide(color: Colors.black)
                          ),
                          onPressed: (){
                            _dialogCaller(context, ConfirmActionDialog(title: "???", textContent: "Deseja pegar uma carta evento?", onConfirm:(){
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
                            }
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(5.0),
                            child: SizedBox(
                              height: 50.0,
                              width: 50.0,
                              child: Image.asset("icons/events.png",
                                  fit: BoxFit.contain),
                            ),
                          ),
                        ),
                      ) : null,

                     backgroundColor: Colors.black,
                      body: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 16.0),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  flex: 2,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                                    children: [
                                      !_balanceVisibility
                                          ?
                                      Text(
                                        "\$ * * * * *",
                                        style: TextStyle(fontSize: 25, letterSpacing: 2, color: Theme.of(context).primaryColor, fontWeight: FontWeight.bold),
                                      )
                                      :
                                      Text(
                                        StringUtils.currencyFormat(gameProvider.currentPlayer.currentCredit),
                                        style: TextStyle(
                                            fontSize: 27.0,
                                            color: _creditSituationColor(gameProvider.currentPlayer.currentCredit, gameProvider.gameModelDTO!.initalGameCredit),
                                            fontWeight: FontWeight.w500),
                                      ),
                                      IconButton(
                                          icon: Icon(_balanceVisibility ? Icons.visibility_off : Icons.visibility, size: 25, color: Theme.of(context).primaryColor),
                                          onPressed: (){
                                        setState(() {
                                          _balanceVisibility = !_balanceVisibility;
                                        });
                                      })
                                    ],
                                  )
                                ),
                                Expanded(
                                    flex: 2,
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.stretch,
                                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                                      spacing: 3,
                                      children: [
                                        ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(20.0)
                                            ),
                                            backgroundColor: Theme.of(context).primaryColor
                                          ),
                                          onPressed: (){
                                            //Navigator.push(context, MaterialPageRoute(builder: (context) => const MortgageScreen()));
                                          },
                                          child: const Text(
                                            "Gráficos",
                                            style: TextStyle(fontSize: 17.0, color: Colors.white, letterSpacing: 2.0, fontWeight: FontWeight.w500),
                                          ),
                                        ),
                                        ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(20.0)
                                            ),
                                            backgroundColor: Theme.of(context).primaryColor
                                          ),
                                          child: const Text(
                                              "Fechar turno", textAlign: TextAlign.center,
                                              style: TextStyle(fontSize: 17.0, color: Colors.white, letterSpacing: 2.0, fontWeight: FontWeight.w500)
                                          ),
                                          onPressed: () async {
                                            gameProvider.eventComposer(type: EventType.closeTurn);
                                          },
                                        )
                                      ],
                                    )
                                )
                              ],
                            ),

                            Wrap(
                              crossAxisAlignment: WrapCrossAlignment.center,
                              alignment: WrapAlignment.spaceBetween,
                              children: [
                                GameIconButtonBuilder(
                                  imgPath: "icons/buy.png",
                                  title: "Comprar", 
                                  onPressed: (){
                                    Navigator.push(context, MaterialPageRoute(builder: (context) => const MarketScreen()));
                                  }
                                ),

                                GameIconButtonBuilder(
                                  imgPath: "icons/wallet.png",  
                                  title: "Minha carteira", 
                                  onPressed: (){
                                    Navigator.push(context, MaterialPageRoute(builder: (context) => const MyPortfolioScreen()));
                                  }
                                ),

                                GameIconButtonBuilder(
                                  imgPath: "icons/pay.png",  
                                  title: "Transferir", 
                                  onPressed: (){
                                    Navigator.push(context, MaterialPageRoute(builder: (context) => const BeneficiariesScreen()));
                                  }
                                ),

                                GameIconButtonBuilder(
                                  imgPath: "icons/graph.png",  
                                  title: "Balanço",
                                  onPressed: (){
                                    //Navigator.push(context, MaterialPageRoute(builder: (context) => const GameBalanceScreen()));
                                  }
                                ),

                                GameIconButtonBuilder(
                                  imgPath: "icons/buildhotel.png",
                                  title: "+Hotel",
                                  onPressed: (){
                                  _dialogCaller(
                                      context, const CustomKeyboard(
                                        title: "Insira o valor total dos hotéis",
                                        eventType: EventType.build
                                      ));
                                }),

                                GameIconButtonBuilder(
                                  imgPath: "icons/buildhome.png",  
                                  title: "+Casa",
                                  onPressed:
                                  (){
                                    _dialogCaller(
                                    context, const CustomKeyboard(title: "Insira o valor da casas", eventType: EventType.build));
                                  }
                                ),

                                GameIconButtonBuilder(
                                    imgPath: "icons/more.png",
                                    title: "Mais", 
                                    onPressed: (){
                                     _dialogCaller(context, const MoreOptionsDialog());
                                }),
                              ],
                            ),

                            Expanded(
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20.0),
                                  color: Theme.of(context).primaryColor,
                                ),
                                padding: const EdgeInsets.all(8.0),
                                child: /*_streamBuilder,*/ListView.builder(
                                    reverse: true,
                                    itemCount: gameProvider.gameModelDTO!.logs.length,
                                    itemBuilder: (context, index) {
                                      List r = gameProvider.gameModelDTO!.logs.reversed.toList();
                                      return Container(
                                          decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(20.0),
                                              color: r[index].contains("Sua empresa") ? Colors.green : Colors.white
                                          ),
                                          padding: const EdgeInsets.all(5.0),
                                          margin: const EdgeInsets.only(top: 5.0),
                                          child:  Text(r[index],
                                            style: TextStyle(
                                              fontSize: 15.0,
                                              color: r[index].contains("Sua empresa") ? Colors.white : Theme.of(context).primaryColor,
                                            ),
                                          ));
                                    }),
                              ),
                            )
                          ],
                        ),
                      ));
        }));
  }

  Future _dialogCaller(BuildContext context, Widget dialog){
    return showDialog(context: context, builder: (BuildContext context){
      return dialog;
    });
  }

  Color _creditSituationColor(num value, double initialCredit){
    if(value >= (initialCredit * .6)){ //60%
      return Colors.green;
    } else if(value >= (initialCredit * .5)){
      return Colors.yellow;
    } else if(value >= (initialCredit * .3)){
      return Colors.orange;
    }else{
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


