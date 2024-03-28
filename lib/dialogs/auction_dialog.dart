import 'package:account_monopoly/enums/log_msg_type.dart';
import 'package:account_monopoly/model/game_model.dart';
import 'package:account_monopoly/utils/string_utils.dart';
import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';

import '../dto/auction.dart';

class AuctionDialog extends StatefulWidget {
  const AuctionDialog({super.key});


  @override
  AuctionDialogState createState() => AuctionDialogState();

}

class AuctionDialogState extends State<AuctionDialog> {

  @override
  Widget build(BuildContext context) {
    return PopScope(
        canPop: false,
            child: ScopedModelDescendant<GameModelController>(
              builder: (context, child, model){
                if(model.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                Auction currentAuction = model.gameModelDTO!.auctions.last;

                return Card(
                  color: Colors.black.withOpacity(0.8),
                  child: Container(
                      width: MediaQuery.of(context).size.width -50,
                      height: MediaQuery.of(context).size.height -80,
                      padding: const EdgeInsets.all(20.0),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20.0),
                        color: Colors.black.withOpacity(0.8),
                      ),
                      child: ListView(
                          children: [
                            Text("Leilão iniciado por ${currentAuction.auctionCaller}", style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w500, color: Colors.white,letterSpacing: 2)),
                            const SizedBox(height: 20.0),
                            Card(
                                color: Theme.of(context).primaryColor,
                                child: Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Text(
                                        "Propriedade: ${currentAuction.propertyName}\n"
                                            "Valor Inicial: ${StringUtils.currencyFormat(currentAuction.startValue.toString())}\n"
                                            "Último Lance: ${currentAuction.buyer}\n"
                                            "Valor Atual: ${StringUtils.currencyFormat(currentAuction.currentValue.toString())}\n"
                                            "Participantes: ${currentAuction.whichPlayersIdStillIn.length}",
                                        style: const TextStyle(fontSize: 17.0, color: Colors.white, letterSpacing: 2.0, fontWeight: FontWeight.bold))
                                )
                            ),
                            const SizedBox(height: 16.0),
                            Container(
                              height: 200.0,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20.0),
                                color: Theme.of(context).primaryColor,
                              ),
                              padding: const EdgeInsets.all(16.0),
                              child:ListView.builder(
                                  reverse: true,
                                  itemCount: model.gameModelDTO!.logs.length,
                                  itemBuilder: (context, index) {
                                    List r =  model.gameModelDTO!.logs.reversed.toList();
                                    return Container(
                                        decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(20.0),
                                            color: r[index].contains("Você") ? Colors.green : Colors.white),
                                        padding: const EdgeInsets.all(5.0),
                                        margin: const EdgeInsets.only(top: 5.0),
                                        child: Text(
                                          r[index],
                                          style: TextStyle(
                                            fontSize: 15.0,
                                            color: r[index].contains("Você") ? Colors.white : Theme.of(context).primaryColor),
                                          ),
                                        );
                                  }
                              ),),
                            const SizedBox(height: 16.0),

                            (currentAuction.areTherePlayersIn() && currentAuction.buyer == model.player.username)
                                ?
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20.0)
                                ),
                              ),
                              onPressed: (currentAuction.areTherePlayersIn() && currentAuction.buyer == model.player.username) ?  () {
                                model.eventComposer(type: LogMsgType.AUCTION_END);
                                Navigator.of(context).pop();
                                Navigator.of(context).pop();
                              } : null,
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: (currentAuction.areTherePlayersIn() && currentAuction.buyer == model.player.username)
                                    ? const Text("Concluir Compra", style: TextStyle(color: Colors.white))
                                    : const Text("Sair", style: TextStyle(color: Colors.white)),
                              ),
                            )
                            :
                            Wrap(
                              alignment: WrapAlignment.spaceEvenly,
                              children: [
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Theme.of(context).primaryColor,
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(20.0)
                                    ),
                                  ),
                                  onPressed: (
                                      model.hasEnoughBalance(currentAuction.currentValue)
                                          && currentAuction.buyer!=model.player.username) ? (){
                                    if(currentAuction.buyer.isEmpty){
                                      model.eventComposer(type: LogMsgType.AUCTION_PAY);
                                    } else {
                                      model.eventComposer(type: LogMsgType.AUCTION_RAISE, value: 50000);
                                    }
                                  } : null,
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: currentAuction.buyer.isEmpty
                                        ? const Text("Pagar", style: TextStyle(fontSize: 17.0, letterSpacing: 2, color: Colors.white))
                                        : const Text("Cobrir (+50K)", style: TextStyle(fontSize: 17.0, letterSpacing: 2, color: Colors.white)),
                                  ),
                                ),
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Theme.of(context).primaryColor,
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(20.0)
                                    ),
                                  ),
                                  onPressed:  _bidAction(context, currentAuction, 100000),
                                  child: const Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: Text("Cobrir (+100K)", style: TextStyle(fontSize: 17.0, letterSpacing: 2, color: Colors.white)),
                                  )
                                ),
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Theme.of(context).primaryColor,
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(20.0)
                                    ),
                                  ),
                                  onPressed: _bidAction(context, currentAuction, 250000),
                                  child: const Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: Text("Cobrir (+250K)", style: TextStyle(fontSize: 17.0, letterSpacing: 2, color: Colors.white)),
                                  ),
                                ),
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Theme.of(context).primaryColor,
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(20.0)
                                    ),
                                  ),
                                  onPressed:  _bidAction(context, currentAuction, 500000),
                                  child: const Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: Text("Cobrir (+500K)", style: TextStyle(fontSize: 17.0, letterSpacing: 2, color: Colors.white)),
                                  ),
                                ),
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red,
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(20.0)
                                    ),
                                  ),
                                  onPressed: currentAuction.buyer!=model.player.username ? ()  {
                                      model.eventComposer(type: LogMsgType.LOST_CONNECTION);
                                      Navigator.of(context).pop();
                                      Navigator.of(context).pop();
                                    }
                                   : null,
                                  child: const Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: Text("Abandonar Leilão", style: TextStyle(fontSize: 17.0, letterSpacing: 2, color: Colors.white)),
                                  ),
                                )
                              ],
                            )
                          ])
                  ),
                );
      },
    ) );

  }

  _bidAction(BuildContext context, Auction currentAuction, value){
    return (currentAuction.buyer.isNotEmpty
        && GameModelController.of(context).hasEnoughBalance(currentAuction.currentValue)
        && currentAuction.buyer!=GameModelController.of(context).player.username
    ) ? (){
      GameModelController.of(context).eventComposer(type: LogMsgType.AUCTION_RAISE, value: value);
    } : null;
  }
}
