import 'package:account_monopoly/provider/game_provider.dart';
import 'package:account_monopoly/utils/string_utils.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:account_monopoly/dto/mortgage.dart';
import 'package:account_monopoly/enums/log_msg_type.dart';
import 'package:account_monopoly/dialogs/confirm_action_dialog.dart';

class NewMortgageDialog extends StatefulWidget {
  const NewMortgageDialog({super.key});

  @override
  NewMortgageDialogState createState() => NewMortgageDialogState();
}

class NewMortgageDialogState extends State<NewMortgageDialog> {

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _valueController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  static const int DEADLINE = 3;

  late GameProvider gameProvider;

  @override
  Widget build(BuildContext context) {
    gameProvider = Provider.of<GameProvider>(context);
    return Dialog(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0)), //this right here
      child: Container(
        padding: const EdgeInsets.all(8.0),
        decoration: BoxDecoration(
            color: Theme.of(context).primaryColor,
            borderRadius: BorderRadius.circular(20.0)),
        height: 420.0,
        width: 300.0,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            const Text("Contrato de Hipotéca", style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.w500, color: Colors.white)),

            Container(
              height: 300.0,
                decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                    border: Border.all(
                      color: Colors.black12,
                    ),
                    borderRadius: const BorderRadius.all(Radius.circular(20))
                ),
              child: Form(
                key: _formKey,
                child: ListView(
                  padding: const EdgeInsets.all(8.0),
                  children: [
                    const SizedBox(height: 20.0),
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                          fillColor: Colors.black12,
                          filled: true,
                          enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.black12, width: 3.0),
                              borderRadius: BorderRadius.all(Radius.circular(20))
                          ),
                          focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: Colors.white, width: 5.0
                              ),
                              borderRadius: BorderRadius.all(Radius.circular(20))
                          ),
                          hintText: "Digite o nome da propriedade"
                      ),
                      keyboardType: TextInputType.text,
                      validator: (text){
                        if(text!.isEmpty) {
                          return "Este campo deve ser preenchido";
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16.0),
                    TextFormField(
                      controller: _valueController,
                      decoration: const InputDecoration(
                        fillColor: Colors.black12,
                          filled: true,
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.black12, width: 3.0),
                              borderRadius: BorderRadius.all(Radius.circular(20))
                          ),
                          focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: Colors.white, width: 5.0
                              ),
                              borderRadius: BorderRadius.all(Radius.circular(20))
                          ),
                          hintText: "Digite o valor da Propriedade"
                      ),
                      keyboardType: TextInputType.number,
                      validator: (text){
                        RegExp equal = RegExp(r'^[.0-9]+$');
                        RegExp equal2 = RegExp(r'^((?!\.{2}|^\.|\.$).)+$');
                        if(text!.isEmpty || !equal.hasMatch(text) || !equal2.hasMatch(text)) {
                          return "Este campo só aceita números e ponto!";
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 32.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20.0)
                            ),
                            backgroundColor: Colors.red,
                            splashFactory: InkRipple.splashFactory,
                          ),
                          child: const Text("Cancelar", style: TextStyle(fontSize: 17.0, letterSpacing: 2, color: Colors.white)),
                          onPressed: () {
                            Navigator.pop(context);
                          },
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20.0)
                            ),
                            backgroundColor: Colors.green,
                            splashFactory: InkRipple.splashFactory,
                          ),
                          child: const Text("Concluir", style: TextStyle(fontSize: 17.0, letterSpacing: 2, color: Colors.white)),
                          onPressed: () {
                            if(_formKey.currentState!.validate()){
                              int toReceive = (int.parse(_valueController.text.replaceAll(".", "")) /2).floor();
                              int toPay = toReceive + (toReceive * 0.2).floor();

                              showDialog(context: context, builder:(BuildContext context){
                                return ConfirmActionDialog(
                                    title: "Confirmar Hipotéca?",
                                    textContent: "Você receberá ${StringUtils.currencyFormat(toReceive.toString())} R\$.\n"
                                        "A propriedade deverá ser entregue ao banco e só poderá ser recuperada "
                                        "mediante ao pagamento de ${StringUtils.currencyFormat(toPay.toString())} R\$.\n"
                                        " Caso não seja recuperada em 3 rodadas, a mesma será leiloada a partir do valor da hipotéca.",
                                    onConfirm: (){
                                      Mortgage mortgage = Mortgage.empty();
                                      mortgage.id = StringUtils.generateUUID(size: 4);
                                      mortgage.name = _nameController.text;
                                      mortgage.value = (int.parse(_valueController.text.replaceAll(".", "")) /2).floor();
                                      mortgage.valueToPay = toPay;
                                      mortgage.deadline = DEADLINE;
                                      mortgage.auctionMinValue = (toPay /2).floor();
                                      gameProvider.gameModelDTO!.mortgages.add(mortgage);

                                      gameProvider.eventComposer(type: LogMsgType.MORTGAGE, value: toReceive);
                                      Navigator.pop(context);
                                      Navigator.pop(context);
                                    });
                              });
                            }
                          },
                        )
                      ],
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
