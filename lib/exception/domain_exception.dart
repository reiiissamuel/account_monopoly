class DomainException implements Exception {
  final String message;
  DomainException(this.message);

  @override
  String toString() => message;
}

// 2. Exceções específicas para condições de falha
class MaxBuildingsException extends DomainException {
  MaxBuildingsException(super.message);
}

class NotEnoughCreditException extends DomainException {
  NotEnoughCreditException(super.message);
}

class MissValueException extends DomainException {
  MissValueException(super.message);
}

class NotEnoughMarkUPException extends DomainException {
  NotEnoughMarkUPException(super.message);
}