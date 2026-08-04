import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  final String Message;

  Failure(this.Message);

  List<Object?> get props => [Message];
}

class serverFailure extends Failure {
  serverFailure(super.Message);
}

class DataBaseFailure extends Failure {
  DataBaseFailure(super.Message);
}