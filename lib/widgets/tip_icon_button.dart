import 'package:flutter/material.dart';

import 'package:account_monopoly/dialogs/tip_alert_dialog.dart';

class TipIconButton extends StatelessWidget {

  final VoidCallback? onConfirm; 

  final String title;
  final String tip;
  final double? height;
  final double? width;
  final double? iconSize;


  const TipIconButton({super.key, required this.title, required this.tip, this.height, this.width, this.iconSize, this.onConfirm});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),
      child: GestureDetector(
        child: SizedBox(
          height: height ?? 20.0,
          width: width ?? 20.0,
          child: Icon(Icons.question_mark_rounded, color: Theme.of(context).colorScheme.onInverseSurface)
        ),
        onTap: (){
          showDialog(context: context, builder: (BuildContext contexct){
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
                  child: Text("Rever tutorial na tela",style: TextStyle(fontSize: 17.0, letterSpacing: 2.0, color: Theme.of(context).primaryColor)),
                  onPressed: () {
                    Navigator.of(context).pop();
                    if (onConfirm != null) {
                      onConfirm!();
                    }
                  },
                ),
                ElevatedButton(
                  child: Text("Voltar",style: TextStyle(fontSize: 17.0, letterSpacing: 2.0, color: Theme.of(context).primaryColor)),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          });
        },
      ),
    );
  }
}