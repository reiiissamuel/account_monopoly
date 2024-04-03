import 'package:account_monopoly/utils/string_utils.dart';
import 'package:charts_flutter/flutter.dart';
import 'package:flutter/material.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:provider/provider.dart';

import '../dto/account.dart';
import '../enums/pie_chart_type.dart';
import '../provider/game_provider.dart';

/*
* esse grafico da uma descrição dos gastos, ou lucros, podendo ser por rodada ou geral
* */

class ChartTwo extends StatelessWidget {

  String chartTitle = "";
  PieChartType chartType;
  late GameProvider gameProvider;
  List<ChartSource> sources = [];

  ChartTwo({super.key, required this.chartTitle, required this.chartType});

   void _buildChartSources(PieChartType type, GameProvider gameProvider){

     (type == PieChartType.GENERAL_EXPANSES ||  type == PieChartType.ROUND_EXPANSES) ?
     sources = [
       ChartSource(indice: "Transferencia", value: 0, color: MaterialPalette.purple.shadeDefault),
       ChartSource(indice: "Compras", value: 0, color: MaterialPalette.green.shadeDefault),
       ChartSource(indice: "Construções", value: 0, color: MaterialPalette.blue.shadeDefault),
       ChartSource(indice: "Eventos", value: 0, color: MaterialPalette.red.shadeDefault),
       ChartSource(indice: "Parcelamento", value: 0, color: MaterialPalette.yellow.shadeDefault),
       ChartSource(indice: "I. Renda", value: 0, color: MaterialPalette.gray.shadeDefault),
       ChartSource(indice: "Outros", value: 0, color: MaterialPalette.lime.shadeDefault)
     ]
         :
     sources = [
       ChartSource(indice: "Transferencia", value: 0, color: MaterialPalette.purple.shadeDefault),
       ChartSource(indice: "Bonus", value: 0, color: MaterialPalette.green.shadeDefault),
       ChartSource(indice: "Eventos", value: 0, color: MaterialPalette.blue.shadeDefault),
       ChartSource(indice: "Hipotecas", value: 0, color: MaterialPalette.red.shadeDefault),
       ChartSource(indice: "Empréstimo", value: 0, color: MaterialPalette.yellow.shadeDefault),
       ChartSource(indice: "Restituição", value: 0, color: MaterialPalette.gray.shadeDefault),
       ChartSource(indice: "Leilões", value: 0, color: MaterialPalette.deepOrange.shadeDefault),
       ChartSource(indice: "Outros", value: 0, color: MaterialPalette.lime.shadeDefault)
     ];
    switch(type){
      case PieChartType.GENERAL_EXPANSES:
        for (Account ac in gameProvider.gameModelDTO!.balance.accounts) {
          sources[0].value += ac.transferOut;
          sources[1].value += ac.qtdPurchases;
          sources[2].value += (ac.qtdHome + ac.qtdHotel);
          sources[3].value += ac.qtdEventPay;
          sources[4].value += ac.previousAccountInstallment;
          sources[5].value += ac.ir;
          sources[6].value += ac.otherPaymentsOut;
        }
        break;
      case PieChartType.GENERAL_PROFIT:
        for (Account ac in gameProvider.gameModelDTO!.balance.accounts) {
          sources[0].value += ac.transferIn;
          sources[1].value += ac.bonus;
          sources[2].value += ac.qtdEventGain;
          sources[3].value += ac.mortgagesIn;
          sources[4].value += ac.loanIn;
          sources[5].value += ac.restituicao;
          sources[6].value += ac.auctionIn;
          sources[7].value += ac.otherReceives;
        }
        break;
      case PieChartType.ROUND_PROFIT:
        sources[0].value += gameProvider.gameModelDTO!.account.transferIn;
        sources[1].value += gameProvider.gameModelDTO!.account.bonus;
        sources[2].value += gameProvider.gameModelDTO!.account.qtdEventGain;
        sources[3].value += gameProvider.gameModelDTO!.account.mortgagesIn;
        sources[4].value += gameProvider.gameModelDTO!.account.loanIn;
        sources[5].value += gameProvider.gameModelDTO!.account.restituicao;
        sources[6].value += gameProvider.gameModelDTO!.account.auctionIn;
        sources[7].value += gameProvider.gameModelDTO!.account.otherReceives;
        break;
      case PieChartType.ROUND_EXPANSES:
        sources[0].value += gameProvider.gameModelDTO!.account.transferOut;
        sources[1].value += gameProvider.gameModelDTO!.account.qtdPurchases;
        sources[2].value += (gameProvider.gameModelDTO!.account.qtdHome + gameProvider.gameModelDTO!.account.qtdHotel);
        sources[3].value += gameProvider.gameModelDTO!.account.qtdEventPay;
        sources[4].value += gameProvider.gameModelDTO!.account.previousAccountInstallment;
        sources[5].value += gameProvider.gameModelDTO!.account.ir;
        sources[6].value += gameProvider.gameModelDTO!.account.otherPaymentsOut;
        break;
    }
  }

  @override
  Widget build(BuildContext context) {

    _buildChartSources(chartType, Provider.of<GameProvider>(context));

    List<charts.Series<ChartSource, String> > series =[
      charts.Series<ChartSource, String>(
          id: "expansesround",
          data: sources,
          domainFn: (ChartSource source, _) => source.indice,
          measureFn: (ChartSource source, _) => source.value,
          colorFn: (ChartSource source, _) => source.color,
          labelAccessorFn: (ChartSource row, _) =>'${row.indice}:${row.value}',
      )];

    return Container(
      height: 220,
      padding: const EdgeInsets.all(2.0),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(4.0),
          child: Column(
            children: <Widget>[
              Text(
                chartTitle,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              Expanded(
              child: charts.PieChart<String>(series, animate: true,defaultRenderer:  charts.ArcRendererConfig(arcRatio: 1,
                  arcWidth: 50), behaviors: [
                charts.DatumLegend(
                  // Positions for "start" and "end" will be left and right respectively
                  // for widgets with a build context that has directionality ltr.
                  // For rtl, "start" and "end" will be right and left respectively.
                  // Since this example has directionality of ltr, the legend is
                  // positioned on the right side of the chart.
                  position: charts.BehaviorPosition.end,
                  // By default, if the position of the chart is on the left or right of
                  // the chart, [horizontalFirst] is set to false. This means that the
                  // legend entries will grow as new rows first instead of a new column.
                  horizontalFirst: false,
                  // This defines the padding around each legend entry.
                  cellPadding: const EdgeInsets.only(right: 4.0, bottom: 4.0),
                  // Set [showMeasures] to true to display measures in series legend.
                  showMeasures: true,
                  // Configure the measure value to be shown by default in the legend.
                  legendDefaultMeasure: charts.LegendDefaultMeasure.firstValue,
                  // Optionally provide a measure formatter to format the measure value.
                  // If none is specified the value is formatted as a decimal.
                  measureFormatter: (value) {
                    return value == null ? '-' : StringUtils.currencyFormat(value.toString());
                  },
                ),
              ],))
            ],
          ),
        ),
      ),
    );
  }
}

class ChartSource {
  String indice;
  int value;
  Color color = MaterialPalette.green.shadeDefault;

  ChartSource(
      {required this.indice,
        required this.value,
        required this.color,
      });
}