enum OfferSource {
  fundIPO(description: "Oferta da propriedade"),        // Novo: Oferta do Fundo/Propriedade (ações disponíveis)
  bankForeclosed(description: "Lote - Ativos do banco"), // Novo: Ações recuperadas pelo Banco (bankPortfolio)
  playerMarket(description: "Lote - Oferta de player");// Existente: Ofertas de jogadores (P2P)

  final String description;

  const OfferSource({required this.description});
}