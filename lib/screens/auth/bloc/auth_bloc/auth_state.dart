import 'package:equatable/equatable.dart';
import 'package:hyper_local/config/helper.dart';

class AuthState extends Equatable {
  final ApiStatus status;
  final String message;
  final MobileANdEmailStatus mobileANdEmailStatus;

  const AuthState({
    this.status = ApiStatus.initial,
    this.message = '',
    this.mobileANdEmailStatus = MobileANdEmailStatus.initial,
  });

  AuthState copyWith({
    ApiStatus? status,
    String? message,
    bool clearMessage = false,
    MobileANdEmailStatus? mobileANdEmailStatus,
  }) {
    return AuthState(
      status: status ?? this.status,
      message: clearMessage ? '' : (message ?? this.message),
      mobileANdEmailStatus: mobileANdEmailStatus ?? this.mobileANdEmailStatus,
    );
  }

  @override
  List<Object?> get props => [status, message, mobileANdEmailStatus];
}
