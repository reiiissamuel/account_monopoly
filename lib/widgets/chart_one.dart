import 'package:account_monopoly/provider/game_provider.dart';
import 'package:flutter/material.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:provider/provider.dart';

import 'package:account_monopoly/dto/player.dart';

/*
* Esse grafico mostra a relação de quanto cada jogador pagou a você e recebeu de vocÊ
* */

class ChartOne extends StatelessWidget {
  const ChartOne({super.key});


  @override
  Widget build(BuildContext context) {

    List<Player> players = Provider.of<GameProvider>(context).gameModelDTO!.othersPlayers.toList(growable: false);

    List<charts.Series<Player, String>> series = [
      charts.Series(
          id: "receiveFrom",
          data: players,
          domainFn: (Player player, _) => player.username,
          measureFn: (Player player, _) => player.receivedFrom,
          colorFn: (_, __) => charts.MaterialPalette.green.shadeDefault),
      charts.Series(
          id: "payedTo",
          data: players,
          domainFn: (Player player, _) => player.username,
          measureFn: (Player player, _) => player.payedTo,
          colorFn: (_, __) => charts.MaterialPalette.red.shadeDefault),

    ];

    return Container(
      height: 200,
      padding: const EdgeInsets.all(2.0),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(4.0),
          child: Column(
            children: <Widget>[
              Text(
                "Recebimentos e Pagamentos por Jogador",
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              Expanded(
                child: charts.BarChart(series, animate: true),
              )
            ],
          ),
        ),
      ),
    );
  }
}
