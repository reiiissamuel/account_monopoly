import 'package:account_monopoly/domain/enums/tutorial_item_type.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:showcaseview/showcaseview.dart';

class TutorialManager {
  // --- CHAVES CENTRALIZADAS  ---
  // HOMESCREEN
  static final GlobalKey homeNewGameKey = GlobalKey();
  static final GlobalKey homeEnterCodeKey = GlobalKey();
  static final GlobalKey homeColorPaletteKey = GlobalKey();

  // GAMESCREEN
  static final GlobalKey broadcastTableIdKey = GlobalKey();
  static final GlobalKey exitButtonKey = GlobalKey();
  static final GlobalKey roundViewerKey = GlobalKey();
  static final GlobalKey balanceViewerKey = GlobalKey();
  static final GlobalKey analysisButtonKey = GlobalKey();
  static final GlobalKey instructionsTableKey = GlobalKey();
  static final GlobalKey goMarkeyButtonKey = GlobalKey();
  static final GlobalKey goMyPortfolioButtonKey = GlobalKey();
  static final GlobalKey goPlayersButtonKey = GlobalKey();
  static final GlobalKey goPayRentButtonKey = GlobalKey();
  static final GlobalKey goMyFinancialHealthButtonKey = GlobalKey();
  static final GlobalKey goMoreOptionsButtonKey= GlobalKey();
  static final GlobalKey goLoanButtonKey = GlobalKey();
  static final GlobalKey logScreenKey = GlobalKey();
  static final GlobalKey chanceButtonKey = GlobalKey();

  // --- MÉTODO REUTILIZÁVEL ---
  static Widget buildShowcase({
    required TutorialItemType type,
    required Widget child,
    ShapeBorder shapeBorder = const RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(12.0)),
    ),
  }) {
    return Showcase(
      key: type.tutorialItemKey, // Chama o getter dinâmico do enum
      title: type.title,
      description: type.description,
      targetShapeBorder: shapeBorder,
      child: child,
    );
  }

  // --- DISPARADORES DE TUTORIAL POR TELA ---
  static void startHomeTutorial(BuildContext context) {
    ShowCaseWidget.of(context).startShowCase([
      //TODO add
    ]);
  }

  static void startGameTutorial(BuildContext context) {
    ShowCaseWidget.of(context).startShowCase([
      TutorialItemType.broadcastTableId.tutorialItemKey,
      TutorialItemType.exitButton.tutorialItemKey,
      TutorialItemType.roundViewer.tutorialItemKey,
      TutorialItemType.chanceButton.tutorialItemKey,
      TutorialItemType.balanceViewer.tutorialItemKey,
      TutorialItemType.analysisButton.tutorialItemKey,
      TutorialItemType.instructionsTable.tutorialItemKey,
      TutorialItemType.goMarButton.tutorialItemKey,
      TutorialItemType.goMyPortfolioButton.tutorialItemKey,
      TutorialItemType.goPlayersButton.tutorialItemKey,
      TutorialItemType.goPayRentButton.tutorialItemKey,
      TutorialItemType.goMyFinancialHealthButton.tutorialItemKey,
      TutorialItemType.goMoreOptionsButton.tutorialItemKey,
      TutorialItemType.goLoanButton.tutorialItemKey,
      TutorialItemType.logScreen.tutorialItemKey
    ]);
  }
}