
import 'package:account_monopoly/domain/enums/event_type.dart';
import 'package:account_monopoly/domain/model/property.dart';
import 'package:account_monopoly/provider/game_provider.dart';
import 'package:account_monopoly/widgets/percent_spinner.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:account_monopoly/utils/string_utils.dart';

class PropertyDetailsScreen extends StatelessWidget {
  final String propertyId;

  const PropertyDetailsScreen({super.key, required this.propertyId});

  @override
  Widget build(BuildContext context) {
    return Consumer<GameProvider>(
      builder: (context, gameProvider, child) {
        final property = gameProvider.ledger.properties[propertyId];
        final ledger = gameProvider.ledger;

        if (property == null) {
          return Scaffold(
            appBar: AppBar(title: const Text("Erro")),
            body: const Center(child: Text("Propriedade não encontrada.")),
          );
        }

        // --- CONTEÚDO DA TELA DE DETALHES ---
        return Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: property.colorSignature,
            title: Text(property.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            centerTitle: true,
            iconTheme: const IconThemeData(color: Colors.white),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                _buildHeader(context, property),
                
                const SizedBox(height: 20),

                _buildPayoutChanger(context, gameProvider, property),
                const SizedBox(height: 20),
                // 2. STATUS DO ATIVO
                _buildSectionTitle("📈 Status de Mercado", property.colorSignature),
                _buildStatusSection(context, property, ledger),
                
                const SizedBox(height: 20),
                
                // 3. MÉTICAS DE RENDA
                _buildSectionTitle("💰 Fluxo de Renda (Aluguel)", property.colorSignature),
                _buildIncomeSection(context, property),

                const SizedBox(height: 20),

                // 4. HISTÓRICO DE AÇÕES (Placeholder)
                _buildSectionTitle("📊 Histórico & Volatilidade", property.colorSignature),
                _buildHistoryPlaceholder(context),

                const SizedBox(height: 20),
                
              ],
            ),
          ),
        );
      },
    );
  }

  // --- WIDGETS AUXILIARES ---

  Widget _buildSectionTitle(String title, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, top: 4.0),
      child: Text(
        title,
        style: TextStyle(
          color: color, 
          fontSize: 18, 
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2
        ),
      ),
    );
  }

  // Seção 1: Cabeçalho com Preço e Ícone
  Widget _buildHeader(BuildContext context, dynamic property) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 15.0),
      decoration: BoxDecoration(
        color: property.colorSignature.withOpacity(0.15),
        borderRadius: BorderRadius.circular(10.0),
        border: Border.all(color: property.colorSignature.withOpacity(0.5)),
      ),
      child: Row(
        children: [
          Icon(property.iconSignature.icon, size: 40, color: property.colorSignature),
          const SizedBox(width: 15),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("PREÇO ATUAL DA AÇÃO", style: TextStyle(color: Colors.white70, fontSize: 12)),
              Text(
                StringUtils.currencyFormat(property.sharePrice),
                style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 28
                ),
              ),
            ],
          ),
          const Spacer(),
          // Seção para variação do dia (Ex: +1.5%)
          // _buildPriceChangeIndicator(property), 
        ],
      ),
    );
  }

  // Seção 2: Status do Ativo (Total de Ações, Valor Total, Edifícios)
  Widget _buildStatusSection(BuildContext context, Property property, dynamic ledger) {
    // Cálculo do valor de mercado (Market Cap)
    final double marketCap = property.totalShares * property.sharePrice; 
    var currentPlayer = Provider.of<GameProvider>(context).currentPlayer;
    String? owner = (currentPlayer.id == property.majorOwnerId) ? currentPlayer.username : Provider.of<GameProvider>(context).otherPlayers[property.majorOwnerId]?.username;
    return Card(
      color: const Color(0xFF1E1E1E), // Fundo mais escuro
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            _buildDetailRow("💰 Valor Total de Mercado (Market Cap)", StringUtils.currencyFormat(marketCap), context, Colors.lightGreen),
            _buildDetailRow("🏠 Edifícios Construídos", property.buildings.toString(), context, Colors.white),
            _buildDetailRow("🧾 Valor atual do aluguel", StringUtils.currencyFormat(property.currentRent), context, Colors.lightGreen),
            const Divider(color: Colors.white12),
            _buildDetailRow("🏷️ Ações Totais Emitidas", property.totalShares.toString(), context, Colors.white70),
            _buildDetailRow("🏦 Ações Disponíveis (Banco/Fundo)", property.availableShares.toString(), context, Colors.amber),
            _buildDetailRow("🧐 Acionista majoritario", owner ?? "", context, Colors.blue)
          ],
        ),
      ),
    );
  }

  // Seção 3: Métricas de Renda
  Widget _buildIncomeSection(BuildContext context, Property property) {
    final double yieldRate = (((property.collectedRent * property.payoutPercentage)/property.totalShares) / property.sharePrice) * 100; // Rendimento por ação
    
    return Card(
      color: const Color(0xFF1E1E1E),
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            _buildDetailRow("💵 Renda Base por Turno", StringUtils.currencyFormat(property.currentRent), context, Colors.lightGreenAccent),
            _buildDetailRow("📈 Rendimento (Yield) por Ação", "${yieldRate.toStringAsFixed(2)}%", context, Colors.cyanAccent),
            _buildDetailRow("🔄 Payout (Distribuição de Renda)", "${(property.payoutPercentage * 100).toStringAsFixed(0)}%", context, Colors.white),
          ],
        ),
      ),
    );
  }
  
  // Seção 4: Placeholder de Histórico
  Widget _buildHistoryPlaceholder(BuildContext context) {
      return Container(
          height: 150,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: const Color(0xFF1E1E1E),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
                Icon(Icons.trending_up, size: 30, color: Colors.white30),
                SizedBox(height: 5),
                Text("Gráfico de Volatilidade e Histórico de Preços", style: TextStyle(color: Colors.white54)),
                Text("(Em breve)", style: TextStyle(color: Colors.white30, fontSize: 12)),
            ],
          )
      );
  }

  Widget _buildPayoutChanger(BuildContext context, GameProvider gameProvider, Property property) {
    int payout = (property.payoutPercentage * 100).toInt();
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 15.0),
      decoration: BoxDecoration(
        color: property.colorSignature.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(10.0),
        border: Border.all(color: property.colorSignature.withValues(alpha: .5)),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Agora você pode auterar o payout desta propriedade',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500, color: Colors.white),
            ),
            const SizedBox(height: 30),
            PercentSpinner(
              label: 'Payout',
              initialValue: payout,
              step: 5,
              onChanged: (newValue) {
                payout = newValue;
                gameProvider.notifyChanges(false);
              },
            ),
            const Divider(color: Colors.white12),
            ElevatedButton.icon(
                onPressed: (){
                  gameProvider.eventComposer(
                    type: EventType.propertyUpdatePayout,
                    propertyId: property.id
                  );
                  ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Payout atualizado")));
                  Navigator.of(context).pop();
                },
                icon: const Icon(Icons.save, size: 30, color: Colors.white),
                label: const Text(
                  'Salvar',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white, 
                  backgroundColor: property.colorSignature,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  shadowColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 20,
                ),
              )
          ],
        ),
      ),
    );
  }

  // Helper para Linhas de Detalhe
  Widget _buildDetailRow(String label, String value, BuildContext context, Color valueColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(child: Text(label, style: const TextStyle(color: Colors.white70, fontSize: 15))),
          Text(value, style: Theme.of(context).textTheme.titleMedium?.copyWith(color: valueColor, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}