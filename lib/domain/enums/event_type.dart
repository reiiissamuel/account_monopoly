enum EventType{
  propertyUpdatePayout(messageScope: "{SOURCE} atualizou o payout de {PROPERTY}"),
  transfer(messageScope: '{SOURCE} transferiu {PRICE} para {DEST}.'),
  payBank(messageScope: '{SOURCE} pagou {PRICE} para o banco.'),
  receiveFromBank(messageScope: '{SOURCE} recebeu {PRICE} do banco.'),
  buyFromIPO(messageScope: '{SOURCE} comprou {QUANTITY} ações de {PROPERTY}.'),
  buyFromTrade(messageScope: '{SOURCE} comprou a oferta {TRADEOFFER}.'),
  build(messageScope: 'A holding {SOURCE} concluiu construções em {PROPERTY} no valor {PRICE}.'),
  setTradeOffer(messageScope: 'Nova oferta no mercado: {TRADEOFFER} lançada por {SOURCE}.'),
  removeTradeOffer(messageScope: "Uma proposta de venda de {SOURCE} foi removida."),
  payRent(messageScope: '{SOURCE} pagou {PRICE} de aluguel em {PROPERTY}.'),
  payTax(messageScope: '{SOURCE} pagou {PRICE} de imposto de renda.'),
  receiveTax(messageScope: '{SOURCE} recebeu {PRICE} de restituição.'),
  loan(messageScope: '{SOURCE} pegou um empréstimo no valor de {PRICE}.'),
  loanPayment(messageScope: '{SOURCE} pagou {PRICE} referente a um emprestimo com o banco.'),
  mortgageForeclosure(messageScope: 'O banco executou a hipoteca das ações de {PROPERTY} pertencentes a {SOURCE}.'),
  loanForeclosure(messageScope: 'O banco executou uma dívida de {PRICE} da {SOURCE}.'),
  roundBonus(messageScope: "{SOURCE} recebeu novos investimentos totalizados em {PRICE}."),
  bankBlacklisted(messageScope: "{SOURCE} entrou para a lista de devedores do banco."),
  dividendsCalculation(messageScope: "Sua empresa recebeu {PRICE} em dividendos referente a rodada {ROUND}."),
  bankruptcy(messageScope: '{SOURCE} declarou falência'),
  iwon(messageScope: '{SOURCE} venceu o jogo.'),
  lostConnection(messageScope: '{SOURCE} está desconectado.'),
  joinTable(messageScope: '{SOURCE} juntou-se ao jogo.'),
  serverHandShake(messageScope: "recebendo nova conexão"),
  CHANCE_USED(messageScope: "{SOURCE}  usou um benefício.");

  final String? messageScope;

  const EventType({required this.messageScope});
}