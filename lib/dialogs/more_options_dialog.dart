import 'package:account_monopoly/exception/domain_exception.dart';
import 'package:account_monopoly/provider/game_provider.dart';
import 'package:account_monopoly/utils/string_utils.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:account_monopoly/domain/enums/event_type.dart';
import 'package:account_monopoly/screens/chances_screen.dart';
import 'package:account_monopoly/dialogs/confirm_action_dialog.dart';
import 'package:account_monopoly/dialogs/custom_keyboard_dialog.dart';

class MoreOptionsDialog extends StatelessWidget {

  const MoreOptionsDialog({super.key});


  @override
  Widget build(BuildContext context) {
    GameProvider gameProvider = Provider.of<GameProvider>(context);
    return Dialog(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0)), //this right here
      child: Container(
        padding: const EdgeInsets.all(8.0),
        decoration: BoxDecoration(
            color: Theme.of(context).primaryColor,
            borderRadius: BorderRadius.circular(20.0)),
        height: 510.0,
        width: 400.0,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _optionButton(
                context: context,
                img: "icons/ir.png",
                title: "Pagar imposto de renda",
                dialog: ConfirmActionDialog(
                    title: "Pagar imposto de renda?",
                    textContent: "Serão deduzidos ${StringUtils.currencyFormat(gameProvider.currentPlayer.incomeTax)} da sua conta.",
                    onConfirm: () => _payIncomeTax(context, gameProvider)
                )),

            _optionButton(context: context, img: "icons/rest.png", title: "Restituição",
                dialog: ConfirmActionDialog(title: "Restituição",
                    textContent: "O banco irá calcular sua restituição para depositar em sua conta.",
                    onConfirm: () {
                      gameProvider.eventComposer(type: EventType.receiveTax);
                      Navigator.of(context).pop();
                      Navigator.of(context).pop();
                    })),
            _optionButton(context: context, img: "icons/receive.png", title: "Receber do banco",
                dialog: const CustomKeyboard(
                    title: "Digite o valor a receber",
                    eventType: EventType.receiveFromBank)),
            _optionButton(context: context, img: "icons/paybank.png", title: "Pagar banco",
                dialog: const CustomKeyboard(
                    title: "Digite o valor a ser pago",
                    eventType: EventType.payBank,
                )),
            _optionButton(context: context, img: "icons/bonus.png", title: "Deseja retirar seu bonus?",
                dialog: ConfirmActionDialog(title: "Deseja retirar seu bonus?",
                    textContent: "O valor será depositado em sua conta.",
                    onConfirm: () {
                      gameProvider.processRoundEnding();
                      Navigator.of(context).pop();
                      Navigator.of(context).pop();
              })),
            _optionButton(
                context: context,
                img: "icons/benefits.png",
                title: "Benefícios",
                enabled: gameProvider.gameModelDTO!.chancesEnabled,
                screen: const ChancesScreen()
            )
          ],
        ),
      ),
    );
  }

  void _payIncomeTax(BuildContext context, GameProvider gameProvider) {
    try{
      Navigator.of(context).pop();
      Navigator.of(context).pop();
      gameProvider.currentPlayer.incomeTax;
      gameProvider.eventComposer(
          type: EventType.payTax
      );
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Pagamento efetuado"), backgroundColor: Colors.green));
    } on DomainException catch(e){
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message), backgroundColor: Colors.red));
    }
  }
}

Widget _optionButton({required BuildContext context, required String img, required String title,
  Widget ?dialog, Widget ?screen, Function ?onPressed, bool ?enabled}){
  if(enabled != null && !enabled){
    return Container();
  }
  return SizedBox(
    height: 60.0,
    width: 230.0,
    child: ElevatedButton(
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.all(4.0),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0), side: const BorderSide(color: Colors.black)),
        ),
      onPressed: onPressed != null
            ? () => onPressed
            : () {
                if (screen != null) {
                  Navigator.push(
                      context, MaterialPageRoute(builder: (context) => screen));
                } else if (dialog != null) { // Adicionamos esta verificação
                  showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return dialog;
                      });
                }
              },
        child: Row(
          children: [
          SizedBox(
            height: 50.0,
            width: 50.0,
            child: Image.asset(img,
                fit: BoxFit.contain),
          ),
          SizedBox(height: 150.0, child: VerticalDivider(color: Theme.of(context).primaryColor)),
          Expanded(
            child: Text(title, style:  TextStyle(fontSize: 15.0, color: Theme.of(context).primaryColor, letterSpacing: 2.0, fontWeight:FontWeight.w500)),
          )
        ],
      ),
    )
  );
}
