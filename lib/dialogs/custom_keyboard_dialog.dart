import 'package:account_monopoly/model/game_model.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../enums/keyboard_operation.dart';
import '../enums/log_msg_type.dart';
import '../utils/string_utils.dart';
import 'confirm_action_dialog.dart';

class CustomKeyboard extends StatefulWidget {

  final String title;
  final KeyboardOparation keyO;
  final LogMsgType logMsgType;
  final String playerToPayId;

  const CustomKeyboard({super.key, required this.title, required this.keyO, required this.logMsgType, required this.playerToPayId});

  @override
  CustomKeyboardState createState() => CustomKeyboardState();
}

class CustomKeyboardState extends State<CustomKeyboard> {
  TextEditingController valueController = TextEditingController();

  @override
  void initState() {
    setState(() {
      valueController.text = "0";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0)), //this right here
      child: Container(
        decoration: BoxDecoration(
            color: Theme.of(context).primaryColor,
            borderRadius: BorderRadius.circular(20.0)),
        height: 421.0,
        width: 300.0,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(widget.title,
                    style: const TextStyle(
                        fontSize: 20.0, fontWeight: FontWeight.w300, color: Colors.white)),
                Container(
                  height: 50.0,
                  margin: const EdgeInsets.only(top: 8.0, bottom: 16.0),
                  padding: const EdgeInsets.all(4.0),
                  decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 0, 52, 98),
                      borderRadius: BorderRadius.circular(20.0)),
                  child: TextField(
                      cursorColor: Colors.white,
                      controller: valueController,
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
                SizedBox(
                  height: 300.0,
                  child: GridView(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4,
                      mainAxisSpacing: 4.0,
                      crossAxisSpacing: 4.0,
                    ),
                    //crossAxisCount: 3,
                    children: List.generate(16, (index) {
                      return numberButton(index);
                    }),
                  ),
                )
            ]),
        ),
      ),
    );
  }

  Widget numberButton(int i) {
    return ElevatedButton(
      style: ButtonStyle(   
        overlayColor: MaterialStateProperty.all(Colors.blue),
        backgroundColor: MaterialStateProperty.all(Colors.black),          
        ),
      onPressed: i != 15 ? (){buttonFunction(i);} : valueController.text == "0" ? null : (){_finishOperation();},
      child: buttonChildBuild(i)
    );
  }

  void _finishOperation(){
    int value = int.parse(valueController.text.replaceAll(".", ""));

    if(widget.keyO == KeyboardOparation.ACCOUT_UPDATE) {
      if(GameModelController.of(context).hasEnoughBalance(value)) {
        showDialog(context: context, builder: (BuildContext context){
        return ConfirmActionDialog(title: "Alerta de Compra!", textContent: "Você Confirma o pagamento de $value?", onConfirm: (){
          GameModelController.of(context).eventComposer(type: widget.logMsgType, value: value);
          Navigator.of(context).pop();
          Navigator.of(context).pop();
        });
      });
      } else {
        _paymentFail();
      }
      }
    else if(widget.keyO == KeyboardOparation.TRANSFER_IN) {
      showDialog(context: context, builder: (BuildContext context){
        return ConfirmActionDialog(title: "Alerta de Rebebimento!", textContent: "Você Confirma o recebimento de $value?", onConfirm: (){
          GameModelController.of(context).eventComposer(type: LogMsgType.RECEIVE_FROM_BANK, value: value);
          Navigator.of(context).pop();
          Navigator.of(context).pop();
        });
      });
    }
    else if(widget.keyO == KeyboardOparation.TRANSFER_OUT){
          if(GameModelController.of(context).hasEnoughBalance(value)) {
            showDialog(context: context, builder: (BuildContext context){
            return ConfirmActionDialog(title: "Alerta de Pagamento!", textContent: widget.playerToPayId == "" ? "Você Confirma o pagamento de $value?"
                : "Confirmar tranferência de $value para ${GameModelController.of(context).gameModelDTO!.players.firstWhere((p) => p.id == widget.playerToPayId).username}?",
                onConfirm: (){
              GameModelController.of(context).eventComposer(
                  type: widget.logMsgType,
                  value: value,
                  destinationPlayer: GameModelController.of(context).gameModelDTO!.players.firstWhere((p) => p.id == widget.playerToPayId)
              );
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            });
          });
          } else {
            _paymentFail();
          }
    }
  }

  int cont = 1;
  Widget buttonChildBuild(int i){
    switch(i){
      case 3:
        return Icon(Icons.backspace, color: Theme.of(context).primaryColor);
      case 7:
        return const Text("C", style: TextStyle(fontSize: 25.0, fontWeight: FontWeight.bold));
      case 11:
        return const Icon(Icons.cancel, color: Colors.red);
      case 12:
        return const Text("00", style: TextStyle(fontSize: 25.0, fontWeight: FontWeight.bold));
      case 13:
        return const Text("0", style: TextStyle(fontSize: 25.0, fontWeight: FontWeight.bold));
      case 14:
        return const Text("000", style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold));
      case 15:
        cont = 1;
        return const Icon(Icons.done, color: Colors.green);
      default:
        return Text("${cont++}", style: const TextStyle(fontSize: 25.0));
    }
  }

  void buttonFunction(int i){

    String value = valueController.text.replaceAll(".", "");

    switch(i){
      case 3:
        updateTextField(value.substring(0,value.length -1));
        break;
      case 7:
        updateTextField("0");
        break;
      case 11:
         Navigator.of(context).pop();
         break;
      case 12:
        updateTextField("${value}00");
        break;
      case 13:
        updateTextField("${value}0");
        break;
      case 14:
        updateTextField("${value}000");
        break;
      default:
        if(i == 0 || i == 1 || i == 2) {
          updateTextField(value + (i+1).toString());
        } else if(i == 8 || i == 9 || i == 10){
          updateTextField(value + (i-1).toString());
        }
        else{
          updateTextField(value + (i).toString());
        }
    }
  }
  
  void updateTextField(String value){
    if(value == "" || int.parse(value) == 0) {
      value = "0";
    }

    if (value.length <= 11){
      setState(() {
        valueController.text = StringUtils.currencyFormat((int.parse(value)).toString());
      });
    }
  }

  void _paymentFail(){
    Fluttertoast.showToast(
        msg: "Saldo insuficiente!",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0
    );
  }
}
