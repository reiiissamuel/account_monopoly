
import 'package:account_monopoly/provider/game_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../enums/log_msg_type.dart';
import '../screens/game_balance_screen.dart';


class WinnerDialog extends StatelessWidget {
  const WinnerDialog({super.key});

  @override
  Widget build(BuildContext context) {
    GameProvider gameProvider = Provider.of<GameProvider>(context);
    return PopScope(
        canPop: false,
        child: Card(
          color: Colors.black.withOpacity(0.8),
          child: Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              padding: const EdgeInsets.all(20.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20.0),
                color: Colors.black.withOpacity(0.8),
              ),
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text("Você construiu um império!",
                        style: TextStyle(
                            fontSize: 20.0, fontWeight: FontWeight.w300, color: Colors.white)),
                    Container(
                        padding: const EdgeInsets.all(32.0),
                        decoration: BoxDecoration(
                            color: Theme.of(context).primaryColor,
                            borderRadius: BorderRadius.circular(20.0)),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            SizedBox(
                              height: 70.0,
                              width: 70.0,
                              child: Image.asset("icons/youwin.png",
                                  fit: BoxFit.contain),
                            ),
                            const Text("Você Venceu!",
                                style: TextStyle(color: Colors.white, fontSize: 17.0)),
                          ],
                        )
                    ),
                    const SizedBox(height: 8.0),

                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20.0)
                        ),
                        backgroundColor: Theme.of(context).primaryColor,
                        splashFactory: InkRipple.splashFactory,
                      ),
                      child: const Text("Análise do jogo", style: TextStyle(fontSize: 16.0, color: Colors.white)),
                      onPressed:  () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => GameBalanceScreen()));
                      },
                    ),

                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20.0)
                        ),
                        backgroundColor: Theme.of(context).primaryColor,
                        splashFactory: InkRipple.splashFactory,
                      ),
                      child: const Text("Sair", style: TextStyle(fontSize: 16.0, color: Colors.white)),
                      onPressed:() {
                        gameProvider.eventComposer(type: LogMsgType.IWON);
                        //Navigator.pushReplacement(context, MaterialPageRoute(builder:(context)=>HomeScreen()));
                      },
                    )
                  ])
          ),
        ));
  }
}
