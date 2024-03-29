import 'package:flutter/material.dart';

import '../enums/log_msg_type.dart';
import '../model/game_model.dart';
import '../utils/string_utils.dart';
import 'confirm_action_dialog.dart';

class LoanDialog extends StatefulWidget {

  @override
  LoanDialogState createState() => LoanDialogState();

  const LoanDialog({super.key});
}

class LoanDialogState extends State<LoanDialog> {

  String _loanValueSelected = "500.000";
  final List <String> _loanValueList = ["500.000","750.000","1.000.000","1.500.000","2.000.000"];
  int _turnValueSelected = 3;
  final List <int> _turnValueList = [2,3,4,5];
  final TextEditingController _editingController = TextEditingController();


  @override
  void initState() {
    _updateValue(GameModelController.of(context));
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0)), //this right here
      child: Container(
        padding: const EdgeInsets.all(8.0),
        decoration: BoxDecoration(
            color: Theme.of(context).primaryColor,
            borderRadius: BorderRadius.circular(20.0)),
        height: 421.0,
        width: 300.0,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            const Text("Empréstimo", style: TextStyle(fontSize: 23.0, fontWeight: FontWeight.w500, color: Colors.white, letterSpacing: 2)),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                const Text("Valor:", style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.w500, color: Colors.white)),
                DropdownButton<String>(
                  value: _loanValueSelected,
                  icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
                  iconSize: 24,
                  elevation: 16,
                  style: const TextStyle(color: Colors.black, fontSize: 18),
                  underline: Container(
                    height: 1,
                    color: Colors.white,
                  ),
                  onChanged: (String ?data) {
                    setState(() {
                      _loanValueSelected = data != null ? data : _loanValueSelected;
                      _updateValue(GameModelController.of(context));
                    });
                  },
                  items: _loanValueList.map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                )
              ],
            ),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                const Text("Parcelas:", style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.w500, color: Colors.white)),
                DropdownButton<int>(
                  value: _turnValueSelected,
                  icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
                  iconSize: 24,
                  elevation: 16,
                  style: const TextStyle(color: Colors.black, fontSize: 18),
                  underline: Container(
                    height: 1,
                    color: Colors.white,
                  ),
                  onChanged: (int ?data) {
                    setState(() {
                      _turnValueSelected = data ?? _turnValueSelected ;
                      _updateValue(GameModelController.of(context));
                    });
                  },
                  items: _turnValueList.map<DropdownMenuItem<int>>((int value) {
                    return DropdownMenuItem<int>(
                      value: value,
                      child: Text(value.toString()),
                    );
                  }).toList(),
                )
              ],
            ),

            Container(
              height: 50.0,
              margin: const EdgeInsets.only(top: 8.0, bottom: 16.0),
              padding: const EdgeInsets.all(4.0),
              decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 0, 52, 98),
                  borderRadius: BorderRadius.circular(20.0)),
              child: TextField(
                  cursorColor: Colors.white,
                  controller: _editingController,
                  readOnly: true,
                  maxLines: 1,
                  style: const TextStyle(
                      fontSize: 25.0,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 2,
                      color: Colors.white
                  ),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    errorBorder: InputBorder.none,
                    disabledBorder: InputBorder.none,
                    prefixIcon: Icon(Icons.attach_money, color: Colors.white),
                  )),
            ),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    backgroundColor: Colors.white,
                  ),
                  child: const Text("Cancelar", style: TextStyle(fontSize: 17.0, letterSpacing: 2)),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    backgroundColor: Colors.white,
                  ),
                  child: const Text("Concluir", style: TextStyle(fontSize: 17.0, letterSpacing: 2)),
                  onPressed: () {
                    showDialog(context: context, builder: (BuildContext context){
                      return ConfirmActionDialog(
                          title: "Alerta de Empréstimo",
                          textContent: "Você confirma o empréstimo?" ,
                          onConfirm: (){
                            GameModelController.of(context).eventComposer(
                              type: LogMsgType.LOAN,
                              value: int.parse(_loanValueSelected.replaceAll(".", "")),
                              installments: _turnValueSelected
                            );
                            Navigator.of(context).pop();
                            Navigator.of(context).pop();
                            Navigator.of(context).pop();
                          });
                    });
                  },
                )
              ],
            )
          ],
        ),
      ),
    );
  }

  void _updateValue(GameModelController model){
    int tax = _turnValueSelected * model.gameModelDTO!.levelTax;
    int valueToPay = int.parse(_loanValueSelected.replaceAll(".", "")) + ((tax * int.parse(_loanValueSelected.replaceAll(".", ""))) / 100).floor();
    setState(() {
      _editingController.text = StringUtils.currencyFormat(valueToPay.toString());
    });
  }
}
