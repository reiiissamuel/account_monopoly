import 'package:account_monopoly/utils/tutorial_manager.dart';
import 'package:flutter/widgets.dart';

enum TutorialItemType {
    //HomeSreen Itens

    //GameScreen Itens
    broadcastTableId(title:'Código do Jogo', description: 'Clique aqui e copie o código clicando no icone de cópia e envie para os outros jogadores conseguirem entrar no jogo.'),
    exitButton(title:'Sair do Jogo', description: 'Clique aqui para sair do jogo (Você poderá voltar depois).'),
    roundViewer(title:'Rodada Atual', description: 'Este é o indicador de voltas ao redor do tabuleiro.'),
    balanceViewer(title:'Saldo', description: 'Aqui você acompanha o seu saldo durante o jogo. A vizualização pode ser desabilitada clicando no icone de olho.'),
    analysisButton(title:'Gráficos', description: 'Clique neste botão para ser levado à telada com análises e gráficos das rodadas.'),
    instructionsTable(title:'Manual de Utilidade', description: 'Clicando aqui você acessará um guia rápido de instuções poderá rever este tutorial.'),
    goMarButton(title:'Mercado de Propriedades', description: 'Clique para comprar propriedades (ações)'),
    goMyPortfolioButton(title:'Meu Portfólio', description: 'Clique ver todas as propriedades(ações) que você possiu, para vender, construir casas...'),
    goPlayersButton(title:'Tela de Jogadores', description: 'Clique aqui sempre que precisar transferir dinheiro para outros jogadores.'),
    goPayRentButton(title:'Tela de Pagamento de Aluguel', description: 'Cliqui aqui sempre que precisar pagar aluguel em alguma propriedade.'),
    goMyFinancialHealthButton(title:'Perfil Financeiro', description: 'Clique aqui para acessar e acompanhar seu resumos financeiros, emprestimos em aberto, total devido de IR...'),
    goMoreOptionsButton(title:'Mais Opções', description: 'Clique aqui para acessar opções rápidas tais como pagamentos ao banco, pagamento de IR, Solicitar restituição, solicitar o seu bonus de fim de rodada...'),
    goLoanButton(title:'Empréstimos', description: 'Clique aqui sempre que estiver apertado. O bando pode ter um emprestimo disponível pra você.'),
    logScreen(title:'Log de Eventos', description: 'Aqui você pode acompanhar todos os eventos que ocorreram durante o jogo.'),
    chanceButton(title:'Carta Evento', description: 'Clique aqui para pegar uma carta evento durante o jogo.');
    
    final String title;
    final String description;
    const TutorialItemType({required this.title, required this.description});

    // Getter dinâmico para mapear o enum à Global correspondente no TutorialManager
    GlobalKey get tutorialItemKey {
      switch (this) {
        case TutorialItemType.broadcastTableId:
          return TutorialManager.broadcastTableIdKey;
        case TutorialItemType.exitButton:
          return TutorialManager.exitButtonKey;
        case TutorialItemType.roundViewer:
          return TutorialManager.roundViewerKey;
        case TutorialItemType.balanceViewer:
          return TutorialManager.balanceViewerKey;
        case TutorialItemType.analysisButton:
          return TutorialManager.analysisButtonKey;
        case TutorialItemType.instructionsTable:
          return TutorialManager.instructionsTableKey;
        case TutorialItemType.goMarButton:
          return TutorialManager.goMarkeyButtonKey;
        case TutorialItemType.goMyPortfolioButton:
          return TutorialManager.goMyPortfolioButtonKey;
        case TutorialItemType.goPlayersButton:
          return TutorialManager.goPlayersButtonKey;
        case TutorialItemType.goPayRentButton:
          return TutorialManager.goPayRentButtonKey;
        case TutorialItemType.goMyFinancialHealthButton:
          return TutorialManager.goMyFinancialHealthButtonKey;
        case TutorialItemType.goMoreOptionsButton:
          return TutorialManager.goMoreOptionsButtonKey;
        case TutorialItemType.goLoanButton:
          return TutorialManager.goLoanButtonKey;
        case TutorialItemType.logScreen:
          return TutorialManager.logScreenKey;
        case TutorialItemType.chanceButton:
          return TutorialManager.chanceButtonKey;
      }
    }
    
}