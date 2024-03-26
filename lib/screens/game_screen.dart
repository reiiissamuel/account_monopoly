/*import 'dart:async';
import 'package:flutter/material.dart';
import 'package:monopolycontamovel/datas/event.dart';
import 'package:monopolycontamovel/datas/hipoteca.dart';
import 'package:monopolycontamovel/dialogs/account_description.dart';
import 'package:monopolycontamovel/dialogs/auction_alert_dialog.dart';
import 'package:monopolycontamovel/dialogs/closeAccount_dialog.dart';
import 'package:monopolycontamovel/dialogs/customKeyboard_dialog.dart';
import 'package:monopolycontamovel/dialogs/event_dialog.dart';
import 'package:account_monopoly/dialogs/moreOptions_dialog.dart';
import 'package:monopolycontamovel/dialogs/table_info_dialog.dart';
import 'package:monopolycontamovel/dialogs/winner_dialog.dart';
import 'package:monopolycontamovel/models/game_model.dart';
import 'package:monopolycontamovel/models/user_model.dart';
import 'package:monopolycontamovel/screens/beneficiaries_screen.dart';
import 'package:monopolycontamovel/screens/game_balance_screen.dart';
import 'package:account_monopoly/screens/hipotecas_screen.dart';
import 'package:account_monopoly/utils/string_utils.dart';
import 'package:account_monopoly/widgets/game_iconButton_builder.dart';
import 'package:scoped_model/scoped_model.dart';

import 'home_screen.dart';

class GameScreen extends StatefulWidget {

  @override
  GameScreenState createState() => GameScreenState();
}
//todo resolver limite de jogadores
//todo implementar dialog com dados da partida e menu
class GameScreenState extends State<GameScreen> {
  
  StringFormatter _stringFormatter = StringFormatter();
  int eventDeckCount = 0;
  List<Event> _events = List.empty();
  EventController _eventController = EventController();
  StringFormatter sf = StringFormatter();

  bool _saldoVisibiliade = false;

  @override
  void initState() {
    super.initState();
    _getAllEvents();
  }


  @override
  Widget build(BuildContext context) {

    if(UserModel.of(context).firebaseUser == null)
      return Center(child: CircularProgressIndicator());
    return WillPopScope(
      onWillPop: () async => false,
      child: ScopedModelDescendant<GameModel>(
                builder: (context, child, model){
                  if(model.isLoading || UserModel.of(context).isLoading)
                    return Center(child: CircularProgressIndicator());

                  if(model.youWon==true)
                    return WinnerDialog(); // retorna quando o jogadore vence
                  return Scaffold(
                      appBar: AppBar(
                        automaticallyImplyLeading: false,
                        title: Text(
                          "My Mobile Bank", style: TextStyle(letterSpacing: 2),
                        ),
                        centerTitle: true,
                        leading: Center(
                            child: !model.isThareAuction ? Icon(Icons.notifications_none, color: Colors.white)
                                :
                            IconButton(
                              icon: Icon(Icons.notifications_active, color: Colors.yellowAccent),
                              onPressed: ()  {
                                _dialogCaller(context, AuctionAlert()).then((value){
                                  //todo fazer essa consulta a partir da lista de objetos auction
                                  String s = model.logs.last;
                                  //so procurará por mais leilões das minhas hipotecas, caso a ultima propriedade leiloada no log tenha sido minha e leiloada pelo banco
                                  if(s.startsWith("Banco") && s.contains("leilão") && s.contains("VOCÊ"))
                                    _lookForNextAuction(context, model);
                                  else
                                    model.isThareAuction = false;
                                  model.notify();
                                });
                              },
                            )
                        ),
                        actions: <Widget>[
                          Center(
                            child: GestureDetector(
                              child: Text("ID", style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold, color: Colors.white),),
                              onTap: (){
                                _dialogCaller(context, TableInfoDialog());
                              },
                            ),
                          ),
                          SizedBox(width: 8.0),
                          IconButton(
                            icon: Icon(Icons.exit_to_app),
                            onPressed: () {
                              showDialog(context: context, builder:(BuildContext context){
                                return ConfirmActionDialog(title: "Quer mesmo sair deste jogo?", textContent: "Você poderá entrar nele novamete\n"
                                    "indo até a sessão \'jogos ativos\'", onConfirm: (){
                                  //todo salvar dados da partida ao sair

                                  Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => HomeScreen()));
                                });
                              });
                            },
                          )
                        ],
                      ),

                      floatingActionButton:
                      Padding(
                        padding: EdgeInsets.only(bottom: 195.0),
                        child: FloatingActionButton(
                          backgroundColor: Theme.of(context).primaryColor,
                          shape:CircleBorder(
                              side: BorderSide(color: Colors.black)
                          ),
                          child: Padding(
                            padding: EdgeInsets.all(5.0),
                            child: SizedBox(
                              height: 50.0,
                              width: 50.0,
                              child: Image.asset("icons/events.png",
                                  fit: BoxFit.contain),
                            ),
                          ),
                          onPressed: model.isThareAuction ? null : (){
                            _dialogCaller(context, ConfirmActionDialog(title: "???", textContent: "Deseja pegar uma carta evento?", onConfirm:(){
                              Navigator.of(context).pop();
                              showDialog(context: context, builder: (BuildContext context){
                                if(_events[eventDeckCount].isbenefit)
                                  model.benefits.add(_events[eventDeckCount]);

                                if(_events[eventDeckCount].effect > 0)
                                  model.account.qtdEventGain += _events[eventDeckCount].effect;
                                else if(_events[eventDeckCount].effect < 0)
                                  model.account.qtdEventPay += -(_events[eventDeckCount].effect);
                                return EventDialog(_events[eventDeckCount++]);
                              });
                            }));

                            if(eventDeckCount == _events.length)
                              eventDeckCount -= eventDeckCount;
                          },
                        ),
                      ),

                     backgroundColor: Colors.black,

                      body: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 16.0),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  flex: 2,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                                    children: [
                                      !_saldoVisibiliade
                                          ?
                                      Container(
                                        height: 8,
                                        width: 170,
                                        decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(20.0),
                                            color: Theme.of(context).primaryColor,
                                        )
                                      )
                                      :
                                      Text(
                                        "${_stringFormatter.currencyFormat(model.currentGameBalance.toString())} R\$",
                                        style: TextStyle(
                                            fontSize: 27.0,
                                            color: _verifyCase(model.currentGameBalance),
                                            fontWeight: FontWeight.w500),
                                      ),
                                      IconButton(
                                          icon: Icon(_saldoVisibiliade ? Icons.visibility_off : Icons.visibility, size: 25, color: Theme.of(context).primaryColor),
                                          onPressed: (){
                                        setState(() {
                                          _saldoVisibiliade = !_saldoVisibiliade;
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
                                          child: Text(
                                            "Hipotécas",
                                            style: TextStyle(fontSize: 17.0, color: Colors.white, letterSpacing: 2.0, fontWeight: FontWeight.w500),
                                          ),
                                          onPressed: model.isThareAuction ? null : (){
                                            Navigator.push(context, MaterialPageRoute(builder: (context) => HipotecaScreen()));
                                          },
                                        ),
                                        ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(20.0)
                                            ),
                                            backgroundColor: Theme.of(context).primaryColor
                                          ),
                                          child: Text(
                                              "Fechar Rodada", textAlign: TextAlign.center,
                                              style: TextStyle(fontSize: 17.0, color: Colors.white, letterSpacing: 2.0, fontWeight: FontWeight.w500)
                                          ),
                                          onPressed: model.isThareAuction ? null : () async {
                                            model.account.bonus = model.gameData["bonus"];

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
                                                }).then((value) => model.notify());

                                            if(model.hipotecas.isNotEmpty){
                                              model.hipotecas.forEach((h){
                                                (h.deadline > 0) ? h.deadline -= 1 : (h.valueToPay > h.auctionMinValue)
                                                    ? h.valueToPay -= (h.valueToPay * 0.1).floor() : h.valueToPay = h.auctionMinValue;
                                                if(h.deadline == 0)
                                                  h.isSetToAuction = false;
                                              });
                                              _lookForNextAuction(context, model);
                                            }
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
                                  onPressed: model.isThareAuction ? (){} : (){
                                    _dialogCaller(context, CustomKeyboard(title: "Insira o valor da propriedade",
                                      keyO: KeyboardOparation.ACCOUT_UPDATE, logMsgType: LogMsgType.BUY, playerToPayId: ""));
                                  }
                                ),

                                GameIconButtonBuilder(
                                  imgPath: "icons/bills.png",  
                                  title: "Ver Fatura", 
                                  onPressed: model.isThareAuction ? (){} : (){
                                    _dialogCaller(context, AccountDescription(model.account));
                                  }
                                ),

                                GameIconButtonBuilder(
                                  imgPath: "icons/pay.png",  
                                  title: "Transferir", 
                                  onPressed: model.isThareAuction ? (){} : (){
                                    Navigator.push(context, MaterialPageRoute(builder: (context)=>BeneficiariesScreen()));
                                  }
                                ),

                                GameIconButtonBuilder(
                                  imgPath: "icons/graph.png",  
                                  title: "Balanço",
                                  onPressed: model.isThareAuction ? (){} : (){
                                    Navigator.push(context, MaterialPageRoute(builder: (context) => GameBalanceScreen()));
                                  }
                                ),

                                GameIconButtonBuilder(
                                  imgPath: "icons/buildhotel.png",
                                  title: "+Hotel",
                                  onPressed: model.isThareAuction ? (){} : (){
                                  _dialogCaller(context, CustomKeyboard(title: "Insira o valor total dos hotéis", keyO: KeyboardOparation.ACCOUT_UPDATE, logMsgType: LogMsgType.BUILD_HOTEL, playerToPayId: ""));
                                }),

                                GameIconButtonBuilder(
                                  imgPath: "icons/buildhome.png",  
                                  title: "+Casa",
                                  onPressed: model.isThareAuction ? (){} : 
                                  (){
                                    _dialogCaller(context, CustomKeyboard(title: "Insira o valor da casas", keyO: KeyboardOparation.ACCOUT_UPDATE, logMsgType: LogMsgType.BUILD_HOUSE, playerToPayId: ""));
                                  }
                                ),

                                GameIconButtonBuilder(
                                    imgPath: "icons/more.png",
                                    title: "Mais", 
                                    onPressed: model.isThareAuction ? (){} : (){_dialogCaller(context, MoreOptionsDialog());
                                }),
                              ],
                            ),

                            Expanded(
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20.0),
                                  color: Theme.of(context).primaryColor,
                                ),
                                padding: EdgeInsets.all(8.0),
                                child: /*_streamBuilder,*/ListView.builder(
                                    reverse: true,
                                    itemCount: GameModel.of(context).logs.length,
                                    itemBuilder: (context, index) {
                                      List r = GameModel.of(context).logs.reversed.toList();
                                      return Container(
                                          decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(20.0),
                                              color: r[index].contains("VOCÊ") ? Colors.green : Colors.white
                                          ),
                                          padding: EdgeInsets.all(5.0),
                                          margin: const EdgeInsets.only(top: 5.0),
                                          child:  Text(r[index],
                                            style: TextStyle(
                                              fontSize: 15.0,
                                              color: r[index].contains("VOCÊ") ? Colors.white : Theme.of(context).primaryColor,
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
    _eventController.getAllEvents().then((list) {
      setState(() {
        (_events = list.cast()).shuffle();
      });
    });
  }

  void _lookForNextAuction(BuildContext context, GameModel model)  {

    if(model.hipotecas.any((h) => (!h.isSetToAuction && h.deadline==0))){
      //model.isThareAuction = true;
      Hipoteca hipoteca = Hipoteca();
      hipoteca = model.hipotecas.firstWhere((h) => (!h.isSetToAuction && h.deadline==0));
      model.hipotecas.firstWhere((h) => h.id == hipoteca.id).isSetToAuction = true;
      model.logComposer(type: LogMsgType.AUCTION, auctionName: hipoteca.name, value: hipoteca.value);
     // model.sendLog("Banco pôs \'${hipoteca.name}\' de ${model.user.userData["nick"]} para leilão com lance inicial de " + sf.currencyFormat(hipoteca.valueToPay.toString()));//todo substituir isso pela chamada do metodo logcomposer
    }else{
      model.isThareAuction = false;
    }

  }

}


enum KeyboardOparation{
  ACCOUT_UPDATE,
  LOAN,
  TRANSFER_IN,
  TRANSFER_OUT
}
*/
