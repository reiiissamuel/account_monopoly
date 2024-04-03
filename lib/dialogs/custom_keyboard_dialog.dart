import 'package:account_monopoly/provider/game_provider.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import '../enums/log_msg_type.dart';
import '../utils/string_utils.dart';
import 'confirm_action_dialog.dart';

class CustomKeyboard extends StatefulWidget {

  final String title;
  final LogMsgType eventType;
  final String playerToPayId;

  const CustomKeyboard({super.key, required this.title, required this.eventType, required this.playerToPayId});

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
                        fontSize: 20.0, fontWeight: FontWeight.bold, color: Colors.white)),
                TextField(
                    cursorColor: Colors.white,
                    controller: valueController,
                    readOnly: true,
                    maxLines: 1,
                    style: const TextStyle(
                      fontSize: 22.0,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 2,
                      color: Colors.white,
                    ),
                    decoration: const InputDecoration(
                      contentPadding: EdgeInsets.symmetric(vertical: 8.0),
                      fillColor: Colors.black12,
                      filled: true,
                      focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.black38, width: 1.0),
                          borderRadius: BorderRadius.all(Radius.circular(25.0))),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black38, width: 1.0),
                        borderRadius: BorderRadius.all(Radius.circular(25.0))),
                      prefixIcon: Icon(Icons.attach_money, color: Colors.white),
                    )),
                const Spacer(flex:1),
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
                      return numberButton(context, index);
                    }),
                  ),
                )
            ]),
        ),
      ),
    );
  }

  Widget numberButton(BuildContext context, int i) {
    return Center(
      child: ElevatedButton(
          style: ButtonStyle(
            elevation: MaterialStateProperty.all(4.0),
            overlayColor: MaterialStateProperty.all(Colors.white54),
            backgroundColor: MaterialStateProperty.all(Colors.black38),
          ),
          onPressed: i != 15 ? (){buttonFunction(i);} : valueController.text == "0" ? null : (){_finishOperation(context);},
          child: buttonChildBuild(i)
      ),
    );
  }

  void _finishOperation(BuildContext context){
    GameProvider gameProvider = Provider.of<GameProvider>(context, listen: false);
    int value = int.parse(valueController.text.replaceAll(".", ""));

    if(widget.eventType == LogMsgType.BUY || widget.eventType == LogMsgType.BUILD_HOUSE || widget.eventType == LogMsgType.BUILD_HOTEL) {
      if(gameProvider.hasEnoughBalance(value)) {
        showDialog(context: context, builder: (BuildContext context){
        return ConfirmActionDialog(title: "Alerta de Compra!", textContent: "Você Confirma o pagamento de $value?", onConfirm: (){
          gameProvider.eventComposer(type: widget.eventType, value: value);
          Navigator.of(context).pop();
          Navigator.of(context).pop();
        });
      });
      } else {
        _paymentFail();
      }
      }
    else if(widget.eventType == LogMsgType.RECEIVE_FROM_BANK) {
      showDialog(context: context, builder: (BuildContext context){
        return ConfirmActionDialog(title: "Alerta de Rebebimento!", textContent: "Você Confirma o recebimento de $value?", onConfirm: (){
          gameProvider.eventComposer(type: widget.eventType, value: value);
          Navigator.of(context).pop();
          Navigator.of(context).pop();
        });
      });
    }
    else if(widget.eventType == LogMsgType.PAY_BANK){
          if(gameProvider.hasEnoughBalance(value)) {
            showDialog(context: context, builder: (BuildContext context){
            return ConfirmActionDialog(title: "Alerta de Pagamento!", textContent: "Você Confirma o pagamento de $value?", onConfirm: (){
              gameProvider.eventComposer(
                  type: widget.eventType,
                  value: value
              );
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            });
          });
          } else {
            _paymentFail();
          }
    }
    else if(widget.eventType == LogMsgType.TRANSFER){
      if(gameProvider.hasEnoughBalance(value)) {
        showDialog(context: context, builder: (BuildContext context){
          return ConfirmActionDialog(title: "Alerta de Pagamento!", textContent: "Você Confirma a transferência de $value?", onConfirm: (){
            gameProvider.eventComposer(
                type: widget.eventType,
                value: value,
                destinationPlayer: gameProvider.gameModelDTO!.players.firstWhere((p) => p.id == widget.playerToPayId)
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
        return const Text("C", style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold, color: Colors.amber));
      case 11:
        return const Icon(Icons.cancel, color: Colors.red);
      case 12:
        return Text("00", style: TextStyle(fontSize: 11.0, fontWeight: FontWeight.bold, color: Theme.of(context).primaryColor));
      case 13:
        return Text("0", style: TextStyle(fontSize: 19.0, fontWeight: FontWeight.bold, color: Theme.of(context).primaryColor));
      case 14:
        return Text("000", style: TextStyle(fontSize: 9.0, fontWeight: FontWeight.bold, color: Theme.of(context).primaryColor));
      case 15:
        cont = 1;
        return const Icon(Icons.done, color: Colors.green);
      default:
        return Text("${cont++}", style: TextStyle(fontSize: 18.0, color: Theme.of(context).primaryColor));
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
