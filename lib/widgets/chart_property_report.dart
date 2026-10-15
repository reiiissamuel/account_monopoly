import 'dart:math' as math;

import 'package:account_monopoly/domain/model/property.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:account_monopoly/utils/string_utils.dart';

/*
* Esse gráfico mostra a relação de gastos e ganhos por rodada,
* utilizando o pacote fl_chart (Gráfico de Linhas).
*/

class ChartPropertyReport extends StatelessWidget {

  final Property property;
  final List<ChartSource> sources = []; // Mudei para final se for inicializada no construtor, ou mantenha como está. Como é modificada, melhor manter sem 'final'.

  ChartPropertyReport({super.key, required this.property});

  void _buildChartSource() {
    // Limpa a lista antes de reconstruir para evitar duplicação no build
    sources.clear();

    int occorrencesToShow = 10;
    // Otimização de código (como sugerido anteriormente):
    List<double> lastTenDividends = property.historicalDividends.reversed
        .take(occorrencesToShow)
        .toList()
        .reversed
        .toList();

    List<double> lastTenRents = property.historicalRents.reversed
        .take(occorrencesToShow)
        .toList()
        .reversed
        .toList();

    List<double> lastTenSharesPrice = property.historicalSharesPrices.reversed
        .take(occorrencesToShow)
        .toList()
        .reversed
        .toList();

    int minListLength = math.min(lastTenDividends.length, math.min(lastTenRents.length, lastTenSharesPrice.length));
    int count = occorrencesToShow > minListLength ? minListLength : occorrencesToShow;
    for (int i = 0; i < count; i++) {
      sources.add(
          ChartSource(
              round: i,
              sharesPrice: lastTenSharesPrice[i],
              rents: lastTenRents[i],
              dividends: lastTenDividends[i]
          )
      );
    }
    sources.sort((a, b) => a.round.compareTo(b.round));
  }

  // A ordem de criação das linhas é: 0: Dividendos, 1: Preço/Ação, 2: Renda
  List<LineChartBarData> _createLineData() {

    final List<FlSpot> rentsSpots = sources
        .map((source) => FlSpot(source.round.toDouble(), source.rents.toDouble()))
        .toList();

    final List<FlSpot> dividendsSpots = sources
        .map((source) => FlSpot(source.round.toDouble(), source.dividends.toDouble()))
        .toList();

    final List<FlSpot> sharePriceSpots = sources
        .map((source) => FlSpot(source.round.toDouble(), source.sharesPrice.toDouble()))
        .toList();

    return [
      LineChartBarData(
        spots: dividendsSpots,
        isCurved: true,
        color: Colors.green.shade600,
        barWidth: 3,
        isStrokeCapRound: true,
        dotData: const FlDotData(show: true),
        belowBarData: BarAreaData(show: false),
      ),
      LineChartBarData(
        spots: sharePriceSpots,
        isCurved: true,
        color: Colors.black,
        barWidth: 3,
        isStrokeCapRound: true,
        dotData: const FlDotData(show: true),
        belowBarData: BarAreaData(show: false),
      ),
      LineChartBarData(
        spots: rentsSpots,
        isCurved: true,
        color: Colors.blue.shade600,
        barWidth: 3,
        isStrokeCapRound: true,
        dotData: const FlDotData(show: true),
        belowBarData: BarAreaData(show: false),
      )
    ];
  }

