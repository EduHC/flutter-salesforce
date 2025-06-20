import 'package:flutter/material.dart';
import 'package:salesforce/domain/model/product.dart';
import 'package:salesforce/presentation/widget/product_screen/star_rating_widget.dart';

class ProductDetail extends StatelessWidget {
  final Product product;
  final ImageProvider img;

  const ProductDetail({super.key, required this.product, required this.img});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SizedBox.expand(
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        clipBehavior: Clip.antiAlias,
        margin: EdgeInsets.symmetric(
          horizontal: MediaQuery.of(context).size.width * 0.01,
          vertical: MediaQuery.of(context).size.height * 0.01,
        ),
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Top image + price tag
                    Stack(
                      fit: StackFit.passthrough,
                      children: [
                        AspectRatio(
                          aspectRatio: 16 / 9,
                          child: Image(
                            image: img,
                            fit: BoxFit.cover,
                            errorBuilder:
                                (_, __, ___) => Center(
                                  child: Icon(
                                    Icons.broken_image,
                                    size:
                                        MediaQuery.of(context).size.height *
                                        0.1,
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                          ),
                        ),
                        Positioned(
                          bottom: MediaQuery.of(context).size.height * 0.01,
                          left: MediaQuery.of(context).size.width * 0.01,
                          child: Material(
                            color: Colors.green[700],
                            elevation: 5,
                            borderRadius: BorderRadius.circular(
                              MediaQuery.of(context).size.height * 0.02,
                            ),
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal:
                                    MediaQuery.of(context).size.width * 0.03,
                                vertical:
                                    MediaQuery.of(context).size.height * 0.01,
                              ),
                              child: Text(
                                'R\$ ${product.price.toStringAsFixed(2)}',
                                style: theme.textTheme.bodyLarge!.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: MediaQuery.of(context).size.height * 0.03),
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: MediaQuery.of(context).size.width * 0.04,
                      ),
                      child: Text(
                        product.name,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    SizedBox(height: MediaQuery.of(context).size.width * 0.03),
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: MediaQuery.of(context).size.width * 0.04,
                      ),
                      child: Text(
                        product.description,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Sticky bottom part
            Divider(
              height: 1,
              thickness: 1,
              color: theme.dividerColor,
              indent: MediaQuery.of(context).size.width * 0.04,
              endIndent: MediaQuery.of(context).size.width * 0.04,
            ),
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: MediaQuery.of(context).size.width * 0.04,
                vertical: MediaQuery.of(context).size.height * 0.02,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      StarRatingWidget(
                        rating: product.rating,
                        color: Colors.amber,
                        size: MediaQuery.of(context).size.width * 0.08,
                      ),
                      SizedBox(width: MediaQuery.of(context).size.width * 0.02),
                      Text(
                        product.rating.toStringAsFixed(1),
                        style: theme.textTheme.bodyLarge,
                      ),
                    ],
                  ),
                  IconButton(
                    onPressed: () {},
                    icon: Icon(Icons.add_shopping_cart, color: Colors.green),
                    iconSize: MediaQuery.of(context).size.width * 0.1,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
