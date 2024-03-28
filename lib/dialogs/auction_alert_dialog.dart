import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';

import '../model/game_model.dart';
import 'auction_dialog.dart';


class AuctionAlert extends StatelessWidget {
  const AuctionAlert({super.key});

  @override
  Widget build(BuildContext context) {
    return PopScope(canPop: false,
        child: ScopedModelDescendant<GameModelController>(
          builder: (context, child, model){

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
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Text("Novo Leilão disponível! "
                            , style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white,letterSpacing: 2)),
                        Container(
                          height: 150.0,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20.0),
                            color: Theme.of(context).primaryColor,
                          ),
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              SizedBox(
                                height: 80.0,
                                width: 80.0,
                                child: Image.asset("icons/bit.png",
                                    fit: BoxFit.contain),
                              ),
                              const Text("Leve pelo maior lance único", textAlign: TextAlign.center,
                                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500, color: Colors.white,letterSpacing: 2)),
                            ],
                          )),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20.0)
                                ),
                                backgroundColor: Colors.green,
                                splashFactory: InkRipple.splashFactory,
                              ),
                              child: const Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Text("Seguir", style: TextStyle(fontSize: 17.0, color: Colors.white, letterSpacing: 2.0)),
                              ),
                              onPressed: (){
                                  showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return const AuctionDialog();
                                      });
                                }
                            ),

                          ],
                        )

                      ])
              ),
            );
          },
        ) );
  }
}
