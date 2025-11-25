import 'package:account_monopoly/domain/enums/event_type.dart';
import 'package:account_monopoly/domain/enums/offer_type.dart';
import 'package:account_monopoly/domain/model/trade_offer.dart';
import 'package:account_monopoly/exception/domain_exception.dart';
import 'package:account_monopoly/screens/property_details_screen.dart';
import 'package:account_monopoly/utils/tips_resourse.dart';
import 'package:account_monopoly/widgets/tip_icon_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'package:account_monopoly/provider/game_provider.dart';
import 'package:account_monopoly/utils/string_utils.dart';

class MarketScreen extends StatelessWidget {
  const MarketScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<GameProvider>(
      builder: (context, gameProvider, child) {
        if (gameProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        final List<TradeOffer> availableStocks = gameProvider.getAllMarketListings();

        return Scaffold(
          appBar: AppBar(
            backgroundColor: Theme.of(context).primaryColor,
            title: const Text("Mercado de Ações", style: TextStyle(letterSpacing: 2, color: Colors.white, fontWeight: FontWeight.bold)),
            centerTitle: true,
            actions: const [
              TipIconButton(title: "Compra de ativos", tip: TipsResourse.MARKET_SCREEN)
            ],
          ),
          backgroundColor: Colors.black,
          body: Builder(
            builder: (scaffoldContext) {
              return availableStocks.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.show_chart, size: 60.0, color: Colors.indigo),
                          const SizedBox(height: 10),
                          Text("Nenhuma ação disponível para negociação no momento.",
                              textAlign: TextAlign.center,
                              style: Theme.of(scaffoldContext).textTheme.titleLarge?.copyWith(color: Colors.white70)),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(10.0),
                      itemCount: availableStocks.length,
                      itemBuilder: (context, index) {
                        return _offerTile(scaffoldContext, availableStocks[index], gameProvider);
                      });
            },
          ),
        );
      },
    );
  }

  // -----------------------------------------------------------------
  // WIDGET DO CARD DE AÇÃO
  // -----------------------------------------------------------------
  Widget _offerTile(BuildContext context, TradeOffer offer, GameProvider gameProvider) {
    final String currentMarketPrice = StringUtils.currencyFormat(offer.currentMarketPrice);
    final String askingPrice = StringUtils.currencyFormat(offer.askingPrice);
    final String available = offer.sharesAmount.toString();
    final property = gameProvider.ledger.properties[offer.propertyId];
    
    // Cor do texto de origem (para destaque)
    final Color sourceColor = switch (offer.source) {
      OfferSource.fundIPO => Colors.black,
      OfferSource.bankForeclosed => Colors.blueGrey,
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
                Icon(property!.iconSignature.icon),
                Text('${property.name} (${offer.propertyId})',
                  style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 21
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
              _buildInfoColumn(context, "Preço de mercado", currentMarketPrice, Colors.black),
              _buildInfoColumn(
                context,
                  "Você possui:", gameProvider.currentPlayer.portfolio.containsKey(offer.propertyId) ?
                  gameProvider.currentPlayer.portfolio[offer.propertyId]!.sharesOwned.toString() : "0", Colors.black)
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildInfoColumn(context, "Preço pedido", askingPrice, Colors.black),
              _buildInfoColumn(context, "Disponível", available, Colors.white),
            ],
          ),
          // Linha de Ação (Botão Comprar)
          const Divider(color: Colors.white70),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            spacing: 5, 
            children: [
              // BOTÃO DE DETALHES
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
                label: Text(offer.sharesAmount > 0 ? "COMPRAR" : "ESGOTADO"),
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
      builder: (BuildContext dialogContext) { 
        return AlertDialog(
          title: Text("Comprar Ações de ${offer.propertyName}",
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
            textAlign: TextAlign.center,
          ),
          backgroundColor: Theme.of(context).primaryColor,
          content: offer.source != OfferSource.fundIPO
          ? Text(
            "Confirmar compra do lote de ${offer.propertyName} posto à venda por ${offer.sellerPlayerId} no valor de total de ${StringUtils.currencyFormat(offer.totalAskingPrice)};",
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.bold
            ),
          )
          : Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Preço por ação $transactionType: ${StringUtils.currencyFormat(offer.currentMarketPrice)}"),
              Text("Disponível: ${offer.sharesAmount} ações"),
              const SizedBox(height: 15),
              if(offer.source == OfferSource.fundIPO) ...[
                TextField(
                    controller: quantityController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                        labelText: "Quantidade de Ações",
                        hintText: "Ex: 10",
                        labelStyle: TextStyle(color: Colors.white54),
                        hoverColor: Colors.white,
                        focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(20.0)),
                            borderSide: BorderSide(
                                color: Colors.white, width: 5.0
                            )
                        ),
                        disabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(20.0)),
                            borderSide: BorderSide(
                                color: Colors.blueGrey, width: 3.0
                            )
                        ),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(20.0)),
                            borderSide: BorderSide(
                                color: Colors.blueGrey, width: 3.0
                            )
                        )
                    ),
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly
                    ]
                )
              ],
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: const Text("Cancelar", style: TextStyle(color: Colors.white)),
              onPressed: () => Navigator.of(dialogContext).pop(),
            ),
            ElevatedButton(
              child: Text(offer.source == OfferSource.fundIPO ? "Comprar" : "Compra Lote",
                  style: TextStyle(color: Theme.of(context).primaryColor)
              ),
              onPressed: () {
                try{
                  if(offer.source != OfferSource.fundIPO){
                    gameProvider.eventComposer(
                      type: EventType.buyFromTrade,
                      tradeOffer: offer,
                      quantity: offer.sharesAmount,
                      destinationPlayer: offer.source == OfferSource.playerMarket ? gameProvider.otherPlayers[offer.sellerPlayerId] : null
                    );
                  } else {
                    final int? quantityInput = int.tryParse(quantityController.text);
                    if(quantityInput == null || quantityInput <= 0) throw MissValueException("Você não preencheu os campos ou a quantidade é inválida.");
                    final quantity = (quantityInput > offer.sharesAmount) ? offer.sharesAmount : quantityInput;
                    gameProvider.eventComposer(
                      type: EventType.buyFromIPO,
                      propertyId: offer.propertyId,
                      quantity: quantity
                    );
                  }
                  // Sucesso: Agendamos a SnackBar no Scaffold da tela principal (context é o correto).
                  ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Compra realizada."), backgroundColor: Colors.green));
                } on DomainException catch(e){
                  ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(e.message), backgroundColor: Colors.red));
                } catch(e) {
                  gameProvider.notifyChanges(false);
                  ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Erro inesperado: ${e.toString()}"), backgroundColor: Colors.red));
                }
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }
}