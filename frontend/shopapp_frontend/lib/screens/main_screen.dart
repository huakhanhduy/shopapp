import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/cart_provider.dart';

import 'home/home_screen.dart';
import 'shop/shop_screen.dart';
import 'cart/cart_screen.dart';
import 'favorite/favorite_screen.dart';
import 'profile/profile_screen.dart';

class MainScreen extends StatefulWidget {

  const MainScreen({
    super.key,
  });

  @override
  State<MainScreen> createState() =>
      _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int currentIndex = 0;
  final GlobalKey<HomeScreenState> homeKey = GlobalKey<HomeScreenState>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final cartProvider = Provider.of<CartProvider>(context, listen: false);
      if (authProvider.customerId != null) {
        cartProvider.initializeForUser(authProvider.customerId!);
      }
    });
  }

  late final List<Widget> pages = [
    HomeScreen(key: homeKey),

    const ShopScreen(),

    const CartScreen(),

    const FavoriteScreen(),

    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      body: IndexedStack(

        index: currentIndex,

        children: pages,
      ),

      bottomNavigationBar:
      BottomNavigationBar(

        currentIndex:
        currentIndex,

        type:
        BottomNavigationBarType.fixed,

        backgroundColor: Colors.white,
        selectedItemColor: const Color(0xffDB3022),
        unselectedItemColor: Colors.grey,

        onTap: (index) {
          if (index == 0 && currentIndex == 0) {
            homeKey.currentState?.reload();
          }
          setState(() {

            currentIndex =
                index;
          });
        },

        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: "Home",
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.storefront_outlined),
            activeIcon: Icon(Icons.store),
            label: "Shop",
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_bag_outlined),
            activeIcon: Icon(Icons.shopping_bag),
            label: "Cart",
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.favorite_border),
            activeIcon: Icon(Icons.favorite),
            label: "Favorite",
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: "Profile",
          ),
        ],
      ),
    );
  }
}