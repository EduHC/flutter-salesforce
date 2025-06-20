import 'package:flutter/material.dart';
import 'package:salesforce/module/service/chart_service.dart';
import 'package:salesforce/presentation/state/product_screen_state.dart';

class BodyHeaderWidget extends StatelessWidget {
  BodyHeaderWidget({super.key});
  final ProductScreenState _state = ProductScreenState();
  final ChartService _chartService = ChartService();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: MediaQuery.of(context).size.width * 0.05,
          vertical: MediaQuery.of(context).size.height * 0.02,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  "Products List",
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const Spacer(),
                ValueListenableBuilder(
                  valueListenable: _chartService.productsQuantity,
                  builder: (context, value, child) {
                    if (value == 0) return Container();

                    return Text(
                      "$value itens",
                      style: Theme.of(context).textTheme.bodySmall,
                    );
                  },
                ),
                IconButton(
                  onPressed: () {},
                  icon: Icon(
                    size: MediaQuery.of(context).devicePixelRatio * 15,
                    Icons.shopping_bag_outlined,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
            TextField(
              onChanged: (value) => _state.setFilterValue(filter: value),
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
