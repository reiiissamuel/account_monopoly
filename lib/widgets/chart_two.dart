/* import 'package:account_monopoly/domain/model/balance.dart';
import 'package:account_monopoly/domain/enums/pie_chart_type.dart';
import 'package:account_monopoly/provider/game_provider.dart';
import 'package:account_monopoly/utils/string_utils.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart'; // Novo pacote de gráficos
import 'package:provider/provider.dart';

/*
* Esse gráfico dá uma descrição dos gastos, ou lucros, podendo ser por rodada ou geral,
* utilizando o pacote fl_chart.
*/

class ChartTwo extends StatelessWidget {
  final String chartTitle;
  final PieChartType chartType;
  
  // Lista de fontes de dados do gráfico. Não precisa de 'late' ou inicialização complexa.
  List<ChartSource> sources = [];

  ChartTwo({super.key, required this.chartTitle, required this.chartType});

  // Cores adaptadas do MaterialPalette (charts_flutter) para Color (fl_chart/Flutter)
  static final Map<String, Color> _palette = {
    "Transferencia": Colors.purple.shade500,
    "Compras": Colors.green.shade500,
    "Construções": Colors.blue.shade500,
    "Eventos": Colors.red.shade500,
    "Parcelamento": Colors.yellow.shade500,
    "I. Renda": Colors.grey.shade500,
    "Outros": Colors.lime.shade500,
    "Bonus": Colors.green.shade500, // Reutilizando cores
    "Hipotecas": Colors.red.shade500, // Reutilizando cores
    "Empréstimo": Colors.yellow.shade700,
    "Restituição": Colors.grey.shade700,
    "Leilões": Colors.deepOrange.shade500,
  };

  void _buildChartSources(PieChartType type, GameProvider gameProvider) {
    // 1. Inicializa a lista de fontes (gastos ou lucros)
    if (type == PieChartType.GENERAL_EXPANSES || type == PieChartType.ROUND_EXPANSES) {
      sources = [
        ChartSource(indice: "Transferencia", value: 0, color: _palette["Transferencia"]!),
        ChartSource(indice: "Compras", value: 0, color: _palette["Compras"]!),
        ChartSource(indice: "Construções", value: 0, color: _palette["Construções"]!),
        ChartSource(indice: "Eventos", value: 0, color: _palette["Eventos"]!),
        ChartSource(indice: "Parcelamento", value: 0, color: _palette["Parcelamento"]!),
        ChartSource(indice: "I. Renda", value: 0, color: _palette["I. Renda"]!),
        ChartSource(indice: "Outros", value: 0, color: _palette["Outros"]!)
      ];
    } else { // Lucros
      sources = [
        ChartSource(indice: "Transferencia", value: 0, color: _palette["Transferencia"]!),
        ChartSource(indice: "Bonus", value: 0, color: _palette["Bonus"]!),
        ChartSource(indice: "Eventos", value: 0, color: _palette["Eventos"]!),
        ChartSource(indice: "Hipotecas", value: 0, color: _palette["Hipotecas"]!),
        ChartSource(indice: "Empréstimo", value: 0, color: _palette["Empréstimo"]!),
        ChartSource(indice: "Restituição", value: 0, color: _palette["Restituição"]!),
        ChartSource(indice: "Leilões", value: 0, color: _palette["Leilões"]!),
        ChartSource(indice: "Outros", value: 0, color: _palette["Outros"]!)
      ];
    }

    // 2. Preenche os valores
    switch (type) {
      case PieChartType.GENERAL_EXPANSES:
        for (Balance ba in gameProvider.gameModelDTO!.player.financialReport.balances) {
          sources[0].value += ba.transferOut;
          sources[1].value += ba.qtdPurchases;
          sources[2].value += (ba.qtdHome + ba.qtdHotel);
          sources[3].value += ba.qtdEventPay;
          sources[4].value += ba.ir;
          sources[5].value += ba.otherPaymentsOut;
        }
        break;
      case PieChartType.GENERAL_PROFIT:
        for (Balance ba in gameProvider.gameModelDTO!.player.financialReport.balances) {
          sources[0].value += ba.transferIn;
          sources[1].value += ba.bonus;
          sources[2].value += ba.qtdEventGain;
          sources[3].value += ba.mortgagesIn;
          sources[4].value += ba.loanIn;
          sources[5].value += ba.restituicao;
          sources[6].value += ba.auctionIn;
          sources[7].value += ba.otherReceives;
        }
        break;
      case PieChartType.ROUND_PROFIT:
        sources[0].value += gameProvider.gameModelDTO!.player.roundBalance.transferIn;
        sources[1].value += gameProvider.gameModelDTO!.player.roundBalance.bonus;
        sources[2].value += gameProvider.gameModelDTO!.player.roundBalance.qtdEventGain;
        sources[3].value += gameProvider.gameModelDTO!.player.roundBalance.mortgagesIn;
        sources[4].value += gameProvider.gameModelDTO!.player.roundBalance.loanIn;
        sources[5].value += gameProvider.gameModelDTO!.player.roundBalance.restituicao;
        sources[6].value += gameProvider.gameModelDTO!.player.roundBalance.auctionIn;
        sources[7].value += gameProvider.gameModelDTO!.player.roundBalance.otherReceives;
        break;
      case PieChartType.ROUND_EXPANSES:
        sources[0].value += gameProvider.gameModelDTO!.player.roundBalance.transferOut;
        sources[1].value += gameProvider.gameModelDTO!.player.roundBalance.qtdPurchases;
        sources[2].value += (gameProvider.gameModelDTO!.player.roundBalance.qtdHome + gameProvider.gameModelDTO!.player.roundBalance.qtdHotel);
        sources[3].value += gameProvider.gameModelDTO!.player.roundBalance.qtdEventPay;
        sources[4].value += gameProvider.gameModelDTO!.player.roundBalance.ir;
        sources[5].value += gameProvider.gameModelDTO!.player.roundBalance.otherPaymentsOut;
        break;
    }
    
    // 3. Remove itens com valor zero, pois o fl_chart não os renderiza bem.
    sources.removeWhere((source) => source.value == 0);
  }


