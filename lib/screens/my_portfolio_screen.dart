// screens/my_portfolio_screen.dart

import 'package:account_monopoly/domain/enums/event_type.dart';
import 'package:account_monopoly/domain/enums/offer_type.dart';
import 'package:account_monopoly/domain/model/property.dart';
import 'package:account_monopoly/domain/model/share_holder.dart';
import 'package:account_monopoly/domain/model/shares_holder_summary.dart';
import 'package:account_monopoly/domain/model/trade_offer.dart';
import 'package:account_monopoly/exception/domain_exception.dart';
import 'package:account_monopoly/screens/property_details_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:provider/provider.dart';

import 'package:account_monopoly/provider/game_provider.dart';
import 'package:account_monopoly/utils/string_utils.dart';


class MyPortfolioScreen extends StatelessWidget {
  const MyPortfolioScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<GameProvider>(
      builder: (context, gameProvider, child) {
        final currentPlayer = gameProvider.currentPlayer;
        List<MapEntry<String, ShareHolder>> currentPortfolio = currentPlayer.portfolio.entries.where((entry) => entry.value.sharesOwned > 0).toList();

        return Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Theme.of(context).primaryColor,
            title: const Text("Minha Carteira", style: TextStyle(letterSpacing: 2, color: Colors.white, fontWeight: FontWeight.bold)),
            centerTitle: true,
          ),
          body: Column(
            children: [
              // RESUMO SUPERIOR
              _buildSummaryHeader(context, gameProvider.ledger.getSharesHolderSummary(currentPlayer.portfolio)),
              
              const SizedBox(height: 10),
              
              // LISTA DE ATIVOS
              Expanded(
                child: currentPortfolio.isEmpty
                    ? _buildEmptyPortfolio(context)
                    : ListView.builder(
                        padding: const EdgeInsets.all(10.0),
                        itemCount: currentPortfolio.length,
                        itemBuilder: (context, index) {
                          return _portfolioTile(
                              context,
                              currentPortfolio[index].value,
                              gameProvider);
                        }),
              ),
            ],
          ),
        );
      },
    );
  }

  // --- WIDGETS DE CONSTRUÇÃO ---

  // 1. CABEÇALHO DE RESUMO
  Widget _buildSummaryHeader(BuildContext context, SharesHolderSummary summary) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      color: const Color(0xFF1E1E1E), // Fundo escuro para o cabeçalho
      child: Column(
        children: [
          _buildSummaryRow("🏦 Valor investido", StringUtils.currencyFormat(summary.totalInvested), context, Colors.white),
          _buildSummaryRow("📈 Valor atual dos ativos", StringUtils.currencyFormat(summary.totalPortfolioValue), context, Colors.lightBlueAccent),
          const Divider(color: Colors.white12, height: 20),
          _buildSummaryRow("➕ Ganho de capital", StringUtils.currencyFormat(summary.totalGainCapital), context, summary.totalGainCapital >= 0? Colors.green : Colors.red),
          _buildSummaryRow("💰 Proventos", StringUtils.currencyFormat(summary.totalDividends), context, Colors.green),
          const Divider(color: Colors.white12, height: 20),
          _buildSummaryRow("✨ Lucro Líquido", StringUtils.currencyFormat(summary.totalNetProfit), context, summary.totalNetProfit >= 0? Colors.green : Colors.red),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, BuildContext context, Color valueColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.white70, fontSize: 13)),
          Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: valueColor)),
        ],
      ),
    );
  }


  // 2. TILE DE CADA ATIVO
  Widget _portfolioTile(BuildContext context, ShareHolder item, GameProvider gameProvider) {
    final property = gameProvider.ledger.properties[item.propertyId];
    final Color pnlColor = item.getProfitPercentage(property!.sharePrice) >= 0 ? Colors.green : Colors.red;
    return Container(
      margin: const EdgeInsets.only(bottom: 12.0),
      padding: const EdgeInsets.all(15.0),
      decoration: BoxDecoration(
        color: property.colorSignature.withValues(alpha: .8),
        borderRadius: BorderRadius.circular(10.0),
        border: Border.all(color: property.colorSignature.withValues(alpha: .5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // NOME & QTD
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(property.name, style: Theme.of(context).textTheme.headlineSmall!.copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
              Text("${item.sharesOwned} Ações", style: const TextStyle(color: Colors.white70, fontSize: 18)),
            ],
          ),
          const Divider(color: Colors.white70),

          // P&L
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildInfoColumn("Lucro: ", StringUtils.currencyFormat(item.getNetProfit(property.sharePrice)), pnlColor),
              _buildInfoColumn("Proventos recebidos: ", StringUtils.currencyFormat(item.dividendsReceived), pnlColor),
              //_buildInfoColumn("Lucro por ação: ", StringUtils.currencyFormat(item.getNetProfitPerShare(property.sharePrice)), pnlColor),
              _buildInfoColumn("Variação %", "${item.getProfitPercentage(property.sharePrice).toStringAsFixed(2)}%", pnlColor),
            ],
          ),
          const SizedBox(height: 10),

          // CUSTO E VALOR ATUAL
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildInfoColumn("Custo Médio", StringUtils.currencyFormat(item.averageCostPerShare), Colors.white70),
              _buildInfoColumn("Valor investido", StringUtils.currencyFormat(item.averageCostPerShare * item.sharesOwned), Colors.white70),
              _buildInfoColumn("Valor Atual", StringUtils.currencyFormat(property.sharePrice), Colors.yellow),
            ],
          ),
          const SizedBox(height: 10),

          // Extra
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildInfoColumn(
                  "Última distribuição",
                  "Rodada ${gameProvider.ledger.properties[item.propertyId]!.lastDividendRound}", Colors.white70),
            ],
          ),
          
          const SizedBox(height: 15),
          
          // BOTÕES DE AÇÃO
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              // BOTÃO DE DETALHES
              OutlinedButton.icon(
                icon: const Icon(Icons.info_outline, color: Colors.white),
                label: const Text("Detalhes", style: TextStyle(color: Colors.white)),
                style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.white70)),
                onPressed: () {
                  MaterialPageRoute(
                    builder: (context) => PropertyDetailsScreen(propertyId: item.propertyId),
                  );
                },
              ),
              const SizedBox(width: 8),
              // BOTÃO DE VENDER (CRIAR OFERTA P2P)
              ElevatedButton.icon(
                icon: const Icon(Icons.sell),
                label: const Text("VENDER"),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.pink, foregroundColor: Colors.white),
                onPressed: () {
                  // Ação: Abrir diálogo para criar oferta de venda (P2P)
                  _showSellSharesDialog(context, item, gameProvider, property);
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Helper para colunas de informação no tile
  Widget _buildInfoColumn(String label, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.white60, fontSize: 12)),
        Text(value, style: TextStyle(color: color, fontSize: 18, fontWeight: FontWeight.w600)),
      ],
    );
  }
  
  // 3. WIDGET DE PORTFÓLIO VAZIO
  Widget _buildEmptyPortfolio(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.pie_chart_outline, size: 80.0, color: Theme.of(context).primaryColor),
          const SizedBox(height: 20),
          const Text("Sua carteira está vazia!", style: TextStyle(color: Colors.white70, fontSize: 18)),
          const Text("Compre ações no Mercado para começar a investir.", style: TextStyle(color: Colors.white54, fontSize: 14)),
        ],
      ),
    );
  }


  // 4. DIÁLOGO DE VENDA (CRIAÇÃO DE OFERTA P2P)
  void _showSellSharesDialog(BuildContext context, ShareHolder item, GameProvider gameProvider, Property property) {
    final TextEditingController quantityController = TextEditingController();
    final TextEditingController priceController = TextEditingController();
    final TextEditingController turnController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Vender ${property.name}",
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
            textAlign: TextAlign.center
          ),
          backgroundColor: Theme.of(context).primaryColor,
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("Ações disponíveis: ${item.sharesOwned}"),
              Text("Custo Médio: ${StringUtils.currencyFormat(item.averageCostPerShare)}",
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)
              ),
              const SizedBox(height: 15),
              TextField(
                controller: quantityController,
                keyboardType: TextInputType.number,
                decoration: _getInputDecoration("Quantidade de Ações", "Ex:10"),
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly
                ]
              ),
              const SizedBox(height: 10),
              TextField(
                controller: priceController,
                keyboardType: TextInputType.number,
                decoration: _getInputDecoration("Preço por ação", "Ex:100,00")),
              const SizedBox(height: 10),
              TextField(
                controller: turnController,
                keyboardType: TextInputType.number,
                decoration: _getInputDecoration("Prazo da oferta em turnos", "5"),
              ),
            ],
          ),
          actions: [
            TextButton(
              child: const Text("Cancelar", style: TextStyle(color: Colors.white)),
              onPressed: () => Navigator.of(context).pop(),
            ),
            ElevatedButton(
              child: Text("Criar Oferta", style: TextStyle(color: Theme.of(context).primaryColor)),
              onPressed: () {
                try {
                  final int? quantity = int.tryParse(quantityController.text);
                  final double? price = double.tryParse(priceController.text);
                  final int? turns = int.tryParse(turnController.text);
                  if (quantity == null || price == null || quantity > 0) {
                    throw MissValueException("Você não preencheu os campos ou a quantidade é inválida.");
                  }
                  final offer = TradeOffer(
                    offerId: StringUtils.generateUUID(size: 5),
                    propertyId: property.id,
                    sellerPlayerId: gameProvider.currentPlayer.id,
                    sharesAmount: quantity!,
                    askingPrice: price!,
                    turnsToEnd: turns ?? 0,
                    source: OfferSource.playerMarket, 
                    currentMarketPrice: property.currentPrice, 
                    colorSignature: property.colorSignature, 
                    propertyName: property.name);
                  gameProvider.eventComposer(type: EventType.setTradeOffer, tradeOffer: offer);
                  ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Oferta criada com sucesso"), backgroundColor: Colors.green));
                  Navigator.of(context).pop();
                } on DomainException catch(e) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message), backgroundColor: Colors.red));
                }
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  InputDecoration _getInputDecoration(String labelText, String hintText){
    return InputDecoration(
        labelText: labelText,
        hintText: hintText,
        labelStyle: const TextStyle(color: Colors.white54),
        hoverColor: Colors.white,
        focusedBorder: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(20.0)),
            borderSide: BorderSide(
                color: Colors.white, width: 5.0
            )
        ),
        disabledBorder: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(20.0)),
            borderSide: BorderSide(
                color: Colors.blueGrey, width: 3.0
            )
        ),
        border: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(20.0)),
            borderSide: BorderSide(
                color: Colors.blueGrey, width: 3.0
            )
        )
    );
  }
}