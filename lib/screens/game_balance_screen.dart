import 'package:flutter/material.dart';

import '../widgets/chart_one.dart';
import '../widgets/chart_three.dart';
import '../widgets/chart_two.dart';


class GameBalanceScreen extends StatelessWidget {
  const GameBalanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
        height: MediaQuery.of(context).size.height -32,
        width: MediaQuery.of(context).size.width -8,
        padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 4.0),
        child: ListView(
          children: [
            ChartThree(),
            ChartOne(),
            ChartTwo(chartTitle: "Gastos na Rodada Atual", chartType: PieChartType.ROUND_EXPANSES),
            ChartTwo(chartTitle: "Ganhos na Rodada Atual", chartType: PieChartType.ROUND_PROFIT),
            ChartTwo(chartTitle: "Gastos Gerais no Jogo", chartType: PieChartType.GENERAL_EXPANSES),
            ChartTwo(chartTitle: "Ganhos Gerais no Jogo", chartType: PieChartType.GENERAL_PROFIT)
          ],
        )
    );
  }
}
