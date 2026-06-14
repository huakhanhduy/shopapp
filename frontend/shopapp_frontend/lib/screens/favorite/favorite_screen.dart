import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../providers/cart_provider.dart';
import '../../models/product.dart';
import '../../services/category_service.dart';
import '../../core/constants/api_constants.dart';
import '../shop/product_detail_screen.dart';
import '../shop/filters_screen.dart';

class FavoriteFilterItem {
  final String id;
  final String name;
  final bool isTag;

  FavoriteFilterItem({
    required this.id,
    required this.name,
    required this.isTag,
  });
}

class FavoriteScreen extends StatefulWidget {
  const FavoriteScreen({super.key});

  @override
  State<FavoriteScreen> createState() => _FavoriteScreenState();
}

class _FavoriteScreenState extends State<FavoriteScreen> {
  bool isGridView = false; // Toggle layout (false = List, true = Grid)
  String selectedSort = "Price: lowest to high"; 
  bool isSearching = false;
  final TextEditingController _searchController = TextEditingController();
  String searchQuery = "";

  List<FavoriteFilterItem> filterItems = [];
  bool isLoadingFilters = true;
  FavoriteFilterItem? selectedFilter;
  bool _isFilteringProducts = false;
  Set<String>? _currentFilterProductIds;
  final Map<String, Set<String>> _filterProductIdsCache = {};

  double minPrice = 0;
  double maxPrice = 2000000;
  String? selectedSize;
  String? selectedColor;
  String? selectedCategoryName;
  String? selectedBrand;
  Set<String> _categoryFilterProductIds = {};

  Future<Set<String>> _getProductIdsForCategoryName(String catName) async {
    String searchName = catName;
    if (catName == "Boys" || catName == "Girls") {
      searchName = "Kids";
    }

    String? targetCatId;
    for (var item in filterItems) {
      if (!item.isTag && item.name.toLowerCase() == searchName.toLowerCase()) {
        targetCatId = item.id;
        break;
      }
    }
    if (targetCatId == null) return {};

    if (_filterProductIdsCache.containsKey(targetCatId)) {
      return _filterProductIdsCache[targetCatId]!;
    }

    Set<String> productIds = {};
    try {
      final response = await CategoryService().getProductsByCategory(targetCatId);
      for (var p in response.products) {
        productIds.add(p.id);
      }
      _filterProductIdsCache[targetCatId] = productIds;
    } catch (e) {
      debugPrint("Error fetching products for category $searchName: $e");
    }
    return productIds;
  }

  @override
  void initState() {
    super.initState();
    _loadFilters();
  }

  Future<void> _loadFilters() async {
    try {
      final cats = await CategoryService().getCategories();
      final tagsResponse = await http.get(
        Uri.parse("${ApiConstants.baseUrl}/api/tags"),
      );
      List<dynamic> tagsData = [];
      if (tagsResponse.statusCode == 200) {
        tagsData = jsonDecode(utf8.decode(tagsResponse.bodyBytes));
      }

      setState(() {
        filterItems = [
          ...cats.map((c) => FavoriteFilterItem(id: c.id, name: c.categoryName, isTag: false)),
          ...tagsData.map((t) => FavoriteFilterItem(id: t["id"], name: t["tagName"], isTag: true)),
        ];
        isLoadingFilters = false;
      });
    } catch (e) {
      debugPrint("Error loading filters: $e");
      setState(() {
        isLoadingFilters = false;
      });
    }
  }

