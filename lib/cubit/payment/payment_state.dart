part of 'payment_cubit.dart';

@immutable
sealed class PaymentState {}

final class PaymentInitial extends PaymentState {}
final class PaymentLoading extends PaymentState {}
final class PaymentSuccess extends PaymentState {}
final class PaymentFail extends PaymentState {}
final class PaymentKeyLoading extends PaymentState {}
final class PaymentKeySuccess extends PaymentState {
  final String paymentKey;
  PaymentKeySuccess(this.paymentKey);
}
final class PaymentKeyFail extends PaymentState {}
