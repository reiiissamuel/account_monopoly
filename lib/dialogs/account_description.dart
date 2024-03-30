import 'package:flutter/material.dart';

import '../dto/account.dart';
import '../utils/string_utils.dart';

class AccountDescription extends StatelessWidget {

  final Account _account;
  const AccountDescription( this._account, {super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0)
      ),
      backgroundColor: Theme.of(context).primaryColor,
      title: const Text("Fatura Atual",
          style: TextStyle(color: Colors.white)),
      content: Text(
          "Compras: ${StringUtils.currencyFormat(_account.qtdPurchases.toString())}\n"
              "Pagamentos: ${StringUtils.currencyFormat(_account.qtdEventPay.toString())}\n"
              "Recebimentos: ${StringUtils.currencyFormat(_account.qtdEventGain.toString().replaceAll("-", ""))}\n"
              "Casas: ${StringUtils.currencyFormat(_account.qtdHome.toString())}\n"
              "Hoteis: ${StringUtils.currencyFormat(_account.qtdHotel.toString())}\n"
              "Empréstimo: ${StringUtils.currencyFormat(_account.loanInstallment.toString())}\n"
              "Fatura Parcelada: ${StringUtils.currencyFormat(_account.previousAccoutInstallment.toString())}\n"
              "Restituições: ${StringUtils.currencyFormat(_account.restituicao.toString())}\n"
              "Imposto de renda: ${StringUtils.currencyFormat(_account.ir.toString())}\n"
              "Bônus: ${StringUtils.currencyFormat(_account.bonus.toString())}\n\n"
              "Total: \$ ${StringUtils.currencyFormat(_account.getTotal().toString())}",
          style: const TextStyle(color: Colors.white)),
      actions: <Widget>[

        TextButton(
          style: TextButton.styleFrom(
            //minimumSize: Size(_width, _height),
            backgroundColor: Colors.black,
            padding: const EdgeInsets.all(0),
          ),
          child: const Text("Voltar", style: TextStyle(fontSize: 17.0)),
          onPressed: () {
            Navigator.of(context).pop();
          },
        )
      ],
    );
  }
}


