import 'package:account_monopoly/dialogs/rules_dialog.dart';
import 'package:flutter/material.dart';

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
          showDialog(context: context, builder: (BuildContext context){
            return AlertDialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.0)
              ),
              backgroundColor: Colors.black,
              title: Text(
                title,
                style: const TextStyle(color: Colors.white, fontSize: 20),
                textAlign: TextAlign.center,
              ),
              content: Card(
                color: Theme.of(context).primaryColor,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                  child: Text(
                    tip, 
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w500),
                  ),
                ),
              ),
              actionsAlignment: MainAxisAlignment.center,
              actionsPadding: const EdgeInsets.fromLTRB(12, 0, 12, 16),
              actions: <Widget>[
                // Wrap garante que os botões se alinhem e quebrem linha se o espaço for curto
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 6.0,
                  runSpacing: 6.0,
                  children: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[800],
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                      child: const Text("Voltar", style: TextStyle(fontSize: 14.0, fontWeight: FontWeight.bold)),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.onInverseSurface,
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                      child: const Text("Regras", style: TextStyle(fontSize: 14.0, fontWeight: FontWeight.bold)),
                      onPressed: () {
                        Navigator.of(context).pop();
                        RulesDialog.show(context);
                      },
                    ),
                    if (onConfirm != null) 
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).primaryColor,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                        ),
                        child: const Text(
                          "Rever tutorial",
                          style: TextStyle(fontSize: 14.0, fontWeight: FontWeight.bold),
                        ),
                        onPressed: () {
                          Navigator.of(context).pop();
                          if (onConfirm != null) {
                            onConfirm!();
                          }
                        },
                      ),
                  ],
                )
              ],
            );
          });
        },
      ),
    );
  }
}