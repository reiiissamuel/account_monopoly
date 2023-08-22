import 'package:account_monopoly/utils/string_utils.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../dto/player.dart';
import '../model/game_model.dart';
import '../model/user_model.dart';
import '../utils/tips_resourse.dart';
import '../widgets/tip_icon_button.dart';

class NewGameScreen extends StatefulWidget {
  @override
  _NewGameScreenState createState() => _NewGameScreenState();
}

class _NewGameScreenState extends State<NewGameScreen> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  final _initialBalanceController = TextEditingController();
  int dropdownValue = 2;
  String dropdownBonusValue = "200.000";
  String dropdownFaturaTax = "Normal";
  List <String> faturaTaxOptions = ["Normal","Alto","Jogo-Rapido"];
  String dropdownLoanTax = "Normal";
  List <String> loanTaxOptions = ["Normal","Alto","Jogo-Rapido"];
  List <String> bonusOptions = ["0", "50.000","100.000","200.000","250.000"];
  List <int> spinnerItems = [2,3,4,5,6,7,8,9,10];
  String _gameCode = "";

  bool _enableConfirmButton = true;

  @override
  void initState() {
    _codeGenerator(UserModelController.of(context).user!.username);
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
        title: const Text("Novo Jogo"),
        centerTitle: true,
      ),
      backgroundColor: Colors.black,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
          child: Column(

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
                    borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 5.0),
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
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  const Text("Limite de Jogadores:", style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.w500, color: Colors.white)),
                  DropdownButton<int>(
                    value: dropdownValue,
                    icon: Icon(Icons.arrow_drop_down, color: Theme.of(context).primaryColor),
                    iconSize: 24,
                    elevation: 16,
                    style: TextStyle(color: Theme.of(context).primaryColor, fontSize: 18),
                    underline: Container(
                      height: 1,
                      color: Theme.of(context).primaryColor,
                    ),
                    onChanged: (data) {
                      setState(() {
                        dropdownValue = data ?? dropdownValue;
                      });
                    },
                    items: spinnerItems.map<DropdownMenuItem<int>>((int value) {
                      return DropdownMenuItem<int>(
                        value: value,
                        child: Text(value.toString()),
                      );
                    }).toList(),
                  ),
                  TipIconButton(title: "Limite de Jogadores", tip: TipsResourse.PLAYERS_LIMIT_TIP)
                ],
              ),
              const SizedBox(height: 25.0),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  const Text("Bônus da Rodada:", style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.w500, color: Colors.white)),
                  DropdownButton<String>(
                    value: dropdownBonusValue,
                    icon: Icon(Icons.arrow_drop_down, color: Theme.of(context).primaryColor),
                    iconSize: 24,
                    elevation: 16,
                    style: TextStyle(color: Theme.of(context).primaryColor, fontSize: 18),
                    underline: Container(
                      height: 1,
                      color: Theme.of(context).primaryColor,
                    ),
                    onChanged: (data) {
                      setState(() {
                        dropdownBonusValue = data ?? dropdownBonusValue;
                      });
                    },
                    items: bonusOptions.map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ),
                  TipIconButton(title: "Bônus da Rodada", tip: TipsResourse.ROUND_BONUS_TIP)
                ],
              ),
              const SizedBox(height: 25.0),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  const Text("Juros de Empréstimo:", style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.w500, color: Colors.white)),
                  DropdownButton<String>(
                    value: dropdownLoanTax,
                    icon: Icon(Icons.arrow_drop_down, color: Theme.of(context).primaryColor),
                    iconSize: 24,
                    elevation: 16,
                    style: TextStyle(color: Theme.of(context).primaryColor, fontSize: 18),
                    underline: Container(
                      height: 1,
                      color: Theme.of(context).primaryColor,
                    ),
                    onChanged: (data) {
                      setState(() {
                        dropdownLoanTax = data ?? dropdownLoanTax;
                      });
                    },
                    items: loanTaxOptions.map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ),
                  TipIconButton(title: "Juros de Empréstimo", tip: TipsResourse.LOAN_TAX_TIP)
                ],
              ),
              const SizedBox(height: 25.0),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  const Text("Juros de Parcelamento:", style: TextStyle(fontSize: 15.0, fontWeight: FontWeight.w500, color: Colors.white)),
                  DropdownButton<String>(
                    value: dropdownFaturaTax,
                    icon: Icon(Icons.arrow_drop_down, color: Theme.of(context).primaryColor),
                    iconSize: 24,
                    elevation: 16,
                    style: TextStyle(color: Theme.of(context).primaryColor, fontSize: 18),
                    underline: Container(
                      height: 1,
                      color: Theme.of(context).primaryColor,
                    ),
                    onChanged: (data) {
                      setState(() {
                        dropdownFaturaTax = data ?? dropdownFaturaTax;
                      });
                    },
                    items: faturaTaxOptions.map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ),
                  TipIconButton(title: "Juros de parcelamento", tip: TipsResourse.INSTALMENT_TAX_TIP)
                ],
              ),
              const SizedBox(height: 25.0),

              Card(
                color: Theme.of(context).primaryColor,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: <Widget>[
                      const Text("ID da mesa", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17.0, color: Colors.white)),
                      const SizedBox(height: 32.0),
                      Text(_gameCode, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 20.0, color: Colors.white, letterSpacing: 2.0), textAlign: TextAlign.center),
                      const SizedBox(height: 32.0),
                      FloatingActionButton(
                          tooltip: "Gerar novo código",
                          backgroundColor: Colors.black,
                          foregroundColor: Theme.of(context).primaryColor,
                          child: const Icon(Icons.refresh),
                          onPressed: (){
                            _codeGenerator(UserModelController.of(context).user!.username);
                          }
                      )
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 25.0),

              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(10.0),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.0)
                  ),
                  splashFactory: InkRipple.splashFactory,
                ),
                child: const Text(
                  "Prosseguir",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20.0, color: Colors.white),
                ),
                onPressed: (){
                  _showConfirmDialog();
                },
              )
            ],
          ),
        ),
      ),
    );
  }


  void _codeGenerator(String nick){
    setState(() {
      _gameCode = DateTime.now().toString().replaceAll( RegExp("[:.-]"), '').replaceAll(" ",nick);
    });
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
          title: const Text("Configurações da mesa",
              style: TextStyle(color: Colors.white)),
          content: Text(
              "Saldo inicial: \$ ${_initialBalanceController.text}\nLimite de Jogadores: $dropdownValue\nBônus da rodada: $dropdownBonusValue\n"
                  "\nCódigo da mesa: $_gameCode"
                  "\n\nDeseja confirmar as configurações?",
              style: const TextStyle(color: Colors.white)),
          actions: <Widget>[
            // define os botões na base do dialogo
            TextButton(
              child: const Text("Voltar", style: TextStyle(fontSize: 17.0)),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              onPressed: !_enableConfirmButton ? null : () async {
                _enableConfirmButton = false;

                Player player = Player.empty();
                player.peerId = StringUtils().generateUUID(size: 8);
                player.peerId = UserModelController.of(context).user!.peerId;
                player.username = UserModelController.of(context).user!.username;

                GameModelDTO gameData = GameModelDTO(
                    //gameCode: StringUtils().generateUUID(), //TODO implementar senha
                    currentGameBalance: int.parse(_initialBalanceController.text),
                    limitPlayer: dropdownValue,
                    players: [player],
                    loanTax: int.parse(dropdownLoanTax),
                    faturaTax: int.parse(dropdownFaturaTax), roundBonus: int.parse(dropdownBonusValue.replaceAll(".", "")),
                    initalGameBalance:  int.parse(_initialBalanceController.text)
                );

                GameModelController.of(context).createNewGame(onFail: _onFail, onSuccess: _onSuccess, gameData: gameData);
              },
              child: const Text("Confirmar", style: TextStyle(fontSize: 17.0)),
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
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => GameScreen())).then((value) => GameModelController.of(context).exitGame());
  }
}
