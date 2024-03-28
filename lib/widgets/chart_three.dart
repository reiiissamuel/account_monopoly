import 'package:account_monopoly/model/game_model.dart';
import 'package:flutter/material.dart';
import 'package:charts_flutter/flutter.dart' as charts;

/*
*
* Esse grafico mostra a relação de gastos e ganhos por rodada
* */


class ChartThree extends StatelessWidget {

  List<ChartSource> sources = [];


  _buildChartSource(GameModelController model){
    for (var ac in model.gameModelDTO!.balance.accounts) {
      sources.add(
          ChartSource(
              round: ac.round,
              inComming: model.gameModelDTO!.balance.getRoundIncomming(ac.round).toInt(),
              outGoing: model.gameModelDTO!.balance.getRoundOutGoing(ac.round).toInt())
      );
    }
  }


  @override
  Widget build(BuildContext context) {

   _buildChartSource(GameModelController.of(context));

    List<charts.Series<ChartSource, int>> series = [
      charts.Series(
          id: "balanceUP",
          data: sources,
          domainFn: (ChartSource source, _) => source.round,
          measureFn: (ChartSource source, _) => source.inComming,
          colorFn: (_, __) => charts.MaterialPalette.green.shadeDefault),
      charts.Series(
          id: "balanceDown",
          data: sources,
          domainFn: (ChartSource source, _) => source.round,
          measureFn: (ChartSource source, _) => source.outGoing,
          colorFn: (_, __) => charts.MaterialPalette.red.shadeDefault),

    ];

    return Container(
      height: 200,
      padding: const EdgeInsets.all(2.0),
      child: Card(
        color: Theme.of(context).primaryColor,
        child: Padding(
          padding: const EdgeInsets.all(4.0),
          child: Column(
            children: <Widget>[
              Text(
                "Lucros e gastos por rodada",
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              Expanded(
                child: charts.LineChart(series, animate: true, defaultRenderer:  charts.LineRendererConfig(includePoints: true))
              )
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
