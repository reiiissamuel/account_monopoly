/* import 'package:account_monopoly/provider/game_provider.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart'; // Importação do novo pacote
import 'package:provider/provider.dart';

import 'package:account_monopoly/domain/model/player.dart';

/*
* Esse gráfico mostra a relação de quanto cada jogador pagou a você e recebeu de você
* usando o pacote fl_chart, que é compatível com o Flutter 3.x/Dart 3.x.
*/

class ChartOne extends StatelessWidget {
  const ChartOne({super.key});

  @override
  Widget build(BuildContext context) {
    // Escuta o GameProvider para obter a lista de jogadores
    final gameProvider = Provider.of<GameProvider>(context);
    final List<Player> players = gameProvider.gameModelDTO!.othersPlayers.toList(growable: false);

    // Converte a lista de Players para o formato que o fl_chart entende
    final barGroups = _createBarGroups(players);

    return Container(
      height: 250, // Aumentei um pouco a altura para acomodar melhor o gráfico
      padding: const EdgeInsets.all(2.0),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Text(
                "Recebimentos e Pagamentos por Jogador",
                style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Expanded(
                child: BarChart(
                  BarChartData(
                    alignment: BarChartAlignment.spaceAround,
                    maxY: _getMaxValue(players) * 1.2, // Calcula o valor máximo para a escala Y
                    titlesData: _getTitlesData(context, players), // Configura rótulos X e Y
                    borderData: FlBorderData(show: false),
                    gridData: const FlGridData(show: true, drawVerticalLine: false),
                    barTouchData: const BarTouchData(enabled: false), // Desabilita o toque para simplicidade
                    barGroups: barGroups,
                  ),
                  swapAnimationDuration: const Duration(milliseconds: 150), // Animação
                  swapAnimationCurve: Curves.linear,
                ),
              ),
              _buildLegend(context),
            ],
          ),
        ),
      ),
    );
  }

  // Função para calcular o valor máximo da barra (para definir o Y max do gráfico)
  double _getMaxValue(List<Player> players) {
    double max = 0.0;
    for (var player in players) {
      if (player.receivedFrom.toDouble() > max) max = player.receivedFrom.toDouble();
      if (player.payedTo.toDouble() > max) max = player.payedTo.toDouble();
    }
    return max > 0 ? max : 1000.0; // Evita divisão por zero ou gráfico vazio
  }

  // Converte a lista de Players para BarChartGroupData
  List<BarChartGroupData> _createBarGroups(List<Player> players) {
    
    return players.asMap().entries.map((entry) {
      final int index = entry.key;
      final Player player = entry.value;

      return BarChartGroupData(
        x: index, // Posição no eixo X (índice do jogador)
        barRods: [
          // Barra de Recebimento (Verde)
          BarChartRodData(
            toY: player.receivedFrom.toDouble(),
            color: Colors.green.shade600,
            width: 10,
          ),
          // Barra de Pagamento (Vermelho)
          BarChartRodData(
            toY: player.payedTo.toDouble(),
            color: Colors.red.shade600,
            width: 10,
          ),
        ],
        // As propriedades barRodsStack e groupVertically foram removidas aqui.
      );
    }).toList();
  }

  // Configuração dos Títulos (Eixo X e Y)
  FlTitlesData _getTitlesData(BuildContext context, List<Player> players) {
    return FlTitlesData(
      show: true,
      // Configuração do Eixo X (Nomes dos Jogadores)
      bottomTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: 30,
          getTitlesWidget: (value, meta) {
            final index = value.toInt();
            if (index >= 0 && index < players.length) {
              return Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  players[index].username,
                  style: const TextStyle(fontSize: 10),
                  textAlign: TextAlign.center,
                ),
              );
            }
            return const Text('');
          },
        ),
      ),
      // Configuração do Eixo Y (Valores)
      leftTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: 40,
          getTitlesWidget: (value, meta) {
            // Formata o valor do eixo Y (ex: 1000.0 -> 1K)
            String text;
            if (value >= 1000) {
              text = '${(value / 1000).toInt()}K';
            } else {
              text = value.toInt().toString();
            }
            return Text(text, style: const TextStyle(fontSize: 10));
          },
        ),
      ),
      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
    );
  }

  // Cria a legenda na parte inferior
  Widget _buildLegend(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          _buildLegendItem(context, 'Recebeu', Colors.green.shade600),
          const SizedBox(width: 20),
          _buildLegendItem(context, 'Pagou', Colors.red.shade600),
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
}
 */