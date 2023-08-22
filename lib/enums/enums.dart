enum LogMsgType{
  TRANSFER(messageScope: '{SOURCE} transferiu {VALUE} para {DEST}.'),
  PAY_BANK(messageScope: '{SOURCE} pagou {VALUE} para o banco.'),
  RECEIVE_FROM_BANK(messageScope: '{SOURCE} recebeu {VALUE} do banco.'),
  BUY(messageScope: '{SOURCE} comprou uma propriedade no valor de {VALUE}.'),
  BUILD_HOUSE(messageScope: '{SOURCE} construiu uma casa avaliada em {VALUE}.'),
  BUILD_HOTEL(messageScope: '{SOURCE} construiu um hotal avaliada em {VALUE}.'),
  LOAN(messageScope: '{SOURCE} pegou um empréstimo no valor de {VALUE}.'),
  HIPOTECA(messageScope: '{SOURCE} recebeu {VALUE} através de uma hipoteca.'),
  BANKRUPTCY(messageScope: '{SOURCE} declarou falência'),
  AUCTION_START(messageScope: '{SOURCE} iniciou um leilão de uma propriedade com lance mínimo de {VALUE}.'),
  AUCTION_RAISE(messageScope: null),
  AUCTION_PAY(messageScope: null),
  AUCTION_END(messageScope: '{SOURCE} comprou a propriedade pelo valor de {VALUE}.'),
  IWON(messageScope: '{SOURCE} venceu o jogo.'),
  LOST_CONNECTION(messageScope: '{SOURCE} está desconectado.'),
  JOIN_TABLE(messageScope: '{SOURCE} juntou-se ao jogo.'),
  SERVER_HAND_SHAKE(messageScope: null);

  final String? messageScope;

  const LogMsgType({required this.messageScope});
}