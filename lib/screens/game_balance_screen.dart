import 'package:flutter/material.dart';

import 'package:account_monopoly/domain/enums/pie_chart_type.dart';
import 'package:account_monopoly/widgets/chart_one.dart';
import 'package:account_monopoly/widgets/chart_three.dart';
import 'package:account_monopoly/widgets/chart_two.dart';


class GameBalanceScreen extends StatelessWidget {
  const GameBalanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Relatório financeiro", style: TextStyle(letterSpacing: 2, color: Colors.white, fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Theme.of(context).primaryColor,
      ),
      backgroundColor: Colors.black,
      body: Container(
          height: MediaQuery.of(context).size.height -32,
          width: MediaQuery.of(context).size.width -8,
          padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 4.0),
          child: ListView(
            children: [
              ChartThree(),
              //const ChartOne(),
              ChartTwo(chartTitle: "Gastos na Rodada Atual", chartType: PieChartType.ROUND_EXPANSES),
              ChartTwo(chartTitle: "Ganhos na Rodada Atual", chartType: PieChartType.ROUND_PROFIT),
              ChartTwo(chartTitle: "Gastos Gerais no Jogo", chartType: PieChartType.GENERAL_EXPANSES),
              ChartTwo(chartTitle: "Ganhos Gerais no Jogo", chartType: PieChartType.GENERAL_PROFIT)
            ],
          )
      )
    );
  }
}