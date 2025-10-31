import 'package:account_monopoly/provider/game_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../dialogs/custom_keyboard_dialog.dart';
import '../dto/player.dart';
import '../enums/log_msg_type.dart';
import '../utils/string_utils.dart';


class BeneficiariesScreen extends StatelessWidget {
  const BeneficiariesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<GameProvider>(
      builder: (context, gameProvider, child) {
        if (gameProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        return Scaffold(
          appBar: AppBar(
            backgroundColor: Theme.of(context).primaryColor,
            title: const Text("Beneficiários", style: TextStyle(letterSpacing: 2, color: Colors.white, fontWeight: FontWeight.bold)),
            centerTitle: true,
          ),
          backgroundColor: Colors.black,
          body: gameProvider.gameModelDTO!.othersPlayers.isEmpty ?
          Center(
            child: Icon(Icons.person, size: 60.0, color: Theme.of(context).primaryColor)
          )
          : ListView.builder(
              padding: const EdgeInsets.all(10.0),
              itemCount: gameProvider.gameModelDTO!.othersPlayers.length,
              itemBuilder: (context, index) {
                return _beneficiaryTile(context, gameProvider.gameModelDTO!.othersPlayers.toList(growable: false)[index]);
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
          return CustomKeyboard(title: "Valor a tranferir", eventType: LogMsgType.TRANSFER, playerToPayId: player.id);
        });
      },
    );
  }
}
