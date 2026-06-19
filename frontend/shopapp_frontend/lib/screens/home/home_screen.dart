import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:provider/provider.dart';

import '../../models/home_response.dart';
import '../../models/home_section.dart';
import '../../services/home_service.dart';
import '../../providers/cart_provider.dart';
import '../../core/widgets/image_helper.dart';
import '../shop/product_detail_screen.dart';
import '../shop/catalog_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  late Future<HomeResponse> futureHome;

  void reload() {
    setState(() {
      futureHome = HomeService().getHome();
    });
  }

  @override
  void initState() {
    super.initState();

    futureHome = HomeService().getHome();
  }

  Widget buildBanner() {
    return CarouselSlider(
      options: CarouselOptions(
        height: 280,

        viewportFraction: 1,

        autoPlay: true,

        autoPlayInterval: const Duration(seconds: 2),

        autoPlayAnimationDuration: const Duration(milliseconds: 800),

        enlargeCenterPage: false,
      ),

      items: [
        Image.asset(
          "assets/images/banner1.png",

          width: double.infinity,

          fit: BoxFit.cover,
        ),

        Image.asset(
          "assets/images/banner2.png",

          width: double.infinity,

          fit: BoxFit.cover,
        ),
      ],
    );
  }

  Widget buildSection(HomeSection section) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,

            children: [
              Text(
                section.tagName,

                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                ),
              ),

              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => CatalogScreen(
                        categoryId: "tag_${section.tagName}",
                        categoryName: section.tagName,
                        products: section.products,
                      ),
                    ),
                  );
                },
                child: const Text(
                  "View all",

                  style: TextStyle(color: Colors.black87, fontSize: 16),
                ),
              ),
            ],
          ),

          Text(
            section.subtitle,

            style: TextStyle(color: Colors.grey[600], fontSize: 16),
          ),

          const SizedBox(height: 20),

          SizedBox(
            height: 360,

            child: ListView.builder(
              scrollDirection: Axis.horizontal,

              itemCount: section.products.length,

              itemBuilder: (context, index) {
                final product = section.products[index];

                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ProductDetailScreen(
                          product: product,
                        ),
                      ),
                    );
                  },
                  child: Container(
                    width: 170,

                    margin: const EdgeInsets.only(right: 16),

                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,

                      children: [
                        Expanded(
                          child: Stack(
                            children: [
                              Positioned.fill(
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(16),
                                  child: buildProductImage(
                                    product.imageUrl,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),

                              Positioned(
                                top: 10,
                                left: 10,

                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 6,
                                  ),

                                  decoration: BoxDecoration(
                                    color: Colors.red,

                                    borderRadius: BorderRadius.circular(20),
                                  ),

                                  child: const Text(
                                    "-20%",

                                    style: TextStyle(
                                      color: Colors.white,

                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),

                              Positioned(
                                right: 10,
                                bottom: 10,
                                child: Consumer<CartProvider>(
                                  builder: (context, cart, _) {
                                    final isFav = cart.isFavorite(product);
                                    return GestureDetector(
                                      onTap: () {
                                        cart.toggleFavorite(product);
                                      },
                                      child: CircleAvatar(
                                        radius: 22,
                                        backgroundColor: Colors.white,
                                        child: Icon(
                                          isFav ? Icons.favorite : Icons.favorite_border,
                                          color: isFav ? Colors.red : Colors.grey[700],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 8),

                        Row(
                          children: List.generate(
                            5,
                            (index) => Icon(
                              index < product.averageRating.round() ? Icons.star : Icons.star_border,
                              color: Colors.amber,
                              size: 16,
                            ),
                          ),
                        ),

                        const SizedBox(height: 6),

                        Text(
                          product.brand,
                          style: TextStyle(
                            color: Colors.grey[500],
                            fontSize: 11,
                          ),
                        ),

                        const SizedBox(height: 4),

                        Text(
                          product.productName,

                          maxLines: 1,

                          overflow: TextOverflow.ellipsis,

                          style: const TextStyle(
                            fontSize: 16,

                            fontWeight: FontWeight.w600,
                          ),
                        ),

                        const SizedBox(height: 6),

                        Row(
                          children: [
                            Text(
                              "${product.regularPrice.toInt()}đ",

                              style: const TextStyle(
                                color: Colors.grey,

                                decoration: TextDecoration.lineThrough,
                              ),
                            ),

                            const SizedBox(width: 8),

                            Text(
                              "${product.discountPrice.toInt()}đ",

                              style: const TextStyle(
                                color: Colors.red,

                                fontSize: 15,

                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget buildHighlightGrid() {
    return Column(
      children: [
        SizedBox(
          height: 260,

          child: Stack(
            children: [
              Positioned.fill(
                child: Image.asset(
                  "assets/images/new_collection_tag.png",

                  fit: BoxFit.cover,
                ),
              ),

              const Positioned(
                left: 20,
                bottom: 20,

                child: Text(
                  "New Collection",

                  style: TextStyle(
                    color: Colors.white,

                    fontSize: 28,

                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),

        SizedBox(
          height: 220,

          child: Row(
            children: [
              Expanded(
                child: Container(
                  color: Colors.white,

                  alignment: Alignment.centerLeft,

                  padding: const EdgeInsets.all(24),

                  child: const Text(
                    "Summer\nsale",

                    style: TextStyle(
                      color: Colors.red,

                      fontSize: 25,

                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              Expanded(
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: Image.asset(
                        "assets/images/menhoddie_tag.png",

                        fit: BoxFit.cover,
                      ),
                    ),

                    const Positioned(
                      right: 20,
                      bottom: 20,

                      child: Text(
                        "Men's\nhoodies",

                        textAlign: TextAlign.right,

                        style: TextStyle(
                          color: Colors.white,

                          fontSize: 24,

                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        SizedBox(
          height: 180,

          child: Stack(
            children: [
              Positioned.fill(
                child: Image.asset(
                  "assets/images/black_tag.png",

                  fit: BoxFit.cover,
                ),
              ),

              const Positioned(
                left: 20,
                bottom: 20,

                child: Text(
                  "Black",

                  style: TextStyle(
                    color: Colors.white,

                    fontSize: 28,

                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      body: SafeArea(
        child: FutureBuilder<HomeResponse>(
          future: futureHome,

          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(child: Text(snapshot.error.toString()));
            }

            final home = snapshot.data!;

            return RefreshIndicator(
              onRefresh: () async {
                setState(() {
                  futureHome = HomeService().getHome();
                });

                await futureHome;
              },

              child: ListView(
                children: [
                  buildBanner(),

                  ...home.sections.map((section) => buildSection(section)),

                  buildHighlightGrid(),

                  const SizedBox(height: 20),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