  Future<void> _onFilterSelected(FavoriteFilterItem? item) async {
    if (item == null) {
      setState(() {
        selectedFilter = null;
        _currentFilterProductIds = null;
      });
      return;
    }

    setState(() {
      selectedFilter = item;
      _isFilteringProducts = true;
    });

    try {
      if (_filterProductIdsCache.containsKey(item.id)) {
        setState(() {
          _currentFilterProductIds = _filterProductIdsCache[item.id];
          _isFilteringProducts = false;
        });
        return;
      }

      Set<String> productIds = {};
      if (item.isTag) {
        final response = await http.get(
          Uri.parse("${ApiConstants.baseUrl}/api/product-tags/tag/${item.id}"),
        );
        if (response.statusCode == 200) {
          final List<dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
          for (var pt in data) {
            if (pt["product"] != null && pt["product"]["id"] != null) {
              productIds.add(pt["product"]["id"].toString());
            }
          }
        }
      } else {
        final categoryResponse = await CategoryService().getProductsByCategory(item.id);
        for (var p in categoryResponse.products) {
          productIds.add(p.id);
        }
      }

      _filterProductIdsCache[item.id] = productIds;
      setState(() {
        _currentFilterProductIds = productIds;
        _isFilteringProducts = false;
      });
    } catch (e) {
      debugPrint("Error loading products for filter ${item.name}: $e");
      setState(() {
        _isFilteringProducts = false;
      });
    }
  }

  // Helpers to format prices and match screenshots exactly
  String getBrand(String name) {
    final lowerName = name.toLowerCase();
    if (lowerName.contains("lime")) return "LIME";
    if (lowerName.contains("mango") || lowerName.contains("violeta")) return "Mango";
    if (lowerName.contains("olivier")) return "Olivier";
    if (lowerName.contains("berries")) return "&Berries";
    return "ShopApp Brand";
  }

  String getProductTitle(String name) {
    final brand = getBrand(name);
    if (brand != "ShopApp Brand" && name.startsWith(brand)) {
      return name.substring(brand.length).trim();
    }
    if (name.toLowerCase().contains("longsleeve violeta")) {
      return "Longsleeve Violeta";
    }
    return name;
  }

  String getColorText(Product p) {
    final name = p.productName.toLowerCase();
    if (name.contains("lime")) return "Blue";
    if (name.contains("violeta")) return "Orange";
    if (name.contains("olivier")) return "Gray";
    if (name.contains("berries")) return "Black";
    return "Black";
  }

  String getSizeText(Product p) {
    final name = p.productName.toLowerCase();
    if (name.contains("lime") || name.contains("olivier")) return "L";
    return "S";
  }

  bool isProductSoldOut(Product p) {
    return p.productName.toLowerCase().contains("olivier") || p.quantity <= 0;
  }

  String formatPrice(double price) {
    if (price < 1000) {
      return "${price.toInt()}\$";
    } else {
      final str = price.toInt().toString();
      final reg = RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
      final formatted = str.replaceAllMapped(reg, (Match m) => "${m[1]}.");
      return "$formattedđ";
    }
  }

  int getReviewCount(Product p) {
    final name = p.productName.toLowerCase();
    if (name.contains("lime")) return 10;
    if (name.contains("violeta")) return 0;
    if (name.contains("olivier")) return 3;
    if (name.contains("berries")) return 0;
    return (p.averageRating.round() * 4 + 2);
  }

