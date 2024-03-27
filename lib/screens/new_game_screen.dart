import 'package:account_monopoly/utils/string_utils.dart';
import 'package:account_monopoly/widgets/default_dropdown_menu.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../model/game_model.dart';
import '../utils/tips_resourse.dart';
import '../widgets/tip_icon_button.dart';

class NewGameScreen extends StatefulWidget {
  const NewGameScreen({super.key});

  @override
  _NewGameScreenState createState() => _NewGameScreenState();
}

class _NewGameScreenState extends State<NewGameScreen> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  final _initialBalanceController = TextEditingController();
  int dropdownValue = 3;
  String dropdownBonusValue = "200.000";
  String dropdownFaturaTax = "Normal";
  List <String> faturaTaxOptions = ["Normal","Alto","Jogo-Rapido"];
  String dropdownLoanTax = "Normal";
  List <String> loanTaxOptions = ["Normal","Alto","Jogo-Rapido"];
  List <String> bonusOptions = ["0", "50.000","100.000","200.000","250.000"];
  List <int> spinnerItems = [2,3,4,5,6,7,8,9,10];
  bool isAuctionSwitchEnabled = false;
  bool isChanceSwitchEnabled = false;
  bool isHipotecaEnabled = false;


  bool _enableConfirmButton = true;

  @override
  void initState() {
    _initialBalanceController.selection = TextSelection.collapsed(offset: _initialBalanceController.text.length);
    setState(() {
      _initialBalanceController.text.isEmpty ? _initialBalanceController.text = "1.500.000" : null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        title: const Text("Configurações Iniciais", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        centerTitle: true,
      ),
      backgroundColor: Colors.black,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 30),
          //padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
          child: ListView(
            children: <Widget>[
              TextField(
                keyboardType: TextInputType.number,
                controller: _initialBalanceController,
                //textAlign: TextAlign.center,
                style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                    fontSize: 20.0),
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.attach_money),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 3.0),
                  ),
                  focusedBorder: const OutlineInputBorder(
                      borderSide: BorderSide(
                          color: Colors.white, width: 5.0
                      ),
                      borderRadius: BorderRadius.all(Radius.circular(20))
                  ),
                  border: const OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(20.0))),
                  helperText: "Saldo inicial",
                  helperStyle: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                      fontSize: 13.0),
                ),
              ),
              const SizedBox(height: 25.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    flex: 3,
                    child: DefaultDropdownMenu<int>(
                        value: dropdownValue,
                        hintText: "Limite de Jogadores",
                        items: spinnerItems,
                        onChange: (data) => setState(() => dropdownValue = data ?? dropdownValue),)
                  ),
                  Expanded(
                      flex: 1,
                      child: TipIconButton(title: "Limite de Jogadores", tip: TipsResourse.PLAYERS_LIMIT_TIP))
                ],
              ),
              const SizedBox(height: 25.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    flex: 3,
                    child: DefaultDropdownMenu<String>(
                    value: dropdownBonusValue,
                    hintText: "Bônus da Rodada",
                    items: bonusOptions,
                    onChange: (data) => setState(() => dropdownBonusValue = data ?? dropdownBonusValue),

                    )),
                  Expanded(
                      flex: 1,
                      child: TipIconButton(title: "Bônus da Rodada", tip: TipsResourse.ROUND_BONUS_TIP))
                ],
              ),
              const SizedBox(height: 25.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    flex: 3,
                    child: DefaultDropdownMenu<String>(
                        value: dropdownLoanTax,
                        hintText: "Nível dos juros",
                        items: loanTaxOptions,
                        onChange: (data) => setState(() {
                          dropdownLoanTax = data ?? dropdownLoanTax;
                        }))
                 ),
                 Expanded(
                     flex:1,
                     child: TipIconButton(title: "Nível dos juros:", tip: TipsResourse.LOAN_TAX_TIP))
                ],
              ),
              const SizedBox(height: 25.0),

              Card(
                color: Theme.of(context).primaryColor,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: <Widget>[
                      ListTile(
                        title: const Text(
                          'Gerenciar leilões',  style: TextStyle(fontSize: 15.0, fontWeight: FontWeight.w500, color: Colors.white)
                        ),
                        trailing: Switch(
                          // thumb color (round icon)
                          activeColor: Theme.of(context).primaryColor,
                          activeTrackColor: Colors.white,
                          inactiveThumbColor: Colors.blueGrey.shade600,
                          inactiveTrackColor: Colors.grey.shade400,
                          splashRadius: 35.0,
                          // boolean variable value
                          value: isAuctionSwitchEnabled,
                          // changes the state of the switch
                          onChanged: (value) => setState(() => isAuctionSwitchEnabled = value),
                        ),
                      ),
                      ListTile(
                        title: const Text(
                            'Gerenciar eventos',  style: TextStyle(fontSize: 15.0, fontWeight: FontWeight.w500, color: Colors.white)
                        ),
                        trailing: Switch(
                          // thumb color (round icon)
                          activeColor: Theme.of(context).primaryColor,
                          activeTrackColor: Colors.white,
                          inactiveThumbColor: Colors.blueGrey.shade600,
                          inactiveTrackColor: Colors.grey.shade400,
                          splashRadius: 35.0,
                          // boolean variable value
                          value: isChanceSwitchEnabled,
                          // changes the state of the switch
                          onChanged: (value) => setState(() => isChanceSwitchEnabled = value),
                        ),
                      ),
                      ListTile(
                        title: const Text(
                            'Gerenciar Hipotecas',  style: TextStyle(fontSize: 15.0, fontWeight: FontWeight.w500, color: Colors.white)
                        ),
                        trailing: Switch(
                          // thumb color (round icon)
                          activeColor: Theme.of(context).primaryColor,
                          activeTrackColor: Colors.white,
                          inactiveThumbColor: Colors.blueGrey.shade600,
                          inactiveTrackColor: Colors.grey.shade400,
                          splashRadius: 35.0,
                          // boolean variable value
                          value: isHipotecaEnabled,
                          // changes the state of the switch
                          onChanged: (value) => setState(() => isHipotecaEnabled = value),
                        ),
                      )
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 25.0),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  fixedSize: const Size(25, 25),
                  backgroundColor: Theme.of(context).primaryColor,
                  padding: const EdgeInsets.all(10.0),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25.0)
                  ),
                  splashFactory: InkRipple.splashFactory,
                ),
                child: const Text(
                  "Prosseguir",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.0, color: Colors.white),
                ),
                onPressed: (){
                  _showConfirmDialog();
                },
              )
            ],
          ),
        ),
      )
    );
  }

  _showConfirmDialog(){
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.0)
          ),
          backgroundColor: Colors.black,
          title: const Text("Resumo",
              style: TextStyle(color: Colors.white)),
          content: Text(
              "Saldo inicial: \$ ${_initialBalanceController.text}\nLimite de Jogadores: $dropdownValue\nBônus da rodada: $dropdownBonusValue\n"
                  "\n\nDeseja confirmar as configurações?",
              style: const TextStyle(color: Colors.white)),
          actions: <Widget>[
            // define os botões na base do dialogo
            TextButton(
              child: const Text("Voltar", style: TextStyle(fontSize: 17.0, color: Colors.white )),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              onPressed: !_enableConfirmButton ? null : () async {
                _enableConfirmButton = false;
                String generatedGameId = StringUtils.generateUUID(size: 8); 
                GameModelDTO gameData = GameModelDTO(
                    id: generatedGameId,
                    currentGameBalance: int.parse(_initialBalanceController.text),
                    limitPlayer: dropdownValue,
                    players: [],
                    initalGameBalance:  int.parse(_initialBalanceController.text),
                    roundBonus: int.parse(dropdownBonusValue),
                    levelTax: int.parse(dropdownLoanTax)
                );

                GameModelController.of(context).createNewGame(onFail: _onFail, onSuccess: _onSuccess, gameData: gameData);
              },
              child: const Text("Confirmar", style: TextStyle(fontSize: 17.0, color: Colors.white )),
            ),
          ],
        );
      },
    );
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

  Future<void> _onSuccess() async {
    Navigator.of(context).pop();
    //Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => GameScreen())).then((value) => GameModelController.of(context).exitGame());
  }
}