/// Sealed class hierarchy for domain-level failures.
/// Use these in repository results instead of throwing raw exceptions.
sealed class Failure {
  const Failure(this.message);
  final String message;
}

/// Failure originating from local data operations.
final class DataFailure extends Failure {
  const DataFailure(super.message);
}

/// Failure originating from a network/HTTP call.
final class NetworkFailure extends Failure {
  const NetworkFailure(super.message);
}
