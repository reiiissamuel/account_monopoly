
import 'package:account_monopoly/utils/string_utils.dart';
import 'package:flutter/material.dart';

import 'package:account_monopoly/domain/chance.dart';

class ChanceDialog extends StatelessWidget {


  final Chance chance;
  const ChanceDialog(this.chance, {super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape:
      RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
      backgroundColor: Colors.black,
      title: const Text( "Evento",
          style: TextStyle(color: Colors.white, letterSpacing: 2.0)
      ),
      content: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            alignment: Alignment.center,
            height: 200.0,
            margin: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 16.0),
            padding: const EdgeInsets.all(4.0),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
              borderRadius: BorderRadius.circular(20.0)
            ),
            child: Text(chance.description!, style: const TextStyle(color: Colors.white, letterSpacing: 2.0, fontSize: 16.0), maxLines: 7),
          ),
          chance.effect! < 0
              ? Text("Você Pagará: ${StringUtils.currencyFormat(chance.effect.toString().replaceAll("-", ""))}",
                  style: const TextStyle(color: Colors.white, letterSpacing: 2.0)
          )
              : chance.effect! > 0
                  ? Text("Você Receberá: ${StringUtils.currencyFormat(chance.effect.toString())}", style: const TextStyle(color: Colors.white, letterSpacing: 2.0))
                  : const Text("Sem premiação em dinheiro", style: TextStyle(color: Colors.white, letterSpacing: 2.0))
        ],
      ),

      actions: <Widget>[
        TextButton(
          child: const Text("Continuar", style: TextStyle(fontSize: 17.0)),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}
