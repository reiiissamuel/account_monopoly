import 'package:account_monopoly/enums/log_msg_type.dart';
import 'package:account_monopoly/provider/game_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../dialogs/confirm_action_dialog.dart';
import '../dialogs/tip_alert_dialog.dart';
import '../dto/chance.dart';
import '../utils/tips_resourse.dart';

class ChancesScreen extends StatelessWidget {
  const ChancesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    if (Provider.of<GameProvider>(context).isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    return Scaffold(
        appBar: AppBar(
          title: const Text("Benefícios", style: TextStyle(letterSpacing: 2)),
          centerTitle: true,
          actions: [
            IconButton(
              icon: const Icon(Icons.help),
              color: Colors.white,
              onPressed: () {
                showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return TipDialog(
                          title: "Tela de Benefícios",
                          tip: TipsResourse.BENEFITS_SCREEN);
                    });
              },
            )
          ],
        ),
        backgroundColor: Colors.black,
        body: Consumer<GameProvider>(
          //
          builder: (context, gameProvider, child) {
            return gameProvider.gameModelDTO!.chances.isEmpty
                ? const Center(
                child: Icon(Icons.hourglass_empty,
                    color: Colors.white, size: 25))
                : ListView.builder(
                padding: const EdgeInsets.all(10.0),
                itemCount: gameProvider.gameModelDTO!.chances.length,
                itemBuilder: (context, index) {
                  //if(model.hipotecas[index].deadline > 0)
                  return _benefitsTile(
                      context, gameProvider.gameModelDTO!.chances[index]);
                });
          },
        ));
  }

  Widget _benefitsTile(BuildContext context, Chance chance) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8.0),
      height: 215.0,
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
              'Benefício: ${chance.name}',
              style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            Align(
              alignment: Alignment.center,
              child: SizedBox(
                height: 50.0,
                width: 50.0,
                child: Image.asset(chance.incoming!, fit: BoxFit.contain),
              ),
            ),
            const SizedBox(height: 10),
            Align(
                alignment: Alignment.bottomCenter,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20.0),
                                side: const BorderSide(color: Colors.white)),
                            backgroundColor: Colors.white),
                        child: Text("Usar",
                            style: TextStyle(
                                fontSize: 20.0,
                                fontWeight: FontWeight.w500,
                                letterSpacing: 2,
                                color: Theme.of(context).primaryColor)),
                        onPressed: () {
                          showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return ConfirmActionDialog(
                                    title: "Confirmar uso desta carta?",
                                    textContent: "Deseja utilizar este evento?",
                                    onConfirm: () {
                                      Provider.of<GameProvider>(context)
                                          .gameModelDTO!
                                          .chances
                                          .removeWhere(
                                              (b) => b.id == chance.id);
                                      Provider.of<GameProvider>(context)
                                          .eventComposer(
                                              type: LogMsgType.CHANCE_USED);
                                      Navigator.pop(context);
                                    });
                              });
                        }),
                    IconButton(
                      icon: const Icon(Icons.help),
                      iconSize: 40,
                      color: Colors.white,
                      onPressed: () {
                        showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return TipDialog(
                                  title: chance.name!,
                                  tip: chance.description!);
                            });
                      },
                    )
                  ],
                ))
          ],
        ),
      ),
    );
  }
}
