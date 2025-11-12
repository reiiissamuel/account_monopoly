// screens/offer_market_screen.dart

import 'package:account_monopoly/domain/enums/event_type.dart';
import 'package:account_monopoly/domain/enums/offer_type.dart';
import 'package:account_monopoly/domain/model/trade_offer.dart';
import 'package:account_monopoly/screens/property_details_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'package:account_monopoly/provider/game_provider.dart';
import 'package:account_monopoly/utils/string_utils.dart';

// -----------------------------------------------------------------
// NOTA: A lógica do diálogo de compra foi integrada ao _offerTile
// para facilitar a referência, mas você pode mantê-la separada.
// -----------------------------------------------------------------

class MarketScreen extends StatelessWidget {
  const MarketScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<GameProvider>(
      builder: (context, gameProvider, child) {
        if (gameProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        // Assume que este método retorna a lista consolidada das 3 fontes (IPO, Banco, P2P)
        final List<TradeOffer> availableStocks = gameProvider.getAllMarketListings();

        return Scaffold(
          appBar: AppBar(
            backgroundColor: Theme.of(context).primaryColor,
            title: const Text("Mercado de Ações", style: TextStyle(letterSpacing: 2, color: Colors.white, fontWeight: FontWeight.bold)),
            centerTitle: true,
          ),
          backgroundColor: Colors.black,
          body: availableStocks.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.show_chart, size: 60.0, color: Colors.indigo),
                      const SizedBox(height: 10),
                      Text("Nenhuma ação disponível para negociação no momento.", 
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.white70)),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(10.0),
                  itemCount: availableStocks.length,
                  itemBuilder: (context, index) {
                    return _offerTile(context, availableStocks[index], gameProvider);
                  }),
        );
      },
    );
  }

  // -----------------------------------------------------------------
  // WIDGET DO CARD DE AÇÃO
  // -----------------------------------------------------------------
  Widget _offerTile(BuildContext context, TradeOffer offer, GameProvider gameProvider) {
    final String currentPrice = StringUtils.currencyFormat(offer.currentMarketPrice);
    final String available = offer.sharesAmount.toString();
    
    // Cor do texto de origem (para destaque)
    final Color sourceColor = switch (offer.source) {
      OfferSource.fundIPO => Colors.lightBlueAccent,
      OfferSource.bankForeclosed => Colors.yellow,
      OfferSource.playerMarket => Colors.pinkAccent,
    };

    return Container(
      margin: const EdgeInsets.only(bottom: 12.0),
      padding: const EdgeInsets.all(15.0),
      decoration: BoxDecoration(
        color: offer.colorSignature, // Cor base da propriedade
        borderRadius: const BorderRadius.all(Radius.circular(15.0)),
        boxShadow: const [BoxShadow(color: Colors.black45, blurRadius: 5)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          // Título do FII
          Row(
              spacing: 5,
              children: [
                Icon(gameProvider.ledger.properties[offer.propertyId]!.iconSignature.icon),
                Text('Nome: ${offer.propertyId}',
                  style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ) ,
                )
              ],
            ),
          
          // Origem da Oferta
          Text(
            "Origem: ${offer.source.description}",
            style: TextStyle(color: sourceColor, fontSize: 14.0, fontWeight: FontWeight.w600),
          ),
          const Divider(color: Colors.white70),

          // Preço e Disponibilidade
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildInfoColumn(context, "Preço por Ação", currentPrice, Colors.black),
              _buildInfoColumn(
                context,
                 "Você possui:", gameProvider.currentPlayer.portfolio.containsKey(offer.propertyId) ?
                 gameProvider.currentPlayer.portfolio[offer.propertyId]!.sharesOwned.toString() : "0", Colors.black),
              _buildInfoColumn(context, "Disponível", available, Colors.white),
            ],
          ),

          // NOVO: Linha de Ação (Botão Comprar)
          const SizedBox(height: 15),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            spacing: 5,
            children: [
              // BOTÃO DE DETALHES (Novo)
              OutlinedButton.icon(
                icon: const Icon(Icons.info_outline, color: Colors.white),
                label: const Text("Detalhes", style: TextStyle(color: Colors.white)),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.white70),
                ),
                onPressed: () {
                  // AÇÃO: Navegar para a tela de detalhes da propriedade
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => PropertyDetailsScreen(propertyId: offer.propertyId),
                    ),
                  );
                },
              ),
              ElevatedButton.icon(
                icon: const Icon(Icons.shopping_cart),
                label: Text(offer.sharesAmount > 0 ? "COMPRAR AÇÃO" : "ESGOTADO"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: offer.sharesAmount > 0 ? Colors.green : Colors.grey,
                  foregroundColor: Colors.white,
                ),
                onPressed: offer.sharesAmount > 0 && offer.sellerPlayerId != gameProvider.currentPlayer.id
                    ? () => _showBuySharesDialog(context, offer, gameProvider)
                    : null, // Desabilita se não houver ações
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  // -----------------------------------------------------------------
  // WIDGETS AUXILIARES E DIÁLOGO DE COMPRA
  // -----------------------------------------------------------------
  Widget _buildInfoColumn(BuildContext context, String label, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.black, fontSize: 12)),
        Text(value, style: Theme.of(context).textTheme.titleLarge!.copyWith(color: color)),
      ],
    );
  }

  void _showBuySharesDialog(BuildContext context, TradeOffer offer, GameProvider gameProvider) {
    final TextEditingController quantityController = TextEditingController();
    
    final String transactionType = offer.source == OfferSource.playerMarket ? "do Jogador" : "do Banco/Fundo";
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Comprar Ações de ${offer.propertyName}"),
          content: offer.source == OfferSource.playerMarket          
          ? Text(
            "Confirmar compra do lote de ${offer.propertyName} posto a venda por ${gameProvider.currentPlayer.username};",
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15
            ),
          )
          : Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Preço por ação $transactionType: ${StringUtils.currencyFormat(offer.currentMarketPrice)}"),
              Text("Disponível: ${offer.sharesAmount} ações"),
              const SizedBox(height: 15),
              TextField(
                controller: quantityController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: "Quantidade de Ações",
                  hintText: "Ex: 10",
                  border: OutlineInputBorder(),
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly
                ]
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: const Text("Cancelar"),
              onPressed: () => Navigator.of(context).pop(),
            ),
            ElevatedButton(
              child: const Text("Comprar"),
              onPressed: () {
                final int? quantity = int.tryParse(quantityController.text);
                if (gameProvider.forbiddenAction) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("O banco não autorizou esta operação devido o fato de você estar no cadastro de devedores")),
                  );
                } 
                
                if (quantity != null && quantity > 0 && quantity <= offer.sharesAmount) {
                  if (gameProvider.currentPlayer.currentCredit < quantity! * offer.askingPrice) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Você não possui saldo suficiente")),
                    );
                  } else if(offer.source != OfferSource.fundIPO){
                    gameProvider.eventComposer(
                      type: EventType.buyFromTrade,
                      tradeOffer: offer,
                      destinationPlayer: offer.source == OfferSource.playerMarket ? gameProvider.otherPlayers[offer.sellerPlayerId] : null
                    );
                  } else {
                    gameProvider.eventComposer(
                      type: EventType.buyFromIPO,
                      propertyId: offer.propertyId,
                      value: quantity
                    );
                  }
                  Navigator.of(context).pop();
                } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Quantidade inválida ou indisponível.")),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }
}