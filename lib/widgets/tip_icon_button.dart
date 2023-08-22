import 'package:flutter/material.dart';

import '../dialogs/tip_alert_dialog.dart';

class TipIconButton extends StatelessWidget {

  final String title;
  final String tip;


  const TipIconButton({super.key, required this.title, required this.tip});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
      child: GestureDetector(
        child: SizedBox(
          height: 20.0,
          width: 20.0,
          child: Image.asset("icons/question.png",
              fit: BoxFit.contain),
        ),
        onTap: (){
          showDialog(context: context, builder: (BuildContext contexct){
            return TipDialog(title: title, tip: tip);
          });
        },
      ),
    );
  }
}