  // Configuração dos Rótulos (Eixo X e Y)
  FlTitlesData _getTitlesData(BuildContext context, double maxY) {
    return FlTitlesData(
      show: true,
      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      // Eixo X: Rótulos para Rodadas
      bottomTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: 30,
          interval: 1,
          getTitlesWidget: (value, meta) {
            return Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text(
                'R${value.toInt()}', // Ex: R1, R2, R3...
                style: const TextStyle(fontSize: 10),
              ),
            );
          },
        ),
      ),
      // Eixo Y: Rótulos para Valores
      leftTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: 40,
          interval: (maxY / 4).ceilToDouble(),
          getTitlesWidget: (value, meta) {
            String text;
            if (value >= 1000) {
              text = '${(value / 1000).toStringAsFixed(0)}K';
            } else if (value > 0) {
              text = value.toStringAsFixed(0);
            } else {
              text = '0';
            }
            return Text(text, style: const TextStyle(fontSize: 10));
          },
        ),
      ),
    );
  }

  // Função para criar a legenda
  Widget _buildLegend(BuildContext context, {required List<String> titles, required List<Color> colors}) {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0, bottom: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(titles.length, (index) {
          return Padding(
            padding: EdgeInsets.only(right: index < titles.length - 1 ? 20 : 0),
            child: _buildLegendItem(context, titles[index], colors[index]),
          );
        }),
      ),
    );
  }

  // Item individual da legenda
  Widget _buildLegendItem(BuildContext context, String title, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          title,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }

  // Widget auxiliar para construir um LineChart individual
  // Widget auxiliar para construir um LineChart individual
  Widget _buildSingleChart({
    required BuildContext context,
    required List<LineChartBarData> barData,
    required double maxY,
    required String title,
    required List<String> legendTitles,
    required List<Color> legendColors,
  }) {
    if (barData.isEmpty) {
      return const Center(child: Text("Dados indisponíveis", style: TextStyle(color: Colors.white70)));
    }

    return Column(
      children: <Widget>[
        // Título do Subgráfico
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: Colors.black
          ),
          textAlign: TextAlign.center,
        ),
        // Gráfico
        Expanded( // MUDANÇA AQUI: Use Expanded para forçar o gráfico a preencher o espaço restante.
          child: LineChart(
            LineChartData(
              lineBarsData: barData,
              // ... (restante da configuração do LineChartData) ...
              minY: 0,
              maxY: maxY > 0 ? maxY : 1000,
              minX: sources.isNotEmpty ? sources.first.round.toDouble() : 0,
              maxX: sources.isNotEmpty ? sources.last.round.toDouble() : 10,
              titlesData: _getTitlesData(context, maxY),
              gridData: FlGridData(
                show: true,
                drawVerticalLine: true,
                horizontalInterval: (maxY / 4).ceilToDouble(),
                verticalInterval: 1,
                getDrawingHorizontalLine: (value) {
                  return const FlLine(color: Colors.grey, strokeWidth: 1);
                },
                getDrawingVerticalLine: (value) {
                  return const FlLine(color: Colors.grey, strokeWidth: 1);
                },
              ),
              borderData: FlBorderData(
                show: true,
                border: Border.all(color: Colors.grey, width: 1),
              ),
              lineTouchData: LineTouchData(
                enabled: true,
                touchTooltipData: LineTouchTooltipData(
                  getTooltipItems: (touchedSpots) {
                    return touchedSpots.map((LineBarSpot touchedSpot) {
                      final textStyle = TextStyle(
                        color: touchedSpot.bar.color,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      );
                      return LineTooltipItem(
                        StringUtils.currencyFormat(touchedSpot.y),
                        textStyle,
                      );
                    }).toList();
                  },
                ),
              ),
            ),
          ),
        ),
        // Legenda (altura fixa)
        _buildLegend(context, titles: legendTitles, colors: legendColors),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {

    _buildChartSource();

    if (sources.isEmpty) {
      return Card(
        color: Colors.transparent,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: const Center(
          child: Text(
            'Nenhum dado disponível para este gráfico.',
            style: TextStyle(color: Colors.white),
          ),
        ),
      );
    }

    final lineBarsData = _createLineData();

    // Cálculo dos MAX Y para cada gráfico
    double maxSharePrice = sources.fold(0.0, (prev, curr) => curr.sharesPrice.toDouble() > prev ? curr.sharesPrice.toDouble() : prev);
    double maxSharesDividends = sources.fold(0.0, (prev, curr) => curr.dividends.toDouble() > prev ? curr.dividends.toDouble() : prev);
    double maxSharesInfoY = math.max(maxSharePrice, maxSharesDividends) * 1.2;

    double maxYRent = sources.fold(0.0, (prev, curr) => curr.rents.toDouble() > prev ? curr.rents.toDouble() : prev) * 1.2;

    // Garante que o Card interno do gráfico ocupe o espaço do Expanded no pai
    return Card(
      elevation: 4,
      color: Colors.white70,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8.0, 16.0, 16.0, 8.0),
        child: Column(
          children: <Widget>[
            // 1. Gráfico de Dividendos e Preço/Ação (Linhas 0 e 1)
            Expanded( // Ocupa metade do espaço vertical disponível
              child: _buildSingleChart(
                context: context,
                // CORREÇÃO: Pega as linhas 0 (Dividendos) e 1 (Preço/Ação)
                barData: lineBarsData.sublist(0, 2),
                maxY: maxSharesInfoY,
                title: "Dividendos vs. Preço/Ação",
                legendTitles: ['Dividendos', 'Preço/ação'],
                legendColors: [Colors.green.shade600, Colors.black],
              ),
            ),
            const Divider(color: Colors.white12, height: 20, indent: 20, endIndent: 20),

            // 2. Gráfico de Renda (Aluguel) (Linha 2)
            Expanded( // Ocupa a outra metade do espaço vertical disponível
              child: _buildSingleChart(
                context: context,
                // CORREÇÃO: Pega a linha 2 (Renda)
                barData: [lineBarsData[2]],
                maxY: maxYRent,
                title: "Renda (Aluguel) por Rodada",
                legendTitles: ['Renda'],
                legendColors: [Colors.blue.shade600],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ChartSource {
  final int round;
  final double dividends;
  final double sharesPrice;
  final double rents;

  ChartSource(
      {
        required this.round,
        required this.dividends,
        required this.sharesPrice,
        required this.rents
      });
}