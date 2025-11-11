/* import 'package:account_monopoly/provider/game_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:account_monopoly/utils/string_utils.dart';

class AccountDescription extends StatelessWidget {


  const AccountDescription({super.key});

  @override
  Widget build(BuildContext context) {
    var account = Provider.of<GameProvider>(context, listen: false).gameModelDTO!.account;
    return AlertDialog(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0)
      ),
      backgroundColor: Theme.of(context).primaryColor,
      title: Text("Fatura Atual Rodada ${account.round}",
          style: const TextStyle(color: Colors.white)),
      content: Text(
          "Compras: ${StringUtils.currencyFormat(account.qtdPurchases.toString())}\n"
              "Pagamentos: ${StringUtils.currencyFormat(account.qtdEventPay.toString())}\n"
              "Recebimentos: ${StringUtils.currencyFormat(account.qtdEventGain.toString().replaceAll("-", ""))}\n"
              "Casas: ${StringUtils.currencyFormat(account.qtdHome.toString())}\n"
              "Hoteis: ${StringUtils.currencyFormat(account.qtdHotel.toString())}\n"
              "Empréstimo: ${StringUtils.currencyFormat(account.loanInstallment.toString())}\n"
              "Fatura Parcelada: ${StringUtils.currencyFormat(account.previousAccountInstallment.toString())}\n"
              "Restituições: ${StringUtils.currencyFormat(account.restituicao.toString())}\n"
              "Imposto de renda: ${StringUtils.currencyFormat(account.ir.toString())}\n"
              "Bônus: ${StringUtils.currencyFormat(account.bonus.toString())}\n\n"
              "Total: \$ ${StringUtils.currencyFormat(account.getTotal().toString())}",
          style: const TextStyle(color: Colors.white)),
      actions: <Widget>[

        TextButton(
          style: TextButton.styleFrom(
            elevation: 6,
            //minimumSize: Size(_width, _height),
            backgroundColor: Colors.black38,
            padding: const EdgeInsets.all(0),
          ),
          child: const Text("Voltar", style: TextStyle(fontSize: 17.0, color: Colors.white)),
          onPressed: () {
            Navigator.of(context).pop();
          },
        )
      ],
    );
  }
}


 */