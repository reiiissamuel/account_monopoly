class Balance {
  // ATRIBUTOS MUTÁVEIS (Acumuladores da Rodada)
  double sharePurchasesOut = 0.0;
  double shareSalesIn = 0.0;
  double eventIn = 0.0;
  double eventOut = 0.0;
  double buildingPurchasesOut = 0.0;
  double bonusIn = 0.0;
  double incomeTaxOut = 0.0;
  double refundIn = 0.0;
  double dividendsIn = 0.0;
  
  // Campos genéricos/transferências (Mantidos mutáveis e com nomes mais simples)
  double transferIn = 0.0;
  double transferOut = 0.0;
  double otherIn = 0.0; 
  double otherOut = 0.0; 

  // Construtor principal para desserialização (aceita todos os campos nomeados)
  Balance({
    this.sharePurchasesOut = 0.0,
    this.shareSalesIn = 0.0,
    this.eventIn = 0.0,
    this.eventOut = 0.0,
    this.buildingPurchasesOut = 0.0,
    this.bonusIn = 0.0,
    this.incomeTaxOut = 0.0,
    this.refundIn = 0.0,
    this.dividendsIn = 0.0,
    this.transferIn = 0.0,
    this.transferOut = 0.0,
    this.otherIn = 0.0,
    this.otherOut = 0.0,
  });

  // Construtor vazio (conveniente para inicializar no Player)
  Balance.empty();

  // GETTER: Entradas
  double get roundIncomes => 
      shareSalesIn +
      eventIn +
      refundIn +
      dividendsIn +
      transferIn +
      otherIn +
      bonusIn;

  // GETTER: Saídas
  double get roundOutcomes => 
      sharePurchasesOut +
      buildingPurchasesOut +
      incomeTaxOut +
      otherOut + 
      transferOut +
      eventOut;

  // GETTER: Fluxo de Caixa da Rodada
  double get roundFinalBalance => roundIncomes - roundOutcomes;

  // Adicionamos um método utilitário para "resetar" a rodada (chamado no fim do turno)
  Balance copyAndReset() {
    // Retorna uma cópia do Balanço atual (para ser armazenado no histórico)
    // E reseta o objeto atual do Player (Player.roundBalance) para 0
    
    var historicalRecord = Balance(
      sharePurchasesOut: sharePurchasesOut,
      shareSalesIn: shareSalesIn,
      eventIn: eventIn,
      eventOut: eventOut,
      bonusIn: bonusIn,
      incomeTaxOut: incomeTaxOut,
      refundIn: refundIn,
      dividendsIn: dividendsIn,
      transferIn: transferIn,
      transferOut: transferOut,
      otherIn: otherIn,
      otherOut: otherOut,
      buildingPurchasesOut: buildingPurchasesOut
    );
    
    // Zera o Balanço do Jogador
    sharePurchasesOut = shareSalesIn = eventIn = eventOut = 0.0;
    bonusIn = incomeTaxOut = refundIn = dividendsIn = 0.0;
    transferIn = transferOut = otherIn = otherOut = buildingPurchasesOut = 0.0;
    
    return historicalRecord;
  }
  
  // toMap e fromMap (ajustados para novos nomes de campos)
  Map<String, dynamic> toMap() {
    return {
      'sharePurchasesOut': sharePurchasesOut,
      'shareSalesIn': shareSalesIn,
      'eventIn': eventIn,
      'eventOut': eventOut,
      'bonusIn': bonusIn,
      'incomeTaxOut': incomeTaxOut,
      'refundIn': refundIn,
      'dividendsIn': dividendsIn,
      'transferIn': transferIn,
      'transferOut': transferOut,
      'otherIn': otherIn,
      'otherOut': otherOut,
      'buildingPurchasesOut': buildingPurchasesOut
    };
  }

  factory Balance.fromMap(Map<String, dynamic> map) {
    // Note: Usando map['key'] as double? ?? 0.0 para desserialização segura
    return Balance(
      sharePurchasesOut: map['sharePurchasesOut'] as double? ?? 0.0,
      shareSalesIn: map['shareSalesIn'] as double? ?? 0.0,
      eventIn: map['eventIn'] as double? ?? 0.0,
      eventOut: map['eventOut'] as double? ?? 0.0,
      bonusIn: map['bonusIn'] as double? ?? 0.0,
      incomeTaxOut: map['incomeTaxOut'] as double? ?? 0.0,
      refundIn: map['refundIn'] as double? ?? 0.0,
      dividendsIn: map['dividendsIn'] as double? ?? 0.0,
      transferIn: map['transferIn'] as double? ?? 0.0,
      transferOut: map['transferOut'] as double? ?? 0.0,
      otherIn: map['otherIn'] as double? ?? 0.0,
      otherOut: map['otherOut'] as double? ?? 0.0,
      buildingPurchasesOut: map['buildingPurchasesOut'] as double? ?? 0.0
    );
  }
}