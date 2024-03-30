import 'package:account_monopoly/enums/log_msg_type.dart';
import 'package:account_monopoly/model/game_model.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:scoped_model/scoped_model.dart';

import '../dto/account.dart';
import '../screens/home_screen.dart';
import '../utils/string_utils.dart';
import 'confirm_action_dialog.dart';
import 'loan_dialog.dart';
import 'new_mortgage_dialog.dart';


class CloseAccountDialog extends StatelessWidget {

 Account account = Account.empty();

  CloseAccountDialog({super.key});

  @override
  Widget build(BuildContext context){
    return PopScope(canPop: false,
        child: ScopedModelDescendant<GameModelController>(
          builder: (context, child, model){
            if(model.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            account =  model.gameModelDTO!.account;
            return Card(
              color: Colors.black.withOpacity(0.8),
              child: Container(
                  width: MediaQuery.of(context).size.width -50,
                  height: MediaQuery.of(context).size.height -80,
                  padding: const EdgeInsets.all(20.0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20.0),
                    color: Colors.black.withOpacity(0.8),
                  ),
                  child: ListView(
                    children: [
                      Text("Fechamento Fatura(Rodada ${account.round})",
                          style: const TextStyle(
                              fontSize: 20.0, fontWeight: FontWeight.w300, color: Colors.white)),
                      Container(
                        padding: const EdgeInsets.all(32.0),
                        decoration: BoxDecoration(
                            color: Theme.of(context).primaryColor,
                            borderRadius: BorderRadius.circular(20.0)),
                        child: Text(
                            "Compras: ${StringUtils.currencyFormat(account.qtdPurchases.toString())}\n"
                                "Pagamentos: ${StringUtils.currencyFormat(account.qtdEventPay.toString())}\n"
                                "Recebimentos: -${StringUtils.currencyFormat(account.qtdEventGain.toString())}\n"
                                "Casas: ${StringUtils.currencyFormat(account.qtdHome.toString())}\n"
                                "Hotéis: ${StringUtils.currencyFormat(account.qtdHotel.toString())}\n"
                                "Empréstimo:${StringUtils.currencyFormat(account.loanInstallment.toString())}\n"
                                "Fatura Parcelada: ${StringUtils.currencyFormat(account.previousAccountInstallment.toString())}\n"
                                "Restituições: -${StringUtils.currencyFormat(account.restituicao.toString())}\n"
                                "Imposto de renda: ${StringUtils.currencyFormat(account.ir.toString())}\n"
                                "Bônus: -${StringUtils.currencyFormat(account.bonus.toString())}\n\n"
                                "Total: \$ ${StringUtils.currencyFormat(account.getTotal().toString())}",
                            style: const TextStyle(color: Colors.white, fontSize: 17.0)),
                      ),
                      const SizedBox(height: 8.0),

                      account.getTotal() > 0
                          ?
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20.0)
                          ),
                          backgroundColor: Theme.of(context).primaryColor,
                        ),
                        child: const Text("Pagar total", style: TextStyle(fontSize: 17.0)),
                        onPressed: () {
                          if(model.hasEnoughBalance(account.getTotal())) {
                            showDialog(context: context, builder: (BuildContext contex){
                              return ConfirmActionDialog(
                                  title: "Alerta de Pagamento!",
                                  textContent: "Confirmar pagamento total da fatura?",
                                  onConfirm: (){
                                    model.eventComposer(type: LogMsgType.CLOSE_TURN);
                                  });
                            });
                          } else {
                            Fluttertoast.showToast(msg: "Saldo insuficiente para o pagamento total!");
                          }
                        },
                      )
                          :
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20.0)
                          ),
                          backgroundColor: Theme.of(context).primaryColor,
                        ),
                        child: const Text("Receber crédito", style: TextStyle(fontSize: 17.0)),
                        onPressed: () {
                          model.eventComposer(type: LogMsgType.CLOSE_TURN);
                          Navigator.of(context).pop();
                        },
                      ),

                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20.0)
                          ),
                          backgroundColor: Theme.of(context).primaryColor,
                        ),
                        onPressed: account.getTotal() <= 0 ? null : () {
                          showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return const NewMortgageDialog();
                              });
                        },
                        child: const Text("Hipotecar", style: TextStyle(fontSize: 16.0)),
                      ),

                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20.0)
                          ),
                          backgroundColor: Theme.of(context).primaryColor,
                        ),
                        onPressed: (account.getTotal() <= 0 || model.hasAnyLoanRunning())  ? null : () {
                          showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return const LoanDialog();
                              });
                        },
                        child: const Text("Pedir Empréstimo", style: TextStyle(fontSize: 16.0)),
                      ),

                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20.0)
                          ),
                          backgroundColor: Theme.of(context).primaryColor,
                        ),
                        onPressed: (account.previousAccountInstallment > 0 || account.getTotal() <= 0) ? null : () {
                          showDialog(context: context, builder: (BuildContext context){
                            return ConfirmActionDialog(title: "Alerta de Parcelamento!", textContent: "Confirma o parcelamento da fatura em 2x?"
                                "\n\nJuros aplicado sobre do valor total: ${2*StringUtils.setTax("")}%",
                                onConfirm: (){
                                  model.eventComposer(type: LogMsgType.CLOSE_TURN, installments: 2);
                                  Navigator.of(context).pop();
                                  Navigator.of(context).pop();
                              });
                          });
                        },
                        child: Text("Parcelar em 2x (+${2*model.gameModelDTO!.levelTax}%)", style: const TextStyle(fontSize: 16.0)),
                      ),

                     ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20.0)
                          ),
                          backgroundColor: Theme.of(context).primaryColor,
                        ),
                        onPressed: (account.previousAccountInstallment > 0 || account.getTotal() <= 0) ? null : () {
                          showDialog(context: context, builder: (BuildContext context){
                            return ConfirmActionDialog(
                                title: "Alerta de Parcelamento!",
                                textContent: "Confirma o parcelamento da fatura em 3x?"
                                "\n\nJuros aplicado sobre do valor total: ${3*StringUtils.setTax(model.gameModelDTO!.levelTax.toString())}%",
                                onConfirm: (){
                                  model.eventComposer(type: LogMsgType.CLOSE_TURN, installments: 3);
                              Navigator.of(context).pop();
                              Navigator.of(context).pop();

                            });
                          });
                        },
                        child: Text("Parcelar em 3x (+${3*StringUtils.setTax(model.gameModelDTO!.levelTax.toString())}%)", style: const TextStyle(fontSize: 16.0)),
                      ),

                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20.0)
                          ),
                          backgroundColor: Theme.of(context).primaryColor,
                        ),
                        onPressed: account.getTotal() <= 0 ? null : () {
                          showDialog(context: context, builder: (BuildContext context){
                            return ConfirmActionDialog(title: "Alerta de falência", textContent: "Deseja declarar falência?", onConfirm: (){
                              model.eventComposer(type: LogMsgType.BANKRUPTCY);
                              Navigator.pushReplacement(context, MaterialPageRoute(builder:(context)=>const HomeScreen()));
                            });
                          });
                        },
                        child: const Text("Declarar falência", style: TextStyle(fontSize: 16.0, color: Colors.white)),
                      ),
                    ],
                  )
              ),
            );
          },
        ) );
  }

}


