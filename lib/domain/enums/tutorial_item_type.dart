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
    goPlayersButton(title:'Transferir', description: 'Clique aqui sempre que precisar transferir dinheiro para outros jogadores.'),
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
    myPortfolioListView(title:'Lista do Meu Portfólio', description: 'Aqui você verá todas as propriedades (ações) que você possui.\nNo quadro da propriedade você poderá ver detalhes e realizar ações como vender ou construir casas.'),
    
    //PlayersScreen Itens
    playerListView(title:'Lista de Jogadores', description: 'Aqui você verá todos os jogadores do jogo e poderá, ao clicar no card, transferir dinheiro para eles.'),
    
    //PayRentDialog Itens
    payRentDialogList(title:'Pague seus aluguéis por aqui', description: 'Selecione nesta lista a propriedade para a qual deseja pagar o aluguel.'),
    valueRentViewer(
     title:'Aluguel a Pagar',
     description: """Aqui será mostrado o valor atual do aluguel que você deverá pagar.
    \nLembre-se que nesta versão de bolsa de valores, os alugueis sofrem variações constantes com base nos lucros das propriedades e construções nela presentes."""),
    valueRentMultiplier(title:'Multiplicador do Aluguel', description: '''As propriedades do tipo companhias tem suporte de multiplicador com base no valor dos dados (regra válida na maior parte das versões de banco imobiliario).
    \nSelecione o multiplicador com base no valor dos dados.'''),

    //MyFinancialScreen Itens
    actionsRedirectsSession(title:'Ações', description: 'Nesta seção você poderá ir para tela do seu portfólio, ou ir para tela de transferências ou ainda acessar seus gráficos detalhados'),
    totalBalanceSession(title:'Total Entradas e Saídas', description: 'Aqui você verá o total de entradas e saídas financeiras em toda a sua trajetória no jogo.'),
    taxesSession(title:'Impostos', description: 'Na seção imposto você tem acesso ao total de imposto de renda que deverá pagar, bem como o total de restituição disponível referente ao último pagamento de imposto de renda.\n\nVolte para principal, clique no icone "Mais" para selecionar as opções de pagamento de imposto de renda e solicitação de restituição.'),
    activeLoansSession(title:'Empréstimos Ativos', description: 'Aqui você verá todos os empréstimos ativos que você e também poderá gerenciar seus pagamentos.'),

    //MoreOptionsDialog Itens
    payTaxesOption(title:'Pague seus impostos', description: 'Clique nesta opção sempre que for solicitado a pagar o imposto de renda.'),
    requestTaxRefundOption(title:'Solicite restituição de impostos', description: 'Clique aqui quando for solicitado a receber sua restituição de imposto, ou logo após ter pago o seu imposto de renda.'),
    requestPaymentOption(title:'Solicite Pagamento', description: 'Clique nesta opção sempre que o jogo lhe direcionar a receber algum pagamento.\nComo em cartas chance, sorte, sorte ou revés...'),
    payToBankOption(title:'Pague ao Banco', description: 'Clique nesta opção sempre que o jogo lhe direcionar a realizar um pagamento ao banco.\nComo em cartas chance, sorte, sorte ou revés...'),
    requestRoundBonusOption(title:'Solicite Bônus de Rodada', description: 'Clique aqui toda vez que você completar uma volta no tabuleiro.'),
    goToMyBenefitsOption(title:'Meus Benefícios', description: 'Clique aqui para ver seus benefícios ativos'),

    //PropertyDetailScreen Itens
    buildingButton(title:'Botão Construir Casa', description: 'Clique neste botão para construir uma casa na propriedade selecionada. Esta opção só estará habilitada nas propriedades que sejam terrenos e apenas se você for o jogador com o maior número de ações disponíveis desta propriedade.'),
    sharesCurrentPriceCard(title:'Preço atual da ações', description: 'Aqui você também verá o preço atual das ações da propriedade selecionada.'),
    marketStatusCard(title:'Status do Mercado', description: 'Este card apresenta um detalhamento de informações de construções, valores e custo da propriedade selecionada.'),
    rentabilyMarkerCard(title:'Marcador de Rentabilidade', description: 'Aqui você terá informações atualizadas sobre a rentabilidade da propriedade selecionada.'),
    hystoricalSharePriceCard(title:'Histórico de Preço das Ações', description: 'Aqui você pode ver o histórico de preço das ações da propriedade ao longo das rodadas.'),
    payoutEditorCard(title:'Editor de porcentagem de Pagamentos', description: 'Aqui você poderá editar a porcentagem dos lucros que serão distribuídos aos jogadores que possuem ações da propriedade selecionada.\nOBS.: Essa edição só poderá ser feita pelo jogador com a maior quantidade de ações disponíveis da propriedade.'),

    //LoanDialog Itens
    selectLoanTypeDropdown(title:'Tipo de Empréstimo', description: 'Você selecionar entre dois tipos de empréstimos:\nUm oferecendo as ações de uma propriedade a sua escolha como garantia e o outro da como garantia o seu bonus da rodada.'),
    availableLoanValue(title:'Valor Disponível do Empréstimo', description: 'Com base nas opções de empréstimo selecionadas, aqui você verá o valor disponível para o empréstimo.'),
    totalValueToPay(title:'Valor Total a Pagar', description: 'Aqui você verá o valor total que precisará pagar referente ao empréstimo selecionado.');
    
    final String title;
    final String description;
    const TutorialItemType({required this.title, required this.description});
    
}