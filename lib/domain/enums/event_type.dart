enum EventType{
  propertyUpdatePayout(messageScope: "{SOURCE} atualizou o payout de {PROPERTY}"),
  transfer(messageScope: '{SOURCE} transferiu {VALUE} para {DEST}.'),
  payBank(messageScope: '{SOURCE} pagou {VALUE} para o banco.'),
  receiveFromBank(messageScope: '{SOURCE} recebeu {VALUE} do banco.'),
  buyFromIPO(messageScope: '{SOURCE} comprou {VALUE} ações de {PROPERTY}.'),
  buyFromTrade(messageScope: '{SOURCE} comprou a oferta {TRADEOFFER}.'),
  build(messageScope: 'A holding {SOURCE} concluiu construções em {PROPERTY} no valor {VALUE}.'),
  setTradeOffer(messageScope: 'Nova oferta no mercado: {TRADEOFFER} lançada por {SOURCE}.'),
  payRent(messageScope: '{SOURCE} pagou {VALUE} de aluguel em {PROPERTY}.'),
  payTax(messageScope: '{SOURCE} pagou {VALUE} de imposto de renda.'),
  receiveTax(messageScope: '{SOURCE} recebeu {VALUE} de restituição.'),
  loan(messageScope: '{SOURCE} pegou um empréstimo no valor de {VALUE}.'),
  loanPayment(messageScope: '{SOURCE} pagou {VALUE} referente a um emprestimo com o banco.'),
  mortgageForeclosure(messageScope: 'O banco executou a hipoteca de {VALUE} ações de {PROPERTY} pertencentes a {SOURCE}.'),
  loanForeclosure(messageScope: 'O banco executou uma dívida de {VALUE} da {SOURCE}.'),
  closeTurn(messageScope: "{SOURCE} finalizou seu turno de negociações."),
  roundBonus(messageScope: "{SOURCE} recebeu novos investimentos totalizando {VALUE}."),
  bankBlacklisted(messageScope: "{SOURCE} entrou para a lista de devedores do banco."),
  closeRound(messageScope: "{SOURCE} recebeu {VALUE} em dividendos referente a rodada {ROUND}."),
  bankruptcy(messageScope: '{SOURCE} declarou falência'),
  iwon(messageScope: '{SOURCE} venceu o jogo.'),
  lostConnection(messageScope: '{SOURCE} está desconectado.'),
  joinTable(messageScope: '{SOURCE} juntou-se ao jogo.'),
  serverHandShake(messageScope: ""),
  CHANCE_USED(messageScope: "{SOURCE}  usou um benefício.");

  final String? messageScope;

  const EventType({required this.messageScope});
}