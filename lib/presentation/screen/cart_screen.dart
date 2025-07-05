import 'package:flutter/material.dart';
import 'package:salesforce/presentation/state/cart_screen_state.dart';
import 'package:salesforce/presentation/widget/cart_screen/cart_item_widget.dart';
import 'package:salesforce/presentation/widget/cart_screen/cart_screen_resume_widget.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final CartScreenState _state = CartScreenState();

  @override
  void initState() {
    _state.addListener(updateState);
    super.initState();
  }

  @override
  void dispose() {
    _state.removeListener(updateState);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(height: MediaQuery.of(context).size.height * 0.07),
        Center(
          child: Text(
            "Meu Carrinho",
            style: Theme.of(context).textTheme.headlineMedium,
          ),
        ),
        Divider(
          thickness: 2,
          endIndent: MediaQuery.of(context).size.width * 0.05,
          indent: MediaQuery.of(context).size.width * 0.05,
        ),
        Expanded(
          child: ListView.builder(
            padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.04),
            itemCount: _state.products.length,
            itemBuilder:
                (context, i) => CartItemWidget(prod: _state.products[i]),
          ),
        ),
        CartScreenResumeWidget(totalPrice: _state.totalPrice),
      ],
    );
  }

  void updateState() {
    setState(() {});
  }
}
