class GameNotExistsException implements Exception {

  final String message;
  
  GameNotExistsException([this.message = "Jogo não encontrado."]);

  @override
  String toString() => message;

}