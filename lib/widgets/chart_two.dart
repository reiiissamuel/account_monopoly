import 'package:account_monopoly/domain/model/balance.dart';
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
    "transferIn": Colors.blueAccent,
    "transferOut": Colors.purple.shade500,
    "buyShares": Colors.orange.shade500,
    "buildings": Colors.yellow.shade500,
    "eventIn": Colors.indigo,
    "eventOut": Colors.pink,
    "incameTax": Colors.redAccent,
    "othersOut": Colors.red,
    "othersIn": Colors.greenAccent,
    "bonus": Colors.green.shade500,
    "refund": Colors.lime.shade500,
    "dividends": Colors.teal,
  };

  void _buildChartSources(PieChartType type, GameProvider gameProvider) {
    // 1. Inicializa a lista de fontes (gastos ou lucros)
    if (type == PieChartType.GENERAL_EXPANSES || type == PieChartType.ROUND_EXPANSES) {
      sources = [
        ChartSource(indice: "Transferencia", value: 0, color: _palette["transferOut"]!),
        ChartSource(indice: "Compras", value: 0, color: _palette["buyShares"]!),
        ChartSource(indice: "Construções", value: 0, color: _palette["buildings"]!),
        ChartSource(indice: "Eventos", value: 0, color: _palette["eventOut"]!),
        ChartSource(indice: "I. Renda", value: 0, color: _palette["incameTax"]!),
        ChartSource(indice: "Outros", value: 0, color: _palette["othersOut"]!)
      ];
    } else { // Lucros
      sources = [
        ChartSource(indice: "Transferencia", value: 0, color: _palette["transferIn"]!),
        ChartSource(indice: "Bonus", value: 0, color: _palette["bonus"]!),
        ChartSource(indice: "Eventos", value: 0, color: _palette["eventIn"]!),
        ChartSource(indice: "Restituição", value: 0, color: _palette["refund"]!),
        ChartSource(indice: "Dividendos", value: 0, color: _palette["dividends"]!),
        ChartSource(indice: "Outros", value: 0, color: _palette["othersIn"]!)
      ];
    }

    // 2. Preenche os valores
    switch (type) {
      case PieChartType.GENERAL_EXPANSES:
        for (Balance ba in gameProvider.gameModelDTO!.player.financialReport.historicalBalances.values) {
          sources[0].value += ba.transferOut;
          sources[1].value += ba.sharePurchasesOut;
          sources[2].value += ba.buildingPurchasesOut;
          sources[3].value += ba.eventOut;
          sources[4].value += ba.incomeTaxOut;
          sources[5].value += ba.otherOut;
        }
        break;
      case PieChartType.GENERAL_PROFIT:
        for (Balance ba in gameProvider.gameModelDTO!.player.financialReport.historicalBalances.values) {
          sources[0].value += ba.transferIn;
          sources[1].value += ba.bonusIn;
          sources[2].value += ba.eventIn;
          sources[3].value += ba.refundIn;
          sources[4].value += ba.dividendsIn;
          sources[5].value += ba.otherIn;
        }
        break;
      case PieChartType.ROUND_PROFIT:
        Balance ba = gameProvider!.currentPlayer.roundBalance;
        sources[0].value += ba.transferOut;
        sources[1].value += ba.sharePurchasesOut;
        sources[2].value += ba.buildingPurchasesOut;
        sources[3].value += ba.eventOut;
        sources[4].value += ba.incomeTaxOut;
        sources[5].value += ba.otherOut;
        break;
      case PieChartType.ROUND_EXPANSES:
        Balance ba = gameProvider!.currentPlayer.roundBalance;
        sources[0].value += ba.transferIn;
        sources[1].value += ba.bonusIn;
        sources[2].value += ba.eventIn;
        sources[3].value += ba.refundIn;
        sources[4].value += ba.dividendsIn;
        sources[5].value += ba.otherIn;
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
        title: StringUtils.currencyFormat(data.value.toDouble()), // Exibe o valor formatado
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
              '${source.indice}: ${StringUtils.currencyFormat(source.value.toDouble())}',
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