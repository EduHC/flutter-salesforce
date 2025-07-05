import 'package:flutter/material.dart';
import 'package:persistent_bottom_nav_bar_v2/persistent_bottom_nav_bar_v2.dart';
import 'package:salesforce/globals.dart';
import 'package:salesforce/presentation/screen/cart_screen.dart';
import 'package:salesforce/presentation/screen/home_screen.dart';
import 'package:salesforce/presentation/screen/product_screen.dart';
import 'package:salesforce/presentation/screen/sale_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final Globals globals = Globals();

  @override
  Widget build(BuildContext context) {
    return PersistentTabView(
      handleAndroidBackButtonPress: false,
      resizeToAvoidBottomInset: true,
      stateManagement: false,
      controller: globals.tabController,
      tabs: [
        PersistentTabConfig(
          screen: HomeScreen(),
          item: ItemConfig(icon: Icon(Icons.home), title: "Home"),
        ),
        PersistentTabConfig(
          screen: ProductScreen(),
          item: ItemConfig(icon: Icon(Icons.list), title: "Product List"),
        ),
        PersistentTabConfig(
          screen: CartScreen(),
          item: ItemConfig(
            icon: Icon(Icons.shopping_cart),
            title: "Shopping cart",
          ),
        ),
        PersistentTabConfig(
          screen: SaleScreen(),
          item: ItemConfig(icon: Icon(Icons.sell), title: "Sales"),
        ),
      ],
      navBarBuilder:
          (navBarConfig) => Style1BottomNavBar(navBarConfig: navBarConfig),
    );
  }
}
