import 'package:flutter/material.dart';
import 'package:salesforce/domain/model/product.dart';
import 'package:salesforce/presentation/state/cart_screen_state.dart';

class CartItemWidget extends StatelessWidget {
  final Product prod;

  CartItemWidget({super.key, required this.prod});

  final CartScreenState _state = CartScreenState();
  final Color primary = Color(0xFF6A5AE0);
  final Color cardBg = Colors.white;
  final Color accent = Color(0xFFEDEBFF);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 80,
              height: 80,
              margin: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: accent,
                borderRadius: BorderRadius.circular(10),
                image: DecorationImage(
                  image: NetworkImage(prod.img),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    prod.name,
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  SizedBox(height: 4),
                  Text(
                    'R\$ ${prod.price}',
                    style: Theme.of(context).textTheme.displayMedium,
                  ),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      _QtyButton(
                        icon: Icons.remove,
                        onTap: () => _state.handleMinusBtnClick(prod: prod),
                      ),
                      SizedBox(width: 8),
                      Text(
                        '${_state.getProductQuantity(id: prod.id!)}',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(width: 8),
                      _QtyButton(
                        icon: Icons.add,
                        onTap: () => _state.handleAddBtnClick(prod: prod),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            IconButton(
              icon: Icon(Icons.delete_outline, color: primary),
              onPressed: () => _state.handleRemoveBtnClick(prod: prod),
            ),
          ],
        ),
      ),
    );
  }
}

class _QtyButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _QtyButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: Color(0xFFEDEBFF),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: 20, color: Color(0xFF6A5AE0)),
      ),
    );
  }
}
