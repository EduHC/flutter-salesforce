import 'package:flutter/material.dart';
import 'package:salesforce/domain/model/product.dart';
import 'package:salesforce/presentation/screen/product_details_screen.dart';
import 'package:salesforce/presentation/state/product_screen_state.dart';
import 'package:salesforce/presentation/widget/header_widget.dart';
import "package:persistent_bottom_nav_bar_v2/persistent_bottom_nav_bar_v2.dart";

class ProductScreenBodyWidget extends StatelessWidget {
  final List<Product> products;
  final ProductScreenState _state = ProductScreenState();

  ProductScreenBodyWidget({super.key, required this.products});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      children: [
        HeaderWidget(),
        SizedBox(height: MediaQuery.of(context).size.height * 0.01),

        if (products.isEmpty)
          Expanded(
            child: Center(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: MediaQuery.of(context).size.width * 0.04,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.shopping_cart_outlined,
                      size: MediaQuery.of(context).size.width * 0.2,
                      color: Colors.grey[400],
                    ),
                    SizedBox(height: MediaQuery.of(context).size.height * 0.03),
                    Text(
                      "Nenhum Produto Disponível",
                      style: textTheme.headlineSmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          )
        else
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.blueGrey[50],
                boxShadow: [
                  BoxShadow(
                    // offset: Offset(-1, -1),
                    color: Colors.black26,
                    spreadRadius: 1,
                    blurRadius: 3,
                    blurStyle: BlurStyle.normal,
                  ),
                ],
                borderRadius: BorderRadiusGeometry.directional(
                  topEnd: Radius.elliptical(
                    MediaQuery.of(context).size.width * 0.04,
                    MediaQuery.of(context).size.width * 0.04,
                  ),
                  topStart: Radius.elliptical(
                    MediaQuery.of(context).size.width * 0.04,
                    MediaQuery.of(context).size.width * 0.04,
                  ),
                ),
              ),
              child: _buildList(context),
            ),
          ),
      ],
    );
  }

  ListView _buildList(BuildContext context) {
    return ListView.builder(
      padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.03),
      itemCount: products.length,
      itemBuilder: (context, index) {
        final prod = products[index];
        precacheImage(NetworkImage(prod.img), context);
        final Image img = Image.network(
          prod.img,
          cacheHeight: (100 * MediaQuery.of(context).devicePixelRatio).toInt(),
          width: MediaQuery.of(context).size.width * 0.20,
          height: MediaQuery.of(context).size.height * 0.15,
          fit: BoxFit.cover,
          errorBuilder:
              (ctx, e, st) => Container(
                color: Colors.grey.shade200,
                width: MediaQuery.of(context).size.width * 0.20,
                height: MediaQuery.of(context).size.height * 0.15,
                child: Icon(
                  Icons.broken_image,
                  size: MediaQuery.of(context).size.height * 0.15,
                  color: Colors.grey,
                ),
              ),
        );

        return Card(
          clipBehavior: Clip.antiAlias,
          elevation: 5,
          margin: EdgeInsets.symmetric(
            vertical: MediaQuery.of(context).size.height * 0.01,
            horizontal: MediaQuery.of(context).size.width * 0.01,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              MediaQuery.of(context).size.height * 0.02,
            ),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(
              MediaQuery.of(context).size.height * 0.02,
            ),
            onTap:
                () => pushScreenWithoutNavBar(
                  context,
                  ProductDetail(product: prod, img: NetworkImage(prod.img)),
                ),
            child: Padding(
              padding: EdgeInsets.all(
                MediaQuery.of(context).size.height * 0.02,
              ),
              child: Row(
                children: [
                  ClipRRect(borderRadius: BorderRadius.circular(8), child: img),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          prod.name,
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          prod.description,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.displaySmall,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'R\$ ${prod.price.toStringAsFixed(2)}',
                          style: Theme.of(context).textTheme.displayMedium,
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      IconButton(
                        onPressed:
                            () => _state.handleFavotireButtonClick(prod: prod),
                        icon: Icon(
                          Icons.favorite,
                          color: prod.favorite ? Colors.red : Colors.grey,
                        ),
                      ),
                      SizedBox(height: 4),
                      IconButton(
                        onPressed:
                            () => _state.handleAddTocartButtonClick(prod: prod),
                        icon: Icon(
                          Icons.add_shopping_cart,
                          color: Colors.green[700],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
