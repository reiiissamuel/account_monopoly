import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';

import '../dialogs/custom_keyboard_dialog.dart';
import '../dto/player.dart';
import '../enums/keyboard_operation.dart';
import '../enums/log_msg_type.dart';
import '../model/game_model.dart';
import '../utils/string_utils.dart';


class BeneficiariesScreen extends StatelessWidget {
  const BeneficiariesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant<GameModelController>(
      builder: (context, child, model) {
        if (model.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text("Beneficiários", style: TextStyle(letterSpacing: 2)),
            centerTitle: true,
          ),
          backgroundColor: Colors.black,
          body: model.gameModelDTO!.players.isEmpty ?
          Center(
            child: Icon(Icons.person, size: 60.0, color: Theme.of(context).primaryColor)
          )
          : ListView.builder(
              padding: const EdgeInsets.all(10.0),
              itemCount: model.gameModelDTO!.players.length,
              itemBuilder: (context, index) {
                return _beneficiaryTile(context, model.gameModelDTO!.players[index]);
              }),
        );
      },
    );
  }

  Widget _beneficiaryTile(BuildContext context, Player player) {

    return GestureDetector(
      child: Container(
        margin: const EdgeInsets.only(bottom: 8.0),
        height: 210.0,
        decoration: const BoxDecoration(
          color: Color(0xff0087a8),
          borderRadius: BorderRadius.all(Radius.circular(15.0)),
        ),
        child: Container(
          padding: const EdgeInsets.all(20.0),
          margin: const EdgeInsets.all(10.0),
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.all(Radius.circular(15.0)),
            color: Theme.of(context).primaryColor,
          ),
          child: Stack(
            children: <Widget>[
              Text(
                 player.username,
                style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Align(
                alignment: Alignment.centerLeft,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Text(StringUtils.currencyFormat(player.receivedFrom.toString()),
                      style: const TextStyle(color: Colors.green, fontSize: 25.0),
                    ),
                    const Icon(Icons.arrow_back, color: Colors.green, size: 50),
                  ],
                )
              ),
              Align(
                alignment: Alignment.bottomLeft,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Text(StringUtils.currencyFormat(player.payedTo.toString()),
                      style: const TextStyle(color: Colors.red, fontSize: 25.0),
                    ),
                    const Icon(Icons.arrow_forward, color: Colors.red, size: 50,),
                  ],
                )
              ),

            ],
          ),
        ),
      ),
      onTap: (){
        showDialog(context: context, builder: (BuildContext context){
          return CustomKeyboard(title: "Valor a tranferir", keyO: KeyboardOparation.TRANSFER_OUT, logMsgType: LogMsgType.TRANSFER, playerToPayId: player.id);
        });
      },
    );
  }
}
