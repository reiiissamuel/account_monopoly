class GameAlreadyInPlayerListException implements Exception {
  static const String GAME_ALREADY_IN_PLAYER_LIST_MSG = "Este código é referente um jogo presente na sua lista...";
  GameAlreadyInPlayerListException(GAME_ALREADY_IN_PLAYER_LIST_MSG);
}