abstract final class ConfigsConstants {
  // Construtor privado impede que a classe seja instanciada por engano
  ConfigsConstants._();

  static const String notEnoughCreditErrorMsg = "Você não possui credito suficiente.";
  static const String notEnoughReserveErrorMsg = "A propriedade não tem capital suficiente para opiar esta operação";
  static const String blackListErrorMsg = "O banco não autorizou essa operação. Cheque se tem dívidas vencidas";
  static const String mortgagedPropertyErrorMsg = "Suas ações desta propriedade ja estão hipotecadas.";
  static const String notEnoughSharesToTradeErrorMsg = "Você não tem ações disponíveis para criar esta oferta";
  
  // CORREÇÃO: Mudado de 'static final' para 'static const'
  static const String newUserSuccessMsg = "Cadastro concluído: ";
  static const String newUserErrorMsg = "Falha ao cadastrar usuário!";
  static const String userExistsErrorMsg = "Este nome de usuário ja está sendo usado";
  
  // Regras de negócio
  static const double initialPayout = 0.5;
  static const int maxBuildings = 5;
  static const String maxBuildingsErrorMsg = "Você não pode passar o limite de construções da propriedade";
  static const int maxBonnusLoans = 1;
  static const String maxBonnusLoansErrorMsg = "O limite de empréstimos simultâneos nessa modalidade foi atingindo";
  static const int defaultPrimaryColorValue = 0xFF5f7887;
}
