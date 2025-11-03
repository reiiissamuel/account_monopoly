import 'package:account_monopoly/provider/game_provider.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart'; // Importação do novo pacote de gráficos
import 'package:provider/provider.dart';
import 'package:account_monopoly/utils/string_utils.dart'; // Usado para formatar o Tooltip

/*
* Esse gráfico mostra a relação de gastos e ganhos por rodada,
* utilizando o pacote fl_chart (Gráfico de Linhas).
*/

class ChartThree extends StatelessWidget {
  List<ChartSource> sources = [];

  ChartThree({super.key});

  void _buildChartSource(GameProvider gameProvider) {
    // Limpa a lista antes de reconstruir para evitar duplicação no build
    sources.clear(); 
    
    // Cria um Set para garantir que cada rodada (round) seja processada apenas uma vez
    Set<int> processedRounds = {};

    // Note: Use 'gameModelDTO!.balance.accounts.reversed' se você quiser a ordem da rodada mais recente para a mais antiga
    // Se 'ac.round' for sequencial, a ordem do For é suficiente.
    for (var ba in gameProvider.gameModelDTO!.player.financialReport.balances) {
      if (processedRounds.add(ba.round)) {
        sources.add(
          ChartSource(
            round: ba.round,
            inComming: gameProvider.gameModelDTO!.player.financialReport.getRoundIncomming(ba.round).toInt(),
            outGoing: gameProvider.gameModelDTO!.player.financialReport.getRoundOutGoing(ba.round).toInt(),
          )
        );
      }
    }
    // Opcional: Ordena por rodada para garantir que o gráfico de linha seja progressivo
    sources.sort((a, b) => a.round.compareTo(b.round));
  }
  
  // Converte a lista de fontes de dados em LineChartBarData para o fl_chart
  List<LineChartBarData> _createLineData() {
    // 1. Dados de Entrada (Lucros - Verde)
    final List<FlSpot> incommingSpots = sources
        .map((source) => FlSpot(source.round.toDouble(), source.inComming.toDouble()))
        .toList();

    // 2. Dados de Saída (Gastos - Vermelho)
    final List<FlSpot> outGoingSpots = sources
        .map((source) => FlSpot(source.round.toDouble(), source.outGoing.toDouble()))
        .toList();

    return [
      // Linha de Lucros (Entrada)
      LineChartBarData(
        spots: incommingSpots,
        isCurved: true,
        color: Colors.green.shade600,
        barWidth: 3,
        isStrokeCapRound: true,
        dotData: const FlDotData(show: true), // Mostrar os pontos
        belowBarData: BarAreaData(show: false),
      ),
      // Linha de Gastos (Saída)
      LineChartBarData(
        spots: outGoingSpots,
        isCurved: true,
        color: Colors.red.shade600,
        barWidth: 3,
        isStrokeCapRound: true,
        dotData: const FlDotData(show: true), // Mostrar os pontos
        belowBarData: BarAreaData(show: false),
      ),
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
          interval: 1, // Mostra um rótulo para cada rodada
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
          // Define a intervalos (opcionalmente pode ser dinâmico)
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
  Widget _buildLegend(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          _buildLegendItem(context, 'Lucros', Colors.green.shade600),
          const SizedBox(width: 20),
          _buildLegendItem(context, 'Gastos', Colors.red.shade600),
        ],
      ),
    );
  }

  // Item individual da legenda
  Widget _buildLegendItem(BuildContext context, String title, Color color) {
    return Row(
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

  @override
  Widget build(BuildContext context) {
    // 1. Preenche a fonte de dados
    _buildChartSource(Provider.of<GameProvider>(context));

    // Se não houver dados, retorna uma tela de placeholder
    if (sources.isEmpty) {
        return Container(
          height: 250,
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
    
    // 2. Cria os dados do gráfico
    final lineBarsData = _createLineData();
    
    // Encontra o valor máximo para definir o maxY do gráfico
    double maxIn = sources.fold(0.0, (prev, curr) => curr.inComming.toDouble() > prev ? curr.inComming.toDouble() : prev);
    double maxOut = sources.fold(0.0, (prev, curr) => curr.outGoing.toDouble() > prev ? curr.outGoing.toDouble() : prev);
    double maxY = (maxIn > maxOut ? maxIn : maxOut) * 1.2; // 20% de margem

    // 3. Renderiza o widget
    return Container(
      height: 250, // Aumentei a altura para melhor visualização
      padding: const EdgeInsets.all(2.0),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8.0, 16.0, 16.0, 8.0), // Ajustei o padding para o eixo Y
          child: Column(
            children: <Widget>[
              Text(
                "Lucros e Gastos por Rodada",
                style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Expanded(
                child: LineChart(
                  LineChartData(
                    lineBarsData: lineBarsData,
                    minY: 0,
                    maxY: maxY > 0 ? maxY : 1000,
                    minX: sources.isNotEmpty ? sources.first.round.toDouble() : 0,
                    maxX: sources.isNotEmpty ? sources.last.round.toDouble() : 5,
                    titlesData: _getTitlesData(context, maxY),
                    gridData: FlGridData(
                      show: true,
                      drawVerticalLine: true,
                      horizontalInterval: (maxY / 4).ceilToDouble(),
                      verticalInterval: 1,
                      getDrawingHorizontalLine: (value) {
                        return FlLine(
                          color: Colors.grey.withOpacity(0.3),
                          strokeWidth: 1,
                        );
                      },
                      getDrawingVerticalLine: (value) {
                        return FlLine(
                          color: Colors.grey.withOpacity(0.3),
                          strokeWidth: 1,
                        );
                      },
                    ),
                    borderData: FlBorderData(
                      show: true,
                      border: Border.all(color: Colors.grey.withOpacity(0.3), width: 1),
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
                              // Formata o valor do ponto tocado para moeda
                              StringUtils.currencyFormat(touchedSpot.y.toString()),
                              textStyle,
                            );
                          }).toList();
                        },
                      ),
                    ),
                    // As propriedades de animação foram removidas daqui para resolver o erro.
                    // A animação ainda é controlada internamente pelo LineChartData.
                  ),
                ),
              ),
              _buildLegend(context),
            ],
          ),
        ),
      ),
    );
  }
}

class ChartSource {
  int round;
  int inComming;
  int outGoing;

  ChartSource(
      {required this.round,
        required this.inComming,
        required this.outGoing,
      });
}
