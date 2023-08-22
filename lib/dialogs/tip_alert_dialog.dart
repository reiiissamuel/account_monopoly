import 'package:flutter/material.dart';

class TipDialog extends StatelessWidget {

  final String title;
  final String tip;


  const TipDialog({super.key, required this.title, required this.tip});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0)
      ),
      backgroundColor: Colors.black,
      title: Text(title,
          style: const TextStyle(color: Colors.white, fontSize: 20)),
      content: Card(
        color: Theme.of(context).primaryColor,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
          child: Text(tip, textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w500)),
        ),
      ),
      actions: <Widget>[
        // define os botões na base do dialogo
        ElevatedButton(
          child: const Text("OK",style: TextStyle(fontSize: 17.0, letterSpacing: 2.0)),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }


}