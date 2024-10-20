import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:xride/services/payment_service.dart';

part 'payment_state.dart';

class PaymentCubit extends Cubit<PaymentState> {
  final PaymentService paymentService;
  PaymentCubit(this.paymentService) : super(PaymentInitial());

  Future<void> pay(int amount, Function(String) onNavigate) async {
    try {
      emit(PaymentLoading());
      
      String paymentKey = await getPaymentKey(amount);

      onNavigate("https://accept.paymob.com/api/acceptance/iframes/874350?payment_token=$paymentKey");

    } catch (e) {
      emit(PaymentFail());
    }
  }

  Future<String> getPaymentKey(int amount) async {
    try {
        emit(PaymentkeyLoading());
        String paymentKey = await paymentService.getPaymentKey(amount, "EGP");
        emit(PaymentkeySuccess(paymentKey));
        return paymentKey;
      } catch (e) {
        emit(PaymentkeyFail());
        throw Exception();
      }
  }
}