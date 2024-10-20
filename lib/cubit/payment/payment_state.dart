part of 'payment_cubit.dart';

@immutable
sealed class PaymentState {}

final class PaymentInitial extends PaymentState {}
final class PaymentLoading extends PaymentState {}
final class PaymentSuccess extends PaymentState {}
final class PaymentFail extends PaymentState {}
final class PaymentkeyLoading extends PaymentState {}
final class PaymentkeySuccess extends PaymentState {
  final String paymentKey;
  PaymentkeySuccess(this.paymentKey);
}
final class PaymentkeyFail extends PaymentState {}
