import 'package:flutter/material.dart';

import '../enums/keyboard_operation.dart';
import '../enums/log_msg_type.dart';
import '../model/game_model.dart';
import '../screens/chances_screen.dart';
import '../screens/set_auction_screen.dart';
import 'confirm_action_dialog.dart';
import 'custom_keyboard_dialog.dart';
import 'loan_dialog.dart';

class MoreOptionsDialog extends StatelessWidget {

  const MoreOptionsDialog({super.key});

  @override
  Widget build(BuildContext context) {
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
            _optionButton(context, "icons/ir.png", "Pagar Imposto de Renda", (){
              showDialog(context: context, builder: (BuildContext context){
                return ConfirmActionDialog(title: "Pagar imposto de renda", textContent: "Confirmar Pagamento 200.000?", onConfirm: (){
                  GameModelController.of(context).gameModelDTO!.account.ir += 200000;
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
                });
              }).then((value){});
            }),
            _optionButton(context, "icons/rest.png", "Restituição", (){
              showDialog(context: context, builder: (BuildContext context){
                return ConfirmActionDialog(title: "Restituição", textContent: "Confirmar recebimento 200.000?", onConfirm: (){
                  GameModelController.of(context).gameModelDTO!.account.restituicao += 200000;
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
                });
              });
            }),

            _optionButton(context, "icons/benefits.png", "Benefícios", (){
              Navigator.push(context, MaterialPageRoute(builder: (context) => const ChancesScreen()));
            }),

            _optionButton(context, "icons/receive.png", "Receber", (){
              showDialog(context: context, builder: (BuildContext context){
                return const CustomKeyboard(title: "Digite o valor a receber", keyO: KeyboardOparation.TRANSFER_IN, playerToPayId: "", logMsgType: LogMsgType.RECEIVE_FROM_BANK,);
              });
            }),

            _optionButton(context, "icons/paybank.png", "Pagar banco", (){
              showDialog(context: context, builder: (BuildContext context){
                return const CustomKeyboard(title: "Digite o valor a pagar", keyO: KeyboardOparation.TRANSFER_OUT, logMsgType: LogMsgType.PAY_BANK, playerToPayId: "");
              });
            }),

            _optionButton(context, "icons/bit.png", "Leiloar Propriedade", (){
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (context)=>const SetAuctionScreen()));
            }),
            _optionButton(context, "icons/loan.png", "Pegar Empréstimo",
                GameModelController.of(context).gameModelDTO!.balance.accounts.any(
                        (ac) => (ac.loanInstallment > 0 && ac.round >= GameModelController.of(context).gameModelDTO!.balance.round))
                    ? () {}
                    : () {
                        showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return const LoanDialog();
                            });
                      }),
          ],
        ),
      ),
    );
  }
}

Widget _optionButton(BuildContext context, String img, String title, Function onPressed){
  return SizedBox(
    height: 60.0,
    width: 230.0,
    child: ElevatedButton(
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.all(4.0),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0), side: const BorderSide(color: Colors.black)),
      ),
      onPressed: onPressed(),
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
