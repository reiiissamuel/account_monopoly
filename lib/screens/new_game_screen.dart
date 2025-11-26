import 'dart:collection';

import 'package:account_monopoly/domain/enums/game_level.dart';
import 'package:account_monopoly/domain/model/game.dart';
import 'package:account_monopoly/domain/model/ledger.dart';
import 'package:account_monopoly/domain/model/property.dart';
import 'package:account_monopoly/provider/user_provider.dart';
import 'package:account_monopoly/utils/string_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show FilteringTextInputFormatter;
import 'package:provider/provider.dart';

import 'package:account_monopoly/provider/game_provider.dart';
import 'package:account_monopoly/utils/tips_resourse.dart';
import 'package:account_monopoly/widgets/tip_icon_button.dart';
import 'package:account_monopoly/screens/game_screen.dart';


class NewGameScreen extends StatefulWidget {
  const NewGameScreen({super.key});

  @override
  NewGameScreenState createState() => NewGameScreenState();
}

class NewGameScreenState extends State<NewGameScreen> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  final _initialCreditController = TextEditingController();
  final _bonusController = TextEditingController();
  final _sharesController = TextEditingController();
  String _selectedPropertyVersion = '';
  List<String> _propertiesVersionsOptions = [];
  int dropdownValue = 3;
  GameLevel gameLevel = GameLevel.nomal;
  List <int> spinnerItems = [2,3,4,5,6,7,8,9,10];
  bool isChanceSwitchEnabled = true;
  bool isLoanEnabled = true;

  final bool _enableConfirmButton = true;

