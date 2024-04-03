import 'package:flutter/material.dart';

class ConfirmActionDialog extends StatelessWidget {

  final String title;
  final String textContent;
  final Function  onConfirm;

  const ConfirmActionDialog({super.key, required this.title, required this.textContent, required this.onConfirm});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape:
      RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
      backgroundColor: Colors.black,
      title: Text(title, style: const TextStyle(color: Colors.white)),
      content: Text(textContent, style: const TextStyle(color: Colors.white)),

      actions: <Widget>[
        // define os botões na base do dialogo
        TextButton(
          child: Text("Cancelar", style: TextStyle(fontSize: 17.0, color: Theme.of(context).primaryColor)),
          onPressed: () => Navigator.pop(context)
        ),
        TextButton(
            onPressed: () => onConfirm(),
            child: Text("Prosseguir", style: TextStyle(fontSize: 17.0, color: Theme.of(context).primaryColor))
        ),
      ],
    );
  }


}
