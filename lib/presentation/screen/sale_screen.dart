import 'package:flutter/material.dart';
import 'package:salesforce/presentation/state/sale_screen_state.dart';

class SaleScreen extends StatelessWidget {
  SaleScreen({super.key});

  final SaleScreenState _state = SaleScreenState();

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () => _state.handleBtnClick(),
      child: Text('Sales!', style: TextStyle(color: Colors.black)),
    );
  }
}
