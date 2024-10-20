import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:xride/app_router.dart';
import 'package:xride/cubit/payment/payment_cubit.dart';

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({super.key});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  final TextEditingController amountController = TextEditingController();
  bool isLoading = false;

  void onNavigate(String url) {
    Navigator.pushNamed(context, AppRouter.paymentWebScreen, arguments: url);
  }

  void payAmount() {
    final String amountText = amountController.text;
    final int? amount = int.tryParse(amountText);

    if (amount != null && amount > 0) {
      context.read<PaymentCubit>().pay(amount, onNavigate);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid amount')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: !isLoading,
          title: const Text('Balance Recharge'),
        ),
        body: BlocListener<PaymentCubit, PaymentState>(
          listener: (context, state) {
            if (state is PaymentkeyLoading) {
              setState(() {
                isLoading = true;
              });
            } else {
              setState(() {
                isLoading = false;
              });
            }
          },
          child: BlocBuilder<PaymentCubit, PaymentState>(
            builder: (context, state) {
              return PopScope(
                canPop: !isLoading,
                child: Center(
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                        Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: TextField(
                          controller: amountController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Enter Payment Amount',
                          ),
                        ),
                        ),
                      const SizedBox(height: 20),
                      (isLoading)
                          ? const CircularProgressIndicator()
                          : (ElevatedButton(
                              onPressed: payAmount,
                              child: const Text('Proceed to Payment'),
                            )),
                    ])),
              );
            },
          ),
        ));
  }
}
