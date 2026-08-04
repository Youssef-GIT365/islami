import 'package:equatable/equatable.dart';

class ErrorMessage extends Equatable {
  final int statusCode;
  final String message;
  final bool success;

  const ErrorMessage({
    required this.statusCode,
    required this.message,
    required this.success,
  });

  factory ErrorMessage.fromJson(Map<String, dynamic> json) {
    return ErrorMessage(
      success: json["succes"],
      statusCode: json["status_code"],
      message: json["status_message"],
    );
  }

  @override
  List<Object?> get props => [statusCode, message, success];
}
