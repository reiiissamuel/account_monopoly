import 'package:flutter/material.dart';

import '../model/game_model.dart';

class TableInfoDialog extends StatelessWidget {
  const TableInfoDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
      backgroundColor: Colors.black,
      title: const Text("Id da Mesa", style: TextStyle(color: Colors.white)),
      content: Text(GameModelController.of(context).gameModelDTO!.id,
          textAlign: TextAlign.center,
          style: const TextStyle(
              color: Colors.white,
              fontSize: 20.0,
              fontWeight: FontWeight.w500)),
      actions: <Widget>[
        // define os botões na base do dialogo
        TextButton(
          child: const Text("Voltar",
              style: TextStyle(fontSize: 17.0, letterSpacing: 2.0)),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}
