import 'package:flutter/material.dart';
import 'package:salesforce/presentation/state/product_screen_state.dart';
import 'package:salesforce/presentation/widget/product_screen/body_widget.dart';

class ProductScreen extends StatefulWidget {
  final bool isFavoriteOnly;

  const ProductScreen({super.key, this.isFavoriteOnly = false});

  @override
  State<StatefulWidget> createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> {
  final ProductScreenState _state = ProductScreenState();

  @override
  void initState() {
    super.initState();
    _state.addListener(_handleNotifyState);
  }

  @override
  void dispose() {
    super.dispose();
    _state.removeListener(_handleNotifyState);
  }

  @override
  Widget build(BuildContext context) {
    _state.doInitialLoadIfNeeded();

    return Scaffold(body: ProductScreenBodyWidget(products: _state.products));
  }

  void _handleNotifyState() => setState(() {});
}
