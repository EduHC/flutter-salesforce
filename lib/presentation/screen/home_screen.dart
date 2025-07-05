import 'package:flutter/material.dart';
import 'package:salesforce/globals.dart';
import 'package:salesforce/presentation/state/home_screen_state.dart';
import 'package:salesforce/presentation/widget/header_widget.dart';
import 'package:salesforce/presentation/widget/home_screen/home_banner.dart';
import 'package:salesforce/presentation/widget/home_screen/home_product_card.dart';
import 'package:salesforce/presentation/widget/title_divider_widget.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final HomeScreenState _state = HomeScreenState();
  final Globals _globals = Globals();
  bool loading = true;

  void handleNotify() => setState(() {});

  @override
  void initState() {
    super.initState();
    _state.addListener(handleNotify);
    Future.delayed(
      Duration(milliseconds: 500),
      () => setState(() => loading = false),
    );
  }

  @override
  void dispose() {
    _state.removeListener(handleNotify);
    super.dispose();
  }

  @override
  Widget build(BuildContext c) {
    _state.doInitialLoadIfNeeded();

    return Scaffold(
      body: SafeArea(
        child:
            loading
                ? Center(child: CircularProgressIndicator())
                : CustomScrollView(
                  slivers: [
                    SliverToBoxAdapter(child: HeaderWidget()),
                    SliverToBoxAdapter(child: HomeBanner()),
                    SliverToBoxAdapter(
                      child: TitleDividerWidget(text: "Artigos para Casa"),
                    ),
                    SliverToBoxAdapter(child: _popularCarousel(1)),
                    SliverToBoxAdapter(
                      child: TitleDividerWidget(text: "Roupas"),
                    ),
                    SliverToBoxAdapter(child: _popularCarousel(2)),
                    SliverPadding(padding: EdgeInsets.only(bottom: 100)),
                  ],
                ),
      ),
      bottomSheet: Container(
        color: Colors.white,
        padding: EdgeInsets.all(16),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            minimumSize: Size.fromHeight(50),
            backgroundColor: Color(0xFF4f6e62),
            elevation: 3,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          onPressed: () => _globals.tabController.jumpToTab(1),
          child: Text("Ver Catálogo", style: TextStyle(fontSize: 18)),
        ),
      ),
    );
  }

  Widget _popularCarousel(int val) => SizedBox(
    height: 240,
    child: ListView.separated(
      scrollDirection: Axis.horizontal,
      padding: EdgeInsets.symmetric(horizontal: 16),
      itemCount: _state.products.length,
      separatorBuilder: (_, i) => SizedBox(width: 12),
      itemBuilder:
          (_, i) => Hero(
            tag: "product$i-$val",
            child: HomeProductCard(product: _state.products[i]),
          ),
    ),
  );
}
