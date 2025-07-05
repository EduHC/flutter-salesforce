import 'package:flutter/material.dart';
import 'package:salesforce/globals.dart';
import 'package:salesforce/module/service/cart_service.dart';
import 'package:salesforce/presentation/state/product_screen_state.dart';

class HeaderWidget extends StatefulWidget {
  const HeaderWidget({super.key});

  @override
  State<HeaderWidget> createState() => _HeaderWidgetState();
}

class _HeaderWidgetState extends State<HeaderWidget> {
  final ProductScreenState _state = ProductScreenState();
  final CartService _cartService = CartService();
  final Globals globals = Globals();
  late FocusNode _focusNode;

  @override
  void initState() {
    _focusNode = FocusNode();
    super.initState();
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: MediaQuery.of(context).size.width * 0.05,
          vertical: MediaQuery.of(context).size.height * 0.02,
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Melchior Kalinor",
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    Text(
                      "PR, Brazil",
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
                ValueListenableBuilder(
                  valueListenable: _cartService.productsQuantity,
                  builder: (context, value, child) {
                    if (value == 0) return Container();

                    return Text(
                      "$value itens",
                      style: Theme.of(context).textTheme.bodySmall,
                    );
                  },
                ),
                IconButton(
                  onPressed: () {
                    globals.tabController.jumpToTab(2);
                  },
                  icon: Icon(
                    size: MediaQuery.of(context).devicePixelRatio * 15,
                    Icons.shopping_bag_outlined,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
            SizedBox(height: MediaQuery.of(context).size.height * 0.015),
            TextField(
              controller: _state.txtController,
              focusNode: _focusNode,
              onChanged: (value) => _state.setFilterValue(filter: value),
              onSubmitted: (value) {
                if (globals.tabController.index == 1) return;
                globals.tabController.jumpToTab(1);
              },
              decoration: InputDecoration(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.06,
                  minHeight: MediaQuery.of(context).size.height * 0.05,
                  maxWidth: MediaQuery.of(context).size.width * 0.9,
                  minWidth: MediaQuery.of(context).size.width * 0.6,
                ),
                hintText: "Search",
                hintStyle: Theme.of(context).textTheme.bodySmall,
                prefixIcon: Icon(
                  Icons.search,
                  size: MediaQuery.of(context).size.height * 0.04,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: -1),
                filled: true,
                fillColor: Colors.grey[200],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(
                    MediaQuery.of(context).size.height * 0.02,
                  ),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
