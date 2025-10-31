import 'dart:async';
import 'package:account_monopoly/enums/log_msg_type.dart';
import 'package:account_monopoly/provider/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:account_monopoly/dialogs/auction_alert_dialog.dart';
import 'package:account_monopoly/dialogs/winner_dialog.dart';
import 'package:account_monopoly/screens/game_balance_screen.dart';
import 'package:account_monopoly/utils/string_utils.dart';
import 'package:provider/provider.dart';

import 'package:account_monopoly/dialogs/account_description.dart';
import 'package:account_monopoly/dialogs/chance_dialog.dart';
import 'package:account_monopoly/dialogs/close_account_dialog.dart';
import 'package:account_monopoly/dialogs/confirm_action_dialog.dart';
import 'package:account_monopoly/dialogs/custom_keyboard_dialog.dart';
import 'package:account_monopoly/dialogs/more_options_dialog.dart';
import 'package:account_monopoly/dialogs/table_info_dialog.dart';
import 'package:account_monopoly/dto/chance.dart';
import 'package:account_monopoly/provider/game_provider.dart';
import 'package:account_monopoly/widgets/game_icon_button_builder.dart';
import 'package:account_monopoly/screens/beneficiaries_screen.dart';
import 'package:account_monopoly/screens/home_screen.dart';
import 'package:account_monopoly/screens/mortgage_screen.dart';

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
      gameProvider.gameModelDTO!.balance.accounts.add(gameProvider.gameModelDTO!.account);
      if (gameProvider.gameModelDTO!.chancesEnabled) {
        _getAllEvents();
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
          if (gameProvider.youWon) {
            return const WinnerDialog(); // return when context player is the winner
          }
          if (gameProvider.isThereAuction) {
            WidgetsBinding.instance.addPostFrameCallback((_) => _dialogCaller(context, const AuctionAlert()));
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
                  child: !gameProvider.isThereAuction
                      ? IconButton(
                          icon: const Icon(Icons.broadcast_on_personal_rounded,
                              color: Colors.green),
                          onPressed: () {
                            _dialogCaller(context, const TableInfoDialog());
                          },
                        )
                      : IconButton(
                          icon: const Icon(Icons.install_mobile,
                              color: Colors.white),
                          onPressed: () {
                            _dialogCaller(context, const TableInfoDialog());
                          },
                        ),
                ),
                actions: <Widget>[
                  Center(
                    child: Text(
                      gameProvider.gameModelDTO!.balance.round.toString(),
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
                          onPressed: gameProvider.isThereAuction ? null : (){
                            _dialogCaller(context, ConfirmActionDialog(title: "???", textContent: "Deseja pegar uma carta evento?", onConfirm:(){
                              Navigator.of(context).pop();
                              showDialog(context: context, builder: (BuildContext context){
                                if(_chances[eventDeckCount].isbenefit) {
                                  gameProvider.gameModelDTO!.chances.add(_chances[eventDeckCount]);
                                }

                                if(_chances[eventDeckCount].effect! > 0) {
                                  gameProvider.gameModelDTO!.account.qtdEventGain += _chances[eventDeckCount].effect!;
                                } else if(_chances[eventDeckCount].effect! < 0){
                                  gameProvider.gameModelDTO!.account.qtdEventPay += (-_chances[eventDeckCount].effect!);
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
                                        "R\$ * * * * *",
                                        style: TextStyle(fontSize: 25, letterSpacing: 2, color: Theme.of(context).primaryColor, fontWeight: FontWeight.bold),
                                      )
                                      :
                                      Text(
                                        "R\$ ${StringUtils.currencyFormat(gameProvider.gameModelDTO!.currentGameBalance.toString())}",
                                        style: TextStyle(
                                            fontSize: 27.0,
                                            color: _verifyCase(gameProvider.gameModelDTO!.currentGameBalance),
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
                                      children: [
                                        ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(20.0)
                                            ),
                                            backgroundColor: Theme.of(context).primaryColor
                                          ),
                                          onPressed: gameProvider.isThereAuction ? null : (){
                                            Navigator.push(context, MaterialPageRoute(builder: (context) => const MortgageScreen()));
                                          },
                                          child: const Text(
                                            "Hipotécas",
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
                                              "Fechar Rodada", textAlign: TextAlign.center,
                                              style: TextStyle(fontSize: 17.0, color: Colors.white, letterSpacing: 2.0, fontWeight: FontWeight.w500)
                                          ),
                                          onPressed: () async {
                                            await showGeneralDialog(
                                                context: context,
                                                barrierDismissible: false,
                                                barrierLabel: MaterialLocalizations.of(context)
                                                    .modalBarrierDismissLabel,
                                                barrierColor: Colors.black45,
                                                transitionDuration: const Duration(milliseconds: 200),
                                                pageBuilder: (BuildContext context, Animation animation,
                                                    Animation secondAnimation){
                                                  return CloseAccountDialog();
                                                });
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
                                    _dialogCaller(context, const CustomKeyboard(title: "Insira o valor da propriedade", eventType: LogMsgType.BUY, playerToPayId: ""));
                                  }
                                ),

                                GameIconButtonBuilder(
                                  imgPath: "icons/bills.png",  
                                  title: "Ver Fatura", 
                                  onPressed: (){
                                    _dialogCaller(context, const AccountDescription());
                                  }
                                ),

                                GameIconButtonBuilder(
                                  imgPath: "icons/pay.png",  
                                  title: "Transferir", 
                                  onPressed: (){
                                    Navigator.push(context, MaterialPageRoute(builder: (context)=>const BeneficiariesScreen()));
                                  }
                                ),

                                GameIconButtonBuilder(
                                  imgPath: "icons/graph.png",  
                                  title: "Balanço",
                                  onPressed: (){
                                    Navigator.push(context, MaterialPageRoute(builder: (context) => const GameBalanceScreen()));
                                  }
                                ),

                                GameIconButtonBuilder(
                                  imgPath: "icons/buildhotel.png",
                                  title: "+Hotel",
                                  onPressed: (){
                                  _dialogCaller(
                                      context, const CustomKeyboard(
                                      title: "Insira o valor total dos hotéis",
                                      eventType: LogMsgType.BUILD_HOTEL,
                                      playerToPayId: ""));
                                }),

                                GameIconButtonBuilder(
                                  imgPath: "icons/buildhome.png",  
                                  title: "+Casa",
                                  onPressed:
                                  (){
                                    _dialogCaller(
                                    context, const CustomKeyboard(title: "Insira o valor da casas", eventType: LogMsgType.BUILD_HOUSE, playerToPayId: ""));
                                  }
                                ),

                                GameIconButtonBuilder(
                                    imgPath: "icons/more.png",
                                    title: "Mais", 
                                    onPressed: (){_dialogCaller(context, const MoreOptionsDialog());
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
                                              color: r[index].contains("Você") ? Colors.green : Colors.white
                                          ),
                                          padding: const EdgeInsets.all(5.0),
                                          margin: const EdgeInsets.only(top: 5.0),
                                          child:  Text(r[index],
                                            style: TextStyle(
                                              fontSize: 15.0,
                                              color: r[index].contains("Você") ? Colors.white : Theme.of(context).primaryColor,
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

  Color _verifyCase(int balance){
    if(balance >= 1500000){
      return Colors.green;
    }else if(balance < 200000){
      return Colors.red;
    }else if(balance >= 200000 && balance <=800000){
      return Colors.orange;
    }else{
      return Colors.yellow;
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


