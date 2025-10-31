import 'package:account_monopoly/provider/game_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';


class TableInfoDialog extends StatelessWidget {
  const TableInfoDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
      backgroundColor: Theme.of(context).primaryColor,
      title: const Text("PeerId da Mesa", style: TextStyle(fontSize: 15, color: Colors.white)),
      icon: IconButton(icon: const Icon(Icons.copy, color: Colors.white, size: 20), onPressed: () {
        Clipboard.setData(ClipboardData(text: Provider.of<GameProvider>(context, listen: false).peerConnectionController!.myPeerId));
        Fluttertoast.showToast(msg: "Copiado!");
      },),
      content: SelectableText(Provider.of<GameProvider>(context, listen: false).peerConnectionController!.myPeerId,
          textAlign: TextAlign.center,
          style: const TextStyle(
              color: Colors.black,
              fontSize: 14.0,
              fontWeight: FontWeight.bold)),
      actions: <Widget>[
        // define os botões na base do dialogo
        TextButton(
          child: const Text("Voltar",
              style: TextStyle(color: Colors.white, fontSize: 17.0, letterSpacing: 2.0)),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}
