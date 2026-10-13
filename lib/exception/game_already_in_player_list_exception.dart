class GameAlreadyInPlayerListException implements Exception {
  final String message;
  
  GameAlreadyInPlayerListException([this.message = "Este código refere-se a um jogo já presente na sua lista."]);

  @override
  String toString() => message;
}