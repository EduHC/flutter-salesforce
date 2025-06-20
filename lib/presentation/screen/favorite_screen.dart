import 'package:flutter/material.dart';
import 'package:salesforce/presentation/state/favorite_screen_state.dart';
import 'package:salesforce/presentation/widget/product_screen/body_widget.dart';

class FavoriteScreen extends StatefulWidget {
  const FavoriteScreen({super.key});

  @override
  State<StatefulWidget> createState() => _FavoriteScreenState();
}

class _FavoriteScreenState extends State<FavoriteScreen> {
  final FavoriteScreenState _state = FavoriteScreenState();

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
