import 'package:account_monopoly/provider/game_provider.dart';
import 'package:account_monopoly/screens/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:account_monopoly/screens/game_balance_screen.dart';
import 'package:account_monopoly/domain/model/player.dart';
import 'package:account_monopoly/utils/string_utils.dart';

class WinnerDialog extends StatelessWidget {
  const WinnerDialog({super.key});

  @override
  Widget build(BuildContext context) {
    GameProvider gameProvider = Provider.of<GameProvider>(context);

    // Coleta todos os jogadores da partida (jogador atual + outros jogadores)
    List<Player> allPlayers = [...gameProvider.otherPlayers.values];

    // Ordena os jogadores por NetWorth de forma decrescente (ranking)
    allPlayers.sort((a, b) {
      double netWorthA = a.netWorth(
        gameProvider.ledger.getSharesHolderSummary(a.portfolio).totalPortfolioValue,
      );
      double netWorthB = b.netWorth(
        gameProvider.ledger.getSharesHolderSummary(b.portfolio).totalPortfolioValue,
      );
      return netWorthB.compareTo(netWorthA);
    });

    return PopScope(
      canPop: false,
      child: Card(
        color: Colors.black.withValues(alpha: 0.8),
        child: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          padding: const EdgeInsets.all(20.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20.0),
            color: Colors.black.withValues(alpha: 0.8),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                "Um Império foi construído!",
                style: TextStyle(
                  fontSize: 20.0,
                  fontWeight: FontWeight.w300,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              
              // Cabeçalho de Vitória (Mantido com a imagem original)
              Container(
                padding: const EdgeInsets.all(20.0),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  borderRadius: BorderRadius.circular(20.0),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: 60.0,
                      width: 60.0,
                      child: Image.asset(
                        "icons/youwin.png",
                        fit: BoxFit.contain,
                      ),
                    ),
                    const SizedBox(height: 8.0),
                    Text(
                      "${allPlayers[0].username} Você Venceu!",
                      style: const TextStyle(color: Colors.white, fontSize: 17.0, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),

              // NOVO: Seção do Ranking por NetWorth dos Jogadores
              const Text(
                "Ranking Final (Patrimônio Líquido)",
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14.0,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              
              Container(
                height: 140, // Altura controlada para caber harmoniosamente no diálogo
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(15.0),
                  border: Border.all(color: Colors.white12),
                ),
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                  itemCount: allPlayers.length,
                  itemBuilder: (context, index) {
                    Player player = allPlayers[index];
                    double netWorth = player.netWorth(
                      gameProvider.ledger.getSharesHolderSummary(player.portfolio).totalPortfolioValue,
                    );
                    bool isMe = player.id == gameProvider.currentPlayer.id;

                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Text(
                                "${index + 1}º",
                                style: const TextStyle(
                                  color: Colors.yellow,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                player.username + (isMe ? " (Você)" : ""),
                                style: TextStyle(
                                  color: isMe ? Colors.yellowAccent : Colors.white,
                                  fontWeight: isMe ? FontWeight.bold : FontWeight.normal,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                          Text(
                            StringUtils.currencyFormat(netWorth),
                            style: const TextStyle(
                              color: Colors.greenAccent,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 4.0),

              // Botão de Análise do Jogo
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                  backgroundColor: Theme.of(context).primaryColor,
                  splashFactory: InkRipple.splashFactory,
                ),
                child: const Text("Análise do jogo", style: TextStyle(fontSize: 16.0, color: Colors.white)),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const GameBalanceScreen()),
                  );
                },
              ),

              // Botão de Sair
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                  backgroundColor: Theme.of(context).primaryColor,
                  splashFactory: InkRipple.splashFactory,
                ),
                child: const Text("Sair", style: TextStyle(fontSize: 16.0, color: Colors.white)),
                onPressed: () async {
                  await Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (context) => const HomeScreen()),
                  ).then((_) async {
                    await gameProvider.leaveGame();
                  });
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}