  // Converte a lista de ChartSource (filtrada) em PieChartSectionData
  List<PieChartSectionData> _createSections(BuildContext context) {
    return sources.asMap().entries.map((entry) {
      final int index = entry.key;
      final ChartSource data = entry.value;

      return PieChartSectionData(
        color: data.color,
        value: data.value.toDouble(),
        title: StringUtils.currencyFormat(data.value.toString()), // Exibe o valor formatado
        radius: 50, // Tamanho do raio
        titleStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Color(0xffffffff),
        ),
        // Adiciona um Tooltip (rótulo) simples para que o usuário saiba o que é
        badgeWidget: null, // Pode ser usado para ícones
        // Rótulo principal, caso você queira um rótulo flutuante
        titlePositionPercentageOffset: 0.55, 
      );
    }).toList();
  }

  // Constrói a legenda (já que o fl_chart não tem uma embutida robusta)
  Widget _buildLegend(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: sources.map((source) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 2.0),
        child: Row(
          children: [
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: source.color,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              '${source.indice}: ${StringUtils.currencyFormat(source.value.toString())}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      )).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final gameProvider = Provider.of<GameProvider>(context);
    _buildChartSources(chartType, gameProvider);
    
    // Verifica se há dados para exibir. Se não houver, mostra uma mensagem.
    if (sources.isEmpty) {
        return Container(
          height: 220,
          padding: const EdgeInsets.all(2.0),
          child: Card(
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            child: Center(
              child: Text(
                'Nenhum dado disponível para este gráfico.',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ),
          ),
        );
    }

    final sections = _createSections(context);

    return Container(
      height: 250, // Aumentei um pouco para acomodar a legenda melhor
      padding: const EdgeInsets.all(2.0),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: <Widget>[
              Text(
                chartTitle,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Expanded(
                child: Row(
                  children: [
                    // Gráfico de Pizza (Ocupa 40% da largura)
                    Expanded(
                      flex: 4,
                      child: PieChart(
                        PieChartData(
                          sectionsSpace: 2, // Espaçamento entre as fatias
                          centerSpaceRadius: 40, // Raio do buraco central (donut)
                          startDegreeOffset: -90, // Começa em cima
                          borderData: FlBorderData(show: false),
                          sections: sections,
                          pieTouchData: PieTouchData(enabled: false), // Desabilita o toque para simplicidade
                        ),
                        swapAnimationDuration: const Duration(milliseconds: 150),
                        swapAnimationCurve: Curves.linear,
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Legenda (Ocupa 60% da largura)
                    Expanded(
                      flex: 6,
                      child: SingleChildScrollView(
                        child: _buildLegend(context),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ChartSource {
  String indice;
  num value;
  Color color; // Cor agora é um objeto Color padrão do Flutter

  ChartSource(
      {required this.indice,
        required this.value,
        required this.color,
      });
}
 */