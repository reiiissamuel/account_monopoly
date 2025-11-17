import 'package:flutter/material.dart';

import 'package:account_monopoly/dialogs/tip_alert_dialog.dart';

class TipIconButton extends StatelessWidget {

  final String title;
  final String tip;
  final double? height;
  final double? width;
  final double? iconSize;


  const TipIconButton({super.key, required this.title, required this.tip, this.height, this.width, this.iconSize});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),
      child: GestureDetector(
        child: SizedBox(
          height: height ?? 20.0,
          width: width ?? 20.0,
          child: const Icon(Icons.question_mark_rounded, color: Colors.white)
        ),
        onTap: (){
          showDialog(context: context, builder: (BuildContext contexct){
            return TipDialog(
              title: title,
              tip: tip
              );
          });
        },
      ),
    );
  }
}