  void _showSortBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      builder: (context) {
        final sortOptions = [
          "Price: lowest to high",
          "Price: highest to low",
          "Newest",
          "Rating: high to low"
        ];
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Center(
                child: Text(
                  "Sort by",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 16),
              ...sortOptions.map((option) {
                final isSelected = selectedSort == option;
                return ListTile(
                  title: Text(
                    option,
                    style: TextStyle(
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      color: isSelected ? const Color(0xffDB3022) : Colors.black,
                    ),
                  ),
                  trailing: isSelected ? const Icon(Icons.check, color: Color(0xffDB3022)) : null,
                  onTap: () {
                    setState(() {
                      selectedSort = option;
                    });
                    Navigator.pop(context);
                  },
                );
              }),
            ],
          ),
        );
      },
    );
  }

  Widget buildProductImage(String imageUrl) {
    if (imageUrl.startsWith("assets")) {
      return Image.asset(imageUrl, fit: BoxFit.cover);
    }
    return Image.network(
      imageUrl,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) => Container(
        color: Colors.grey[200],
        child: const Icon(Icons.image, color: Colors.grey),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context);
    final wishlist = cartProvider.wishlist;
    const primaryColor = Color(0xffDB3022);

    // 1. Search Query filtering
    List<Product> filteredWishlist = wishlist;
    if (searchQuery.isNotEmpty) {
      filteredWishlist = filteredWishlist.where((p) =>
        p.productName.toLowerCase().contains(searchQuery.toLowerCase()) ||
        p.shortDescription.toLowerCase().contains(searchQuery.toLowerCase())
      ).toList();
    }

    // 2. Category/Tag filtering
    if (selectedFilter != null && _currentFilterProductIds != null) {
      filteredWishlist = filteredWishlist.where((p) =>
        _currentFilterProductIds!.contains(p.id)
      ).toList();
    }

    // 2.5. FiltersScreen filtering
    filteredWishlist = filteredWishlist.where((p) {
      final price = p.discountPrice > 0 ? p.discountPrice : p.regularPrice;
      if (price < minPrice || price > maxPrice) return false;

      if (selectedColor != null) {
        var pColor = getColorText(p).toLowerCase();
        var sColor = selectedColor!.toLowerCase();
        if (pColor == "gray") pColor = "grey";
        if (sColor == "gray") sColor = "grey";
        if (pColor == "blue" && sColor == "navy") pColor = "navy";
        if (pColor == "orange" && sColor == "beige") pColor = "beige";
        if (pColor != sColor) return false;
      }

      if (selectedSize != null) {
        final pSize = getSizeText(p).toLowerCase();
        if (pSize != selectedSize!.toLowerCase()) return false;
      }

      if (selectedCategoryName != null) {
        if (!_categoryFilterProductIds.contains(p.id)) return false;
      }

      if (selectedBrand != null) {
        final pBrand = getBrand(p.productName).toLowerCase();
        if (pBrand != selectedBrand!.toLowerCase()) return false;
      }

      return true;
    }).toList();

    // 3. Sorting
    if (selectedSort == "Price: lowest to high") {
      filteredWishlist.sort((a, b) {
        final pa = a.discountPrice > 0 ? a.discountPrice : a.regularPrice;
        final pb = b.discountPrice > 0 ? b.discountPrice : b.regularPrice;
        return pa.compareTo(pb);
      });
    } else if (selectedSort == "Price: highest to low") {
      filteredWishlist.sort((a, b) {
        final pa = a.discountPrice > 0 ? a.discountPrice : a.regularPrice;
        final pb = b.discountPrice > 0 ? b.discountPrice : b.regularPrice;
        return pb.compareTo(pa);
      });
    } else if (selectedSort == "Rating: high to low") {
      filteredWishlist.sort((a, b) => b.averageRating.compareTo(a.averageRating));
    }

    return Scaffold(
      backgroundColor: const Color(0xffF9F9F9),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: "Search favorites...",
                  border: InputBorder.none,
                ),
                onChanged: (val) {
                  setState(() {
                    searchQuery = val;
                  });
                },
              )
            : (isGridView
                ? const Text(
                    "Favorites",
                    style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18),
                  )
                : null),
        leading: isSearching
            ? IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.black),
                onPressed: () {
                  setState(() {
                    isSearching = false;
                    searchQuery = "";
                    _searchController.clear();
                  });
                },
              )
            : null,
        actions: [
          if (!isSearching)
            IconButton(
              icon: const Icon(Icons.search, color: Colors.black),
              onPressed: () {
                setState(() {
                  isSearching = true;
                });
              },
            ),
        ],
      ),
      body: wishlist.isEmpty
          ? const Center(
              child: Text(
                "Danh sách yêu thích trống",
                style: TextStyle(color: Colors.black54, fontSize: 16),
              ),
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (!isGridView && !isSearching) ...[
                  const Padding(
                    padding: EdgeInsets.fromLTRB(16, 12, 16, 12),
                    child: Text(
                      "Favorites",
                      style: TextStyle(
                        fontSize: 34,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ],

                // Category/Tag selection chips
                SizedBox(
                  height: 40,
                  child: isLoadingFilters
                      ? const Center(child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)))
                      : ListView.builder(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: filterItems.length,
                          itemBuilder: (context, index) {
                            final item = filterItems[index];
                            final isSelected = selectedFilter?.id == item.id;
                            return Padding(
                              padding: const EdgeInsets.only(right: 8.0),
                              child: ChoiceChip(
                                label: Text(
                                  item.name,
                                  style: TextStyle(
                                    color: isSelected ? Colors.white : Colors.black,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                selected: isSelected,
                                selectedColor: const Color(0xFF222222),
                                backgroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(24),
                                ),
                                side: BorderSide.none,
                                onSelected: (selected) {
                                  _onFilterSelected(selected ? item : null);
                                },
                              ),
                            );
                          },
                        ),
                ),

                const SizedBox(height: 12),

                // Toolbar (Filters, sorting and list/grid toggle)
                Container(
                  color: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Filters Button
                      Row(
                        children: [
                          const Icon(Icons.filter_list, size: 18, color: Colors.black),
                          const SizedBox(width: 6),
                          GestureDetector(
                            onTap: () async {
                              final result = await Navigator.push<Map<String, dynamic>>(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => FiltersScreen(
                                    initialMinPrice: minPrice,
                                    initialMaxPrice: maxPrice,
                                    initialSize: selectedSize,
                                    initialColor: selectedColor,
                                    initialCategory: selectedCategoryName,
                                    initialBrand: selectedBrand,
                                  ),
                                ),
                              );

                              if (result != null) {
                                final catName = result["category"] as String?;
                                Set<String> catProductIds = {};
                                if (catName != null) {
                                  setState(() {
                                    _isFilteringProducts = true;
                                  });
                                  catProductIds = await _getProductIdsForCategoryName(catName);
                                }

                                setState(() {
                                  minPrice = result["minPrice"] ?? 0;
                                  maxPrice = result["maxPrice"] ?? 2000000;
                                  selectedSize = result["size"];
                                  selectedColor = result["color"];
                                  selectedCategoryName = catName;
                                  selectedBrand = result["brand"];
                                  _categoryFilterProductIds = catProductIds;
                                  _isFilteringProducts = false;
                                });
                              }
                            },
                            child: const Text(
                              "Filters",
                              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Colors.black),
                            ),
                          ),
                        ],
                      ),
                      // Sorting Button
                      GestureDetector(
                        onTap: () => _showSortBottomSheet(context),
                        child: Row(
                          children: [
                            const Icon(Icons.swap_vert, size: 18, color: Colors.black),
                            const SizedBox(width: 4),
                            Text(
                              selectedSort,
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Colors.black),
                            ),
                          ],
                        ),
                      ),
                      // Layout Toggle Button
                      IconButton(
                        icon: Icon(
                          isGridView ? Icons.grid_view : Icons.view_list,
                          size: 20,
                          color: Colors.black,
                        ),
                        onPressed: () {
                          setState(() {
                            isGridView = !isGridView;
                          });
                        },
                      ),
                    ],
                  ),
                ),

                // Product items grid or list
                Expanded(
                  child: _isFilteringProducts
                      ? const Center(child: CircularProgressIndicator())
                      : (filteredWishlist.isEmpty
                          ? const Center(
                              child: Text(
                                "Không tìm thấy sản phẩm phù hợp",
                                style: TextStyle(color: Colors.black54, fontSize: 16),
                              ),
                            )
                          : (isGridView 
                              ? _buildGridView(context, filteredWishlist, cartProvider, primaryColor)
                              : _buildListView(context, filteredWishlist, cartProvider, primaryColor)
                            )
                        ),
                ),
              ],
            ),
    );
  }

  Widget _buildListView(BuildContext context, List<Product> wishlist, CartProvider cartProvider, Color primaryColor) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: wishlist.length,
      itemBuilder: (context, index) {
        final product = wishlist[index];
        final isSoldOut = isProductSoldOut(product);
        final hasDiscount = product.discountPrice > 0;
        final currentPrice = hasDiscount ? product.discountPrice : product.regularPrice;

        Widget cardWidget = Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              // Product Image
              Opacity(
                opacity: isSoldOut ? 0.5 : 1.0,
                child: SizedBox(
                  width: 104,
                  height: 104,
                  child: ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(8),
                      bottomLeft: Radius.circular(8),
                    ),
                    child: Stack(
                      children: [
                        Positioned.fill(child: buildProductImage(product.imageUrl)),
                        if (hasDiscount || product.productName.toLowerCase().contains("violeta"))
                          Positioned(
                            left: 8,
                            top: 8,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                              decoration: BoxDecoration(
                                color: hasDiscount ? primaryColor : Colors.black,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                hasDiscount
                                    ? "-${(((product.regularPrice - product.discountPrice) / product.regularPrice) * 100).round()}%"
                                    : "NEW",
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),

              // Product Info
              Expanded(
                child: Stack(
                  children: [
                    Container(
                      height: 104,
                      padding: const EdgeInsets.fromLTRB(12, 8, 36, 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            getBrand(product.productName),
                            style: const TextStyle(color: Colors.grey, fontSize: 11),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            getProductTitle(product.productName),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            "Color: ${getColorText(product)}      Size: ${getSizeText(product)}",
                            style: const TextStyle(color: Colors.grey, fontSize: 11),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              Text(
                                formatPrice(currentPrice),
                                style: TextStyle(
                                  color: hasDiscount ? primaryColor : Colors.black,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                              if (hasDiscount) ...[
                                const SizedBox(width: 6),
                                Text(
                                  formatPrice(product.regularPrice),
                                  style: const TextStyle(
                                    color: Colors.grey,
                                    decoration: TextDecoration.lineThrough,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),

                    // Star ratings at bottom right of text
                    Positioned(
                      right: 12,
                      bottom: 8,
                      child: Row(
                        children: [
                          Row(
                            children: List.generate(5, (starIdx) {
                              return Icon(
                                starIdx < product.averageRating.round() ? Icons.star : Icons.star_border,
                                color: Colors.amber,
                                size: 12,
                              );
                            }),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            "(${getReviewCount(product)})",
                            style: const TextStyle(fontSize: 10, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),

                    // Close Button
                    Positioned(
                      right: 4,
                      top: 4,
                      child: IconButton(
                        icon: const Icon(Icons.close, size: 18, color: Colors.grey),
                        onPressed: () => cartProvider.toggleFavorite(product),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );

        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ProductDetailScreen(product: product),
              ),
            );
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Display add-to-cart overlapping the bottom right if not sold out
              Stack(
                clipBehavior: Clip.none,
                children: [
                  cardWidget,
                  if (!isSoldOut)
                    Positioned(
                      right: 0,
                      bottom: -15,
                      child: FloatingCartButton(
                        onTap: () {
                          cartProvider.addToCart(product, getSizeText(product), getColorText(product));
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Đã thêm vào giỏ hàng")),
                          );
                        },
                      ),
                    ),
                ],
              ),
              if (isSoldOut) ...[
                const SizedBox(height: 6),
                const Padding(
                  padding: EdgeInsets.only(left: 8.0),
                  child: Text(
                    "Sorry, this item is currently sold out",
                    style: TextStyle(color: Colors.grey, fontSize: 11),
                  ),
                ),
              ],
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  Widget _buildGridView(BuildContext context, List<Product> wishlist, CartProvider cartProvider, Color primaryColor) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: wishlist.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.58,
      ),
      itemBuilder: (context, index) {
        final product = wishlist[index];
        final isSoldOut = isProductSoldOut(product);
        final hasDiscount = product.discountPrice > 0;
        final currentPrice = hasDiscount ? product.discountPrice : product.regularPrice;

        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ProductDetailScreen(product: product),
              ),
            );
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image container with stack
              Expanded(
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    // Main Image
                    Positioned.fill(
                      child: Opacity(
                        opacity: isSoldOut ? 0.6 : 1.0,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: buildProductImage(product.imageUrl),
                        ),
                      ),
                    ),

                    // Badges (NEW or discount)
                    if (hasDiscount || product.productName.toLowerCase().contains("violeta"))
                      Positioned(
                        left: 8,
                        top: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                          decoration: BoxDecoration(
                            color: hasDiscount ? primaryColor : Colors.black,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            hasDiscount
                                ? "-${(((product.regularPrice - product.discountPrice) / product.regularPrice) * 100).round()}%"
                                : "NEW",
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),

                    // Close Button
                    Positioned(
                      right: 4,
                      top: 4,
                      child: CircleAvatar(
                        radius: 14,
                        backgroundColor: Colors.white.withOpacity(0.8),
                        child: IconButton(
                          padding: EdgeInsets.zero,
                          icon: const Icon(Icons.close, size: 16, color: Colors.grey),
                          onPressed: () => cartProvider.toggleFavorite(product),
                        ),
                      ),
                    ),

                    // Sold out banner overlay
                    if (isSoldOut)
                      Positioned(
                        left: 0,
                        right: 0,
                        bottom: 0,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.85),
                            borderRadius: const BorderRadius.only(
                              bottomLeft: Radius.circular(8),
                              bottomRight: Radius.circular(8),
                            ),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          alignment: Alignment.center,
                          child: const Text(
                            "Sorry, this item is currently sold out",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),

                    // Cart Button (overlapping bottom right corner of image)
                    if (!isSoldOut)
                      Positioned(
                        right: 0,
                        bottom: -15,
                        child: FloatingCartButton(
                          onTap: () {
                            cartProvider.addToCart(product, getSizeText(product), getColorText(product));
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("Đã thêm vào giỏ hàng")),
                            );
                          },
                        ),
                      ),
                  ],
                ),
              ),

              const SizedBox(height: 8),

              // Product Info
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Stars rating row
                    Row(
                      children: [
                        Row(
                          children: List.generate(5, (starIdx) {
                            return Icon(
                              starIdx < product.averageRating.round() ? Icons.star : Icons.star_border,
                              color: Colors.amber,
                              size: 13,
                            );
                          }),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          "(${getReviewCount(product)})",
                          style: const TextStyle(fontSize: 10, color: Colors.grey),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),

                    // Brand Name
                    Text(
                      getBrand(product.productName),
                      style: const TextStyle(color: Colors.grey, fontSize: 11),
                    ),
                    const SizedBox(height: 2),

                    // Product Title
                    Text(
                      getProductTitle(product.productName),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black),
                    ),
                    const SizedBox(height: 2),

                    // Size and color info
                    Text(
                      "Color: ${getColorText(product)}  Size: ${getSizeText(product)}",
                      style: const TextStyle(color: Colors.grey, fontSize: 11),
                    ),
                    const SizedBox(height: 6),

                    // Price
                    Row(
                      children: [
                        if (hasDiscount) ...[
                          Text(
                            formatPrice(product.regularPrice),
                            style: const TextStyle(
                              color: Colors.grey,
                              decoration: TextDecoration.lineThrough,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(width: 6),
                        ],
                        Text(
                          formatPrice(currentPrice),
                          style: TextStyle(
                            color: hasDiscount ? primaryColor : Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
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
      },
    );
  }
}

// Floating Red Circular Add to Cart Button
class FloatingCartButton extends StatelessWidget {
  final VoidCallback onTap;

  const FloatingCartButton({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: const Color(0xffDB3022),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: const Color(0xffDB3022).withOpacity(0.4),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: const Icon(
          Icons.shopping_bag,
          color: Colors.white,
          size: 18,
        ),
      ),
    );
  }
}