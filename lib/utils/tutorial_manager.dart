import 'package:account_monopoly/domain/enums/tutorial_item_type.dart';
import 'package:flutter/material.dart';
import 'package:showcaseview/showcaseview.dart';

class TutorialManager {
  final List<TutorialItemType> _order;
  final Map<TutorialItemType, GlobalKey> _keys;

  // Construtor principal: recebe a lista ordenada e cria as chaves só desses itens
  TutorialManager(List<TutorialItemType> order)
      : _order = List.unmodifiable(order),
        _keys = {for (final t in order) t: GlobalKey()};

  // Um construtor nomeado por tela, só define a lista
  TutorialManager.game()
      : this(const [
          TutorialItemType.broadcastTableId,
          TutorialItemType.exitButton,
          TutorialItemType.roundViewer,
          TutorialItemType.chanceButton,
          TutorialItemType.balanceViewer,
          TutorialItemType.analysisButton,
          TutorialItemType.instructionsTable,
          TutorialItemType.goMarketButton,
          TutorialItemType.goMyPortfolioButton,
          TutorialItemType.goPlayersButton,
          TutorialItemType.goPayRentButton,
          TutorialItemType.goMyFinancialHealthButton,
          TutorialItemType.goMoreOptionsButton,
          TutorialItemType.goLoanButton,
          TutorialItemType.logScreen,
        ]);
  
  TutorialManager.market()
      : this(const [
        TutorialItemType.searchPropertyByName,
        TutorialItemType.propertyListView
      ]);
  
  TutorialManager.myPortfolio()
      : this(const [
        TutorialItemType.myPortfolioSummaryView,
        TutorialItemType.myPortfolioListView
      ]);

  TutorialManager.home()
      : this(const [
          //TODO
        ]);

  Widget buildShowcase({
    required TutorialItemType type,
    required Widget child,
    ShapeBorder shapeBorder = const RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(12.0)),
    ),
  }) {
    final key = _keys[type];
    assert(key != null, '$type não faz parte do tutorial desta tela');

    // Se o item não pertence a esta tela, devolve o widget sem showcase
    if (key == null) return child;

    return Showcase(
      key: key,
      title: type.title,
      description: type.description,
      targetShapeBorder: shapeBorder,
      tooltipBackgroundColor: Colors.grey[900]!,
      textColor: Colors.white,
      titleTextStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white70),
      descTextStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
      tooltipPadding: const EdgeInsets.all(16),
      showArrow: true,
      blurValue: 1,
      child: child,
    );
  }

  void startTutorial(BuildContext context) {
    ShowCaseWidget.of(context).startShowCase(
      [for (final t in _order) _keys[t]!],
    );
  }
}