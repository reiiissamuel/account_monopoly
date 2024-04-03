import 'package:account_monopoly/dto/account.dart';
import 'package:account_monopoly/provider/game_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../enums/keyboard_operation.dart';
import '../enums/log_msg_type.dart';
import '../screens/chances_screen.dart';
import '../screens/set_auction_screen.dart';
import 'confirm_action_dialog.dart';
import 'custom_keyboard_dialog.dart';
import 'loan_dialog.dart';

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
                title: "Imposto de renda",
                dialog: ConfirmActionDialog(
                    title: "Pagar imposto de renda",
                    textContent: "Confirmar Pagamento 200.000?",
                    onConfirm: () {
                      gameProvider.eventComposer(type: LogMsgType.CURRENT_ACCOUNT_UPDATE_DOWN);
                      Navigator.of(context).pop();
                      Navigator.of(context).pop();
                    })),

            _optionButton(context: context, img: "icons/rest.png", title: "Restituição",
                dialog: ConfirmActionDialog(title: "Restituição",
                    textContent: "Confirmar recebimento 200.000?",
                    onConfirm: () {
                      gameProvider.eventComposer(type: LogMsgType.CURRENT_ACCOUNT_UPDATE_UP);
                      Navigator.of(context).pop();
                      Navigator.of(context).pop();
                    })),
            _optionButton(context: context, img: "icons/receive.png", title: "Receber",
                dialog: const CustomKeyboard(
                    title: "Digite o valor a receber",
                    playerToPayId: "",
                    eventType: LogMsgType.RECEIVE_FROM_BANK)),
            _optionButton(context: context, img: "icons/paybank.png", title: "Pagar banco",
                dialog: const CustomKeyboard(
                  title: "Digite o valor a ser pago",
                  playerToPayId: "",
                  eventType: LogMsgType.PAY_BANK,
                )),

            _optionButton(context: context, img: "icons/bit.png", title: "Leiloar Propriedade",
                screen: const SetAuctionScreen()),

            _optionButton(context: context, img: "icons/loan.png", title: "Pegar Empréstimo",
                onPressed: Provider.of<GameProvider>(context).hasAnyLoanRunning() ? () {} : null,
                dialog: Provider.of<GameProvider>(context).hasAnyLoanRunning()  ? null : const LoanDialog()
            ),
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
                } else {
                  showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return dialog!;
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
