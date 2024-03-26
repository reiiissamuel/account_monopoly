class PeerUnavailableException implements Exception {

  static const String PEER_UNAVAILABLE_ERROR_MSG = "Problema na conexão. Assegure-se ter digitado o código no correto ou de que o jogador host ter iniciado a sala.";
  PeerUnavailableException(PEER_UNAVAILABLE_ERROR_MSG);
}