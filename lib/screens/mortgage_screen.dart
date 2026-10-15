/* import 'package:account_monopoly/provider/game_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:account_monopoly/dialogs/confirm_action_dialog.dart';
import 'package:account_monopoly/dialogs/new_mortgage_dialog.dart';
import 'package:account_monopoly/domain/model/mortgage.dart';
import 'package:account_monopoly/domain/enums/event_type.dart';
import 'package:account_monopoly/utils/string_utils.dart';

class MortgageScreen extends StatefulWidget{
  const MortgageScreen({super.key});


  @override
  MortgageScreenState createState() => MortgageScreenState();
}

class MortgageScreenState extends State<MortgageScreen> {
  late GameProvider gameProvider;

  @override
  Widget build(BuildContext context) {
    return Consumer<GameProvider>(
      builder: (context, gameProvider, child) {
        if (gameProvider.isLoading) return const Center(child: CircularProgressIndicator());
        return Scaffold(
            appBar: AppBar(
              backgroundColor: Theme.of(context).primaryColor,
              title: const Text("Hipotécas", style: TextStyle(letterSpacing: 2, color: Colors.white, fontWeight: FontWeight.bold)),
              centerTitle: true,
              actions: [
                IconButton(
                  icon: const Icon(Icons.add, color: Colors.white,),
                  onPressed: (){
                    showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return const NewMortgageDialog();
                        });
                  },
                )
              ],
            ),
            backgroundColor: Colors.black,
            body: gameProvider.gameModelDTO!.player.mortgages.isEmpty ?
                Center(
                  child: IconButton(icon: const Icon(Icons.add, size: 60.0), color: Theme.of(context).primaryColor, onPressed: (){
                    showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return const NewMortgageDialog();
                        });
                  },),
                )

          : ListView.builder(
                padding: const EdgeInsets.all(10.0),
                itemCount: gameProvider.gameModelDTO!.player.mortgages.length,
                itemBuilder: (context, index) {
                  //if(model.mortgages[index].deadline > 0)
                    return _mortgageTile(context, gameProvider.gameModelDTO!.player.mortgages[index]);
                }),
        );
      },
    );
  }

  Widget _mortgageTile(BuildContext context, Mortgage mortgage){
    gameProvider = Provider.of<GameProvider>(context);
    return Container(
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
              'Posse: ${mortgage.name}',
              style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Valor Recebido: ${StringUtils.currencyFormat(mortgage.value.toString())} R\$\n"
                    " Total a Pagar: ${StringUtils.currencyFormat(mortgage.valueToPay.toString())} R\$\n"
                    "Prazo(Rodadas): ${mortgage.deadline.toString()}",
                style: const TextStyle(color: Colors.white, fontSize: 20.0),
              ),
            ),
            Align(
                alignment: Alignment.bottomRight,
                child: mortgage.deadline > 0 ?
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.0), side: const BorderSide(color: Colors.black)),
                    backgroundColor: Theme.of(context).primaryColor,
                  ),
                  onPressed: gameProvider.hasEnoughBalance(mortgage.valueToPay) ? () {
                    showDialog(context: context, builder: (BuildContext context){
                      return ConfirmActionDialog(
                          title: "Resgate de propriedade",
                          textContent: "Confirma o pagamento de  ${StringUtils.currencyFormat(mortgage.valueToPay.toString())} R\$ ?" ,
                          onConfirm: (){

                            gameProvider.eventComposer(type: EventType.PAY_BANK, value: mortgage.valueToPay);
                            gameProvider.gameModelDTO!.player.mortgages.removeWhere((h) => h.id == mortgage.id);
                            Navigator.of(context).pop();
                          });
                    });
                  } : null,
                  child: const Text("Resgatar", style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.w500, letterSpacing: 2, color: Colors.green))
                ) : const Text("Confiscado",
                    style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.w500, color: Colors.red, letterSpacing: 2))
            )
          ],
        ),
      ),
    );
  }


}

 */