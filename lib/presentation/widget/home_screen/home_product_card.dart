import 'package:flutter/material.dart';
import 'package:salesforce/domain/model/product.dart';
import 'package:persistent_bottom_nav_bar_v2/persistent_bottom_nav_bar_v2.dart';
import 'package:salesforce/presentation/screen/product_details_screen.dart';

class HomeProductCard extends StatelessWidget {
  final Product product;

  const HomeProductCard({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    precacheImage(NetworkImage(product.img), context);

    return GestureDetector(
      onTap:
          () => pushScreenWithoutNavBar(
            context,
            ProductDetail(product: product, img: NetworkImage(product.img)),
          ),
      child: AnimatedContainer(
        duration: Duration(milliseconds: 300),
        width: 160,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 6,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                child: Image(
                  image: NetworkImage(product.img),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(8),
              child: Text(
                product.name,
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                "R\$ ${product.price}",
                style: TextStyle(color: Colors.green[700]),
              ),
            ),
            SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
