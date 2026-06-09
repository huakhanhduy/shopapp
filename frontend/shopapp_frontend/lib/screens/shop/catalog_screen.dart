import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'product_detail_screen.dart';
import 'filters_screen.dart';
import '../../models/product.dart';
import '../../services/category_service.dart';
import '../../services/product_service.dart';
import '../../providers/cart_provider.dart';

class CatalogScreen extends StatefulWidget {
  final String categoryId;
  final String categoryName;
  final List<Product>? products;

  const CatalogScreen({
    super.key,
    required this.categoryId,
    required this.categoryName,
    this.products,
  });

  @override
  State<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends State<CatalogScreen> {
  late Future<List<Product>> futureProducts;
  final ProductService _productService = ProductService();

  // Filters state
  double minPrice = 0;
  double maxPrice = 2000000;
  String? selectedSize;
  String? selectedColor;
  String? selectedSort;

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  void _loadProducts() {
    if (widget.products != null) {
      futureProducts = Future.value(widget.products);
    } else if (widget.categoryId == "visual_search") {
      futureProducts = _productService.getVisualSearchResults();
    } else {
      futureProducts = CategoryService()
          .getProductsByCategory(widget.categoryId)
          .then((res) => res.products);
    }
  }

  List<Product> _localFilterAndSort(List<Product> products) {
    List<Product> filtered = products.where((p) {
      double price = p.discountPrice > 0 ? p.discountPrice : p.regularPrice;
      return price >= minPrice && price <= maxPrice;
    }).toList();

    if (selectedSort != null) {
      if (selectedSort == "price_low") {
        filtered.sort((a, b) {
          double priceA = a.discountPrice > 0 ? a.discountPrice : a.regularPrice;
          double priceB = b.discountPrice > 0 ? b.discountPrice : b.regularPrice;
          return priceA.compareTo(priceB);
        });
      } else if (selectedSort == "price_high") {
        filtered.sort((a, b) {
          double priceA = a.discountPrice > 0 ? a.discountPrice : a.regularPrice;
          double priceB = b.discountPrice > 0 ? b.discountPrice : b.regularPrice;
          return priceB.compareTo(priceA);
        });
      }
    }
    return filtered;
  }

  void _applyFilters() async {
    final result = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(
        builder: (_) => FiltersScreen(
          initialMinPrice: minPrice,
          initialMaxPrice: maxPrice,
          initialSize: selectedSize,
          initialColor: selectedColor,
          initialSort: selectedSort,
        ),
      ),
    );

    if (result != null) {
      setState(() {
        minPrice = result["minPrice"] ?? 0;
        maxPrice = result["maxPrice"] ?? 2000000;
        selectedSize = result["size"];
        selectedColor = result["color"];
        selectedSort = result["sort"];

        if (widget.products != null) {
          futureProducts = Future.value(_localFilterAndSort(widget.products!));
        } else {
          futureProducts = _productService.getProductsFiltered(
            minPrice: minPrice,
            maxPrice: maxPrice,
            size: selectedSize,
            color: selectedColor,
            sort: selectedSort,
            categoryId: widget.categoryId == "visual_search" ? null : widget.categoryId,
          );
        }
      });
    }
  }

  void showSortSheet() {
    showModalBottomSheet(
      context: context,
      builder: (_) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: const Text("Newest"),
                onTap: () {
                  Navigator.pop(context);
                  _updateSort("newest");
                },
              ),
              ListTile(
                title: const Text("Price Low -> High"),
                onTap: () {
                  Navigator.pop(context);
                  _updateSort("price_low");
                },
              ),
              ListTile(
                title: const Text("Price High -> Low"),
                onTap: () {
                  Navigator.pop(context);
                  _updateSort("price_high");
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _updateSort(String sortType) {
    setState(() {
      selectedSort = sortType;
      if (widget.products != null) {
        futureProducts = Future.value(_localFilterAndSort(widget.products!));
      } else {
        futureProducts = _productService.getProductsFiltered(
          minPrice: minPrice,
          maxPrice: maxPrice,
          size: selectedSize,
          color: selectedColor,
          sort: selectedSort,
          categoryId: widget.categoryId == "visual_search" ? null : widget.categoryId,
        );
      }
    });
  }

  Widget buildProductCard(Product product) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ]
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Stack(
              children: [
                Positioned.fill(
                  child: ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                    ),
                    child: product.imageUrl.startsWith("assets")
                        ? Image.asset(product.imageUrl, fit: BoxFit.cover)
                        : Image.network(product.imageUrl, fit: BoxFit.cover, errorBuilder: (_, __, ___) => Container(color: Colors.grey[200])),
                  ),
                ),
                Positioned(
                  top: 10,
                  left: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
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
                          radius: 18,
                          backgroundColor: Colors.white,
                          child: Icon(
                            isFav ? Icons.favorite : Icons.favorite_border,
                            color: isFav ? Colors.red : Colors.grey[700],
                            size: 18,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: List.generate(
                    5,
                    (index) => Icon(
                      index < product.averageRating.round() ? Icons.star : Icons.star_border,
                      size: 14,
                      color: Colors.amber,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  product.productName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 4),
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
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      appBar: AppBar(
        title: Text(widget.categoryName),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: FutureBuilder<List<Product>>(
        future: futureProducts,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          if (snapshot.hasError) {
            return Center(
              child: Text(snapshot.error.toString()),
            );
          }

          final products = snapshot.data ?? [];

          return Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _applyFilters,
                        icon: const Icon(Icons.filter_list),
                        label: const Text("Filters"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black,
                          elevation: 1,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: showSortSheet,
                        icon: const Icon(Icons.sort),
                        label: const Text("Sort"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black,
                          elevation: 1,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: products.isEmpty
                    ? const Center(child: Text("Không tìm thấy sản phẩm nào"))
                    : GridView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: products.length,
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          childAspectRatio: 0.58,
                        ),
                        itemBuilder: (context, index) {
                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => ProductDetailScreen(product: products[index]),
                                ),
                              );
                            },
                            child: buildProductCard(products[index]),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}