@override
 void initState() {
  super.initState();
  WidgetsBinding.instance.addPostFrameCallback((_) {
   _initialCreditController.text.isEmpty ? _initialCreditController.text = "200.000,00" : null;
   _bonusController.text.isEmpty ? _bonusController.text = "200.000,00" : null;
   _sharesController.text.isEmpty ? _sharesController.text = "1000" : null;
   _initialCreditController.selection = TextSelection.collapsed(offset: _initialCreditController.text.length);
   _bonusController.selection = TextSelection.collapsed(offset: _bonusController.text.length);
   _sharesController.selection = TextSelection.collapsed(offset: _sharesController.text.length);
    final availableVersions = Provider.of<UserProvider>(context, listen: false).user!.propertiesVersion!.keys.toList();
   _propertiesVersionsOptions = availableVersions;
    if (_propertiesVersionsOptions.isNotEmpty) {
      _selectedPropertyVersion = _propertiesVersionsOptions.first;
    }
      
   setState(() {});
  });
 }

  InputDecoration _buildInputDecoration(BuildContext context, String labelText, {IconData? icon}) {
    return InputDecoration(
      labelText: labelText,
      labelStyle: const TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.w500,
        fontSize: 18.0,
      ),
      prefixIcon: icon != null ? Icon(icon, color: Theme.of(context).primaryColor) : null,
      
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 3.0),
        borderRadius: const BorderRadius.all(Radius.circular(20)),
      ),
      focusedBorder: const OutlineInputBorder(
        borderSide: BorderSide(
          color: Colors.white, width: 5.0
        ),
        borderRadius: BorderRadius.all(Radius.circular(20))
      ),
      border: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(20.0))),
    );
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
          child: ListView(
            children: <Widget>[
              // --- Campo: Saldo Inicial (Agora com labelText) ---
              TextField(
                keyboardType: TextInputType.number,
                controller: _initialCreditController,
                style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                    fontSize: 20.0),
                decoration: _buildInputDecoration(context, "Saldo Inicial", icon: Icons.attach_money),
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  StringUtils(), // Aplica a formatação de moeda
                ]
              ),
              const SizedBox(height: 25.0),
              TextField(
                keyboardType: TextInputType.number,
                controller: _bonusController,
                style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                    fontSize: 20.0),
                decoration: _buildInputDecoration(context, "Bônus de Rodada", icon: Icons.attach_money),
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  StringUtils(), // Aplica a formatação de moeda
                ]
              ), 
              const SizedBox(height: 25.0),
              TextField(
                keyboardType: TextInputType.number,
                controller: _sharesController,
                style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                    fontSize: 20.0),
                decoration: _buildInputDecoration(context, "Quantidade de ações por propriedade", icon: Icons.money),
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                ]
              ), 
              const SizedBox(height: 25.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    flex: 3,
                    child: DropdownButtonFormField<int>(
                      initialValue: dropdownValue,
                      decoration: _buildInputDecoration(context, "Limite de Jogadores"), 
                      dropdownColor: Colors.black, // Cor do menu dropdown para visibilidade
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                          fontSize: 20.0),
                      
                      items: spinnerItems.map<DropdownMenuItem<int>>((int value) {
                        return DropdownMenuItem<int>(
                          value: value,
                          child: Text(value.toString()),
                        );
                      }).toList(),
                      onChanged: (data) => setState(() => dropdownValue = data ?? dropdownValue),
                    ),
                  ),
                  const Expanded(
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
                    child: DropdownButtonFormField<String>(
                      initialValue: _selectedPropertyVersion,
                      decoration: _buildInputDecoration(context, "Versão do tabuleiro"), 
                      dropdownColor: Colors.black, // Cor do menu dropdown para visibilidade
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                          fontSize: 20.0),
                      
                      items: _propertiesVersionsOptions.map<DropdownMenuItem<String>>((String selectedPropertyVersion) {
                        return DropdownMenuItem<String>(
                          value: selectedPropertyVersion,
                          child: Text(selectedPropertyVersion),
                        );
                      }).toList(),
                      onChanged: (data) => setState(() => _selectedPropertyVersion = data ?? _selectedPropertyVersion),
                    ),
                  ),
                  const Expanded(
                      flex: 1,
                      child: TipIconButton(title: "Versão do tabuleiro", tip: TipsResourse.VERSION))
                ],
              ),
              const SizedBox(height: 25.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    flex: 3,
                    child: DropdownButtonFormField<GameLevel>(
                      initialValue: gameLevel,
                      decoration: _buildInputDecoration(context, "Nível do Jogo"),
                      dropdownColor: Colors.black, // Cor do menu dropdown para visibilidade
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                          fontSize: 20.0),
                      
                      items: GameLevel.values.map((GameLevel type) {
                          return DropdownMenuItem<GameLevel>(
                            value: type,
                            child: Text(
                              type.description, // Exibe apenas o nome do enum
                              style: const TextStyle(color: Colors.white),
                            ),
                          );
                        }).toList(),
                      onChanged: (data) => setState(() {
                        gameLevel = data ?? gameLevel;
                      })
                    )
                  ),
                  const Expanded(
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
                            'Habilitar eventos de mercado', style: TextStyle(fontSize: 15.0, fontWeight: FontWeight.w500, color: Colors.white)
                        ),
                        trailing: Switch(
                          activeThumbColor: Theme.of(context).primaryColor,
                          activeTrackColor: Colors.white,
                          inactiveThumbColor: Colors.blueGrey.shade600,
                          inactiveTrackColor: Colors.grey.shade400,
                          splashRadius: 35.0,
                          value: isChanceSwitchEnabled,
                          onChanged: (value) => setState(() => isChanceSwitchEnabled = value),
                        ),
                      ),
                      ListTile(
                        title: const Text(
                            'Habilitar empréstimos', style: TextStyle(fontSize: 15.0, fontWeight: FontWeight.w500, color: Colors.white)
                        ),
                        trailing: Switch(
                          activeThumbColor: Theme.of(context).primaryColor,
                          activeTrackColor: Colors.white,
                          inactiveThumbColor: Colors.blueGrey.shade600,
                          inactiveTrackColor: Colors.grey.shade400,
                          splashRadius: 35.0,
                          value: isLoanEnabled,
                          onChanged: (value) => setState(() => isLoanEnabled = value),
                        ),
                      )
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 25.0),
              
              // --- Botão Prosseguir (Mantido) ---
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
                  _showConfirmDialog(context);
                },
              )
            ],
          ),
        ),
      )
    );
  }

  void _showConfirmDialog(BuildContext context){
    final gameProvider = Provider.of<GameProvider>(context, listen: false);
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.0)
          ),
          backgroundColor: Theme.of(context).primaryColor,
          title: const Text("Resumo das configurações",
              style: TextStyle(color: Colors.white)),
          content: SizedBox(
            height: 200,
            child: Column(
              children: [
                const Divider(color: Colors.white70),
                Text(
                    "Saldo inicial: \$ ${_initialCreditController.text}\nLimite de Jogadores: $dropdownValue\nBônus da rodada: ${_bonusController.text}\n"
                        "Nível: ${gameLevel.description}\n\nDeseja confirmar as configurações?",
                    style: const TextStyle(color: Colors.white)),
              ],
            ),
          ),
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
                try{
                  String generatedGameId = StringUtils.generateUUID(size: 8);
                  Map<String, Property> properties = {};
                  if (userProvider.user!.propertiesVersion![_selectedPropertyVersion] != null) {
                    for (var originalProperty in userProvider.user!.propertiesVersion![_selectedPropertyVersion]!) {
                      final newShares = int.parse(_sharesController.text);
                      final clonedProperty = originalProperty.copyWith(
                        totalShares: newShares,
                        availableShares: newShares,
                      );

                      properties[clonedProperty.id] = clonedProperty;
                    }
                  }

                  Ledger ledger =  Ledger(
                      properties: properties,
                      currentInterestRate: gameLevel.initalInterestRate,
                      propertyProfitTaxRate: gameLevel.propertyProfitTaxRate,
                      incomeTaxRate: gameLevel.incomeTaxRate,
                      lateFeeRate: gameLevel.lateFeeRate,
                      roundBonus: StringUtils.currencyAsDouble(_bonusController.text)
                  );

                  GameModelDTO gameData = GameModelDTO(
                      ledger: ledger,
                      id: generatedGameId,
                      limitPlayer: dropdownValue,
                      initalGameCredit: StringUtils.currencyAsDouble(_initialCreditController.text),
                      chancesEnabled: isChanceSwitchEnabled,
                      loanEnabled: isLoanEnabled
                  );
                  gameProvider.userModelController = Provider.of<UserProvider>(context, listen: false);
                  await gameProvider.createNewGame(game: gameData);
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const GameScreen()));
                  //.then((value) => GameModelController.of(context).exitGame());

                } on Exception catch(e){
                  ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Erro interno: $e"), backgroundColor: Colors.red));
                }
              },
              child: const Text("Confirmar", style: TextStyle(fontSize: 17.0, color: Colors.white )),
            ),
          ],
        );
      },
    );
  }
}
