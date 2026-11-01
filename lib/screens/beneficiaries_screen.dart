import 'package:account_monopoly/domain/enums/tutorial_item_type.dart';
import 'package:account_monopoly/provider/game_provider.dart';
import 'package:account_monopoly/utils/tips_resourse.dart';
import 'package:account_monopoly/utils/tutorial_fake_objetcs.dart';
import 'package:account_monopoly/utils/tutorial_manager.dart';
import 'package:account_monopoly/widgets/tip_icon_button.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:account_monopoly/dialogs/custom_keyboard_dialog.dart';
import 'package:account_monopoly/domain/model/player.dart';
import 'package:account_monopoly/domain/enums/event_type.dart';
import 'package:account_monopoly/utils/string_utils.dart';
import 'package:showcaseview/showcaseview.dart';

class BeneficiariesScreen extends StatefulWidget {
  const BeneficiariesScreen({super.key});

  @override
  State<BeneficiariesScreen> createState() => _BeneficiariesScreenState();
}

class _BeneficiariesScreenState extends State<BeneficiariesScreen> {
  final _playersScreenTutorialManager = TutorialManager.playersScreen();
  bool _isTutorialActive = false;
  List<Player> _getOthersPlayersList(GameProvider gameProvider) {
    return gameProvider.gameModelDTO!.othersPlayers.values
    .where((player) => player.isOnline && !player.youBankrupt && player.id != gameProvider.currentPlayer.id)
    .toList();
  }

  @override
  Widget build(BuildContext context) {
    return ShowCaseWidget(
      onFinish: () => setState(() => _isTutorialActive = false),
      builder: (showCaseContext){
        return Consumer<GameProvider>(
          builder: (context, gameProvider, child) {
            if (gameProvider.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            final List<Player> othersPlayers = _getOthersPlayersList(gameProvider);

            if (!gameProvider.isPlayersScreenOnBoarded) {
              _isTutorialActive = true;
              gameProvider.userModelController
                  .setOnBoardedOnScreen(isPlayersScreenOnBoarded: true);
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted) _playersScreenTutorialManager.startTutorial(showCaseContext);
              });
            }

            // a fake sobrevive aos rebuilds até o onFinish, só se a carteira continuar vazia
            if (_isTutorialActive && othersPlayers.isEmpty) {
              othersPlayers.add(TutorialFakeObjects.fakePlayer);
            }

            return Scaffold(
              appBar: AppBar(
                backgroundColor: Theme.of(context).primaryColor,
                foregroundColor: Theme.of(context).colorScheme.onInverseSurface,
                title: Text("Beneficiários", style: TextStyle(letterSpacing: 2, color: Theme.of(context).colorScheme.onInverseSurface, fontWeight: FontWeight.bold)),
                centerTitle: true,
                  actions: [
                    TipIconButton(
                      title: "Lista de Beneficiários",
                      tip: TipsResourse.BENEFICIARIES_SCREEN,
                      onConfirm: () {
                        gameProvider.userModelController
                            .setOnBoardedOnScreen(isPlayersScreenOnBoarded: false);
                        gameProvider.notifyChanges(false);
                      }
                    )
                  ]
              ),
              backgroundColor: Colors.black,
              body: othersPlayers.isEmpty ?
              Center(
                // Ícone central se a lista estiver vazia
                child: Icon(Icons.person, size: 60.0, color: Theme.of(context).primaryColor)
              )
              : ListView.builder(
                  padding: const EdgeInsets.all(10.0),
                  itemCount: othersPlayers.length,
                  itemBuilder: (context, index) {
                    final tile = _beneficiaryTile(context, othersPlayers[index]);
                    return index == 0
                                  ? _playersScreenTutorialManager.buildShowcase(
                                      type: TutorialItemType.playerListView,
                                      child: tile,
                                    )
                                  : tile;
                  }),
            );
          },
        );
      });
    }

  Widget _beneficiaryTile(BuildContext context, Player player) {

    return GestureDetector(
      child: Container(
        margin: const EdgeInsets.only(bottom: 8.0),
        height: 210.0,
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColor.withValues(alpha: .3),
          borderRadius: const BorderRadius.all(Radius.circular(15.0)),
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
              // Nome do Jogador
              Text(
                  player.username,
                  style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              // Valores Recebidos (Green)
              Align(
                alignment: Alignment.centerLeft,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Text(StringUtils.currencyFormat(player.financialReport.totalIncome),
                      style: const TextStyle(color: Colors.green, fontSize: 25.0),
                    ),
                    const Icon(Icons.arrow_back, color: Colors.green, size: 50),
                  ],
                )
              ),
              // Valores Pagos (Red)
              Align(
                alignment: Alignment.bottomLeft,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Text(StringUtils.currencyFormat(player.financialReport.totalExpenses),
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
        // Diálogo para Transferência de Valor
        showDialog(context: context, builder: (BuildContext context){
          return CustomKeyboard(title: "Valor a transferir", eventType: EventType.transfer, playerToPayId: player.id);
        });
      },
    );
  }
}