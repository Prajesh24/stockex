
import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  final String message;
  const Failure(this.message);

  @override
  List<Object?> get props => [message];
}

//Local Database Failure
class LocalDatabaseFailue extends Failure {
  const LocalDatabaseFailue({
    String message = 'Local database operation failed',
  }) : super(message);
}

//Api Failure with status code
class ServerFailure extends Failure {
  final int? statusCode;

  const ServerFailure({required String message, this.statusCode}) : super(message);

  @override
  List<Object?> get props => [message, statusCode];
}
