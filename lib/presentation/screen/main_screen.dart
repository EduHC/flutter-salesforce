import 'package:flutter/material.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
import 'package:salesforce/presentation/screen/chart_screen.dart';
import 'package:salesforce/presentation/screen/favorite_screen.dart';
import 'package:salesforce/presentation/screen/product_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final PersistentTabController _controller = PersistentTabController(
    initialIndex: 0,
  );

  static const List<Widget> _screens = [
    ProductScreen(),
    FavoriteScreen(),
    ChartScreen(),
    ChartScreen(),
  ];

  final RouteAndNavigatorSettings _navSettings = RouteAndNavigatorSettings(
    initialRoute: "/",
    routes: {
      "/": (final context) => const ProductScreen(),
      "/favorites": (final context) => const FavoriteScreen(),
    },
  );

  @override
  Widget build(BuildContext context) {
    return PersistentTabView(
      context,
      screens: _screens,
      handleAndroidBackButtonPress: false,
      neumorphicProperties: NeumorphicProperties(
        border: Border.all(width: 0.1),
      ),
      resizeToAvoidBottomInset: true,
      stateManagement: false,
      controller: _controller,
      hideNavigationBarWhenKeyboardAppears: true,
      popBehaviorOnSelectedNavBarItemPress: PopBehavior.all,
      isVisible: true,
      confineToSafeArea: true,
      navBarHeight: kBottomNavigationBarHeight,
      items: [
        PersistentBottomNavBarItem(
          icon: Icon(Icons.list),
          title: "Product List",
          activeColorPrimary: Colors.green,
          inactiveColorPrimary: Colors.blueGrey,
          routeAndNavigatorSettings: _navSettings,
        ),
        PersistentBottomNavBarItem(
          icon: Icon(Icons.favorite),
          title: "Favorites",
          activeColorPrimary: Colors.green,
          inactiveColorPrimary: Colors.blueGrey,
          routeAndNavigatorSettings: _navSettings,
        ),
        PersistentBottomNavBarItem(
          icon: Icon(Icons.shopping_cart),
          title: "Shopping Chart",
          activeColorPrimary: Colors.green,
          inactiveColorPrimary: Colors.blueGrey,
          routeAndNavigatorSettings: _navSettings,
        ),
        PersistentBottomNavBarItem(
          icon: Icon(Icons.sell),
          title: "Sales",
          activeColorPrimary: Colors.green,
          inactiveColorPrimary: Colors.blueGrey,
          routeAndNavigatorSettings: _navSettings,
        ),
      ],
      navBarStyle: NavBarStyle.neumorphic,
    );
  }
}
