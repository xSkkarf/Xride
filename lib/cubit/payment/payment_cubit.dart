import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:xride/services/payment_service.dart';

part 'payment_state.dart';

class PaymentWebArgs {
  final String paymentUrl;
  Function(String) paymentStatusCallBack;

  PaymentWebArgs(this.paymentUrl, this.paymentStatusCallBack);
}

class PaymentCubit extends Cubit<PaymentState> {
  final PaymentService paymentService;
  PaymentCubit(this.paymentService) : super(PaymentInitial());

  Future<void> pay(int amount, Function(PaymentWebArgs) onNavigate) async {
    try {
      emit(PaymentLoading());
      
      String paymentKey = await getPaymentKey(amount);

      PaymentWebArgs args = PaymentWebArgs("https://accept.paymob.com/api/acceptance/iframes/874350?payment_token=$paymentKey",
        (status) {
          if (status == "success") {
            emit(PaymentSuccess());
          } else {
            emit(PaymentFail());
          }
        }
      );

      onNavigate(args);

      // emit(PaymentSuccess());

    } catch (e) {
      emit(PaymentFail());
    }
  }

  Future<String> getPaymentKey(int amount) async {
    try {
        emit(PaymentKeyLoading());
        String paymentKey = await paymentService.getPaymentKey(amount, "EGP");
        emit(PaymentKeySuccess(paymentKey));
        return paymentKey;
      } catch (e) {
        emit(PaymentKeyFail());
        throw Exception();
      }
  }
}