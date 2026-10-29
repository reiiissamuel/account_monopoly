enum TutorialItemType {
    //HomeSreen Itens

    //GameScreen Itens
    broadcastTableId(title:'Código do Jogo', description: 'Clique aqui e copie o código clicando no icone de cópia e envie para os outros jogadores que irão entrar no jogo.'),
    exitButton(title:'Sair do Jogo', description: 'Clique aqui para sair do jogo (Você poderá voltar depois).'),
    roundViewer(title:'Rodada Atual', description: 'Este é o indicador de voltas ao redor do tabuleiro.'),
    balanceViewer(title:'Saldo', description: 'Aqui você acompanha o seu saldo durante o jogo.\nA visualização pode ser desabilitada clicando no icone de olho.'),
    analysisButton(title:'Gráficos', description: 'Clique neste botão para ser levado à tela de análises e gráficos das rodadas.'),
    instructionsTable(title:'Manual de Utilidade', description: 'Clicando aqui você terá acesso a um guia rápido de instuções do jogo, além de poder rever este tutorial.'),
    goMarketButton(title:'Mercado de Propriedades', description: 'Clique para comprar propriedades (ações)'),
    goMyPortfolioButton(title:'Meu Portfólio', description: 'Clique ver todas as propriedades(ações) que você possiu, para vender, construir casas...'),
    goPlayersButton(title:'Tela de Jogadores', description: 'Clique aqui sempre que precisar transferir dinheiro para outros jogadores.'),
    goPayRentButton(title:'Tela de Pagamento de Aluguel', description: 'Cliqui aqui sempre que precisar pagar aluguel em alguma propriedade.'),
    goMyFinancialHealthButton(title:'Perfil Financeiro', description: 'Clique aqui para acessar e acompanhar seu resumos financeiros, emprestimos em aberto, total devido de IR...'),
    goMoreOptionsButton(title:'Mais Opções', description: 'Clique aqui para acessar opções rápidas tais como pagamentos ao banco, pagamento de IR, Solicitar restituição, solicitar o seu bonus de fim de rodada...'),
    goLoanButton(title:'Empréstimos', description: 'Clique aqui sempre que estiver apertado. O bando pode ter um emprestimo disponível pra você.'),
    logScreen(title:'Log de Eventos', description: 'Aqui você pode acompanhar todos os eventos que ocorreram durante o jogo.'),
    chanceButton(title:'Carta Evento', description: 'Clique aqui para pegar uma carta evento durante o jogo.'),

    //MarketScreen Itens
    searchPropertyByName(title:'Buscar Propriedade', description: 'Digite o nome da propriedade para encontrá-la rapidamente na lista abaixo.'),
    propertyListView(title:'Lista de propriedades à venda', description: 'Aqui você verá todas as propriedades (ações) disponíveis para compra no mercado.\nNo quadro da propriedade você poderá ver detalhes e realizar a compra.'),
    
    //MyPortfolioScreen Itens
    myPortfolioSummaryView(title:'Resumo de ganhos do Meu Portfólio', description: 'Aqui você verá um resumo dos lucros obtidos com suas propriedades (ações).'),
    myPortfolioListView(title:'Lista do Meu Portfólio', description: 'Aqui você verá todas as propriedades (ações) que você possui.\nNo quadro da propriedade você poderá ver detalhes e realizar ações como vender ou construir casas.');
    
    final String title;
    final String description;
    const TutorialItemType({required this.title, required this.description});
    
}