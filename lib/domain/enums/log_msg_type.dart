enum LogMsgType{
  TRANSFER(messageScope: '{SOURCE} transferiu {VALUE} para {DEST}.'),
  PAY_BANK(messageScope: '{SOURCE} pagou {VALUE} para o banco.'),
  RECEIVE_FROM_BANK(messageScope: '{SOURCE} recebeu {VALUE} do banco.'),
  BUY(messageScope: '{SOURCE} comprou uma propriedade no valor de {VALUE}.'),
  BUILD_HOUSE(messageScope: '{SOURCE} construiu uma casa avaliada em {VALUE}.'),
  BUILD_HOTEL(messageScope: '{SOURCE} construiu um hotal avaliada em {VALUE}.'),
  LOAN(messageScope: '{SOURCE} pegou um empréstimo no valor de {VALUE}.'),
  MORTGAGE(messageScope: '{SOURCE} recebeu {VALUE} através de uma hipoteca.'),
  BANKRUPTCY(messageScope: '{SOURCE} declarou falência'),
  AUCTION_START(messageScope: '{SOURCE} iniciou um leilão de uma propriedade com lance mínimo de {VALUE}.'),
  AUCTION_RAISE(messageScope: '{SOURCE} aumenta o lance.'),
  AUCTION_PAY(messageScope: '{SOURCE} da o lance inicial.'),
  AUCTION_LEAVE(messageScope: '{SOURCE} desistiu do leilão.'),
  AUCTION_END(messageScope: '{SOURCE} comprou a propriedade pelo valor de {VALUE}.'),
  IWON(messageScope: '{SOURCE} venceu o jogo.'),
  LOST_CONNECTION(messageScope: '{SOURCE} está desconectado.'),
  JOIN_TABLE(messageScope: '{SOURCE} juntou-se ao jogo.'),
  SERVER_HAND_SHAKE(messageScope: null),
  CLOSE_TURN(messageScope: "{SOURCE} fechou o faturamento da rodada em {VALUE}."),
  CHANCE_USED(messageScope: "{SOURCE}  usou um benefício."),
  ROUND_BONUS(messageScope: "{SOURCE} recebeu um bonus de {VALUE}."),
  CURRENT_ACCOUNT_UPDATE_UP(messageScope: '{SOURCE} recebeu {VALUE} em crédito.'),
  CURRENT_ACCOUNT_UPDATE_DOWN(messageScope: '{SOURCE} pagou {VALUE} para o banco.');

  final String? messageScope;

  const LogMsgType({required this.messageScope});
}