import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/product.dart';
import '../../models/review.dart';
import '../../services/product_service.dart';
import '../../services/review_service.dart';
import '../../core/widgets/image_helper.dart';
import '../../providers/cart_provider.dart';
import 'reviews_list_screen.dart';

class ProductDetailScreen extends StatefulWidget {
  final Product product;

  const ProductDetailScreen({super.key, required this.product});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  late Future<List<Product>> _relatedProductsFuture;
  late Future<List<Review>> _reviewsFuture;
  
  String _selectedSize = "M";
  String _selectedColor = "Black";

  final List<String> _sizes = ["S", "M", "L", "XL"];
  final List<String> _colors = ["Black", "Red", "Blue", "White"];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    _relatedProductsFuture = ProductService().getRelatedProducts(widget.product.id);
    _reviewsFuture = ReviewService().getReviews(widget.product.id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.product.productName,
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share, color: Colors.black, size: 20),
            onPressed: () {},
          ),
        ],
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Images Gallery (horizontal scroll mockup)
            SizedBox(
              height: 400,
              width: double.infinity,
              child: PageView(
                children: [
                  buildProductImage(widget.product.imageUrl, fit: BoxFit.cover),
                  buildProductImage(widget.product.imageUrl, fit: BoxFit.cover), // Second slide mockup
                ],
              ),
            ),
            
            const SizedBox(height: 12),

            // Dropdowns (Size, Color, Favorite)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  // Size Dropdown
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _selectedSize,
                          isExpanded: true,
                          items: _sizes.map((size) {
                            return DropdownMenuItem(
                              value: size,
                              child: Text("Size: $size", style: const TextStyle(fontSize: 14)),
                            );
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) setState(() => _selectedSize = val);
                          },
                        ),
                      ),
                    ),
                  ),
                  
                  const SizedBox(width: 12),

                  // Color Dropdown
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _selectedColor,
                          isExpanded: true,
                          items: _colors.map((color) {
                            return DropdownMenuItem(
                              value: color,
                              child: Text(color, style: const TextStyle(fontSize: 14)),
                            );
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) setState(() => _selectedColor = val);
                          },
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 12),

                  // Favorite Button
                  Consumer<CartProvider>(
                    builder: (context, cart, _) {
                      final isFav = cart.isFavorite(widget.product);
                      return GestureDetector(
                        onTap: () {
                          cart.toggleFavorite(widget.product);
                        },
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: 4,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Icon(
                            isFav ? Icons.favorite : Icons.favorite_border,
                            color: isFav ? Colors.red : Colors.grey,
                            size: 24,
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 22),

            // Product Details Block
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          widget.product.productName,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.5,
                          ),
                        ),
                      ),
                      Text(
                        "${widget.product.discountPrice.toInt()}đ",
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                          color: Color(0xffDB3022),
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 4),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        widget.product.brand,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.grey,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      if (widget.product.regularPrice > widget.product.discountPrice)
                        Text(
                          "${widget.product.regularPrice.toInt()}đ",
                          style: const TextStyle(
                            fontSize: 15,
                            color: Colors.grey,
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  // Ratings Link Section
                  FutureBuilder<List<Review>>(
                    future: _reviewsFuture,
                    builder: (context, snapshot) {
                      final reviews = snapshot.data ?? [];
                      double avgRating = 0;
                      if (reviews.isNotEmpty) {
                        double sum = 0;
                        for (var r in reviews) {
                          sum += r.rating;
                        }
                        avgRating = sum / reviews.length;
                      }

                      return InkWell(
                        onTap: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ReviewsListScreen(
                                productId: widget.product.id,
                                productName: widget.product.productName,
                              ),
                            ),
                          );
                          setState(() {
                            _loadData();
                          });
                        },
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
                              children: List.generate(5, (index) {
                                return Icon(
                                  index < avgRating.round() ? Icons.star : Icons.star_border,
                                  color: Colors.amber,
                                  size: 18,
                                );
                              }),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              "(${reviews.length})",
                              style: const TextStyle(
                                fontSize: 13,
                                color: Colors.grey,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 16),

                  // Short Description
                  Text(
                    widget.product.shortDescription,
                    style: const TextStyle(
                      fontSize: 15,
                      height: 1.4,
                      color: Colors.black87,
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Full Description
                  Text(
                    widget.product.productDescription,
                    style: TextStyle(
                      fontSize: 13,
                      height: 1.4,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),

            // ADD TO CART BUTTON
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () {
                    Provider.of<CartProvider>(context, listen: false).addToCart(
                      widget.product,
                      _selectedSize,
                      _selectedColor,
                    );
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Đã thêm sản phẩm vào giỏ hàng")),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xffDB3022),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(26),
                    ),
                    elevation: 3,
                  ),
                  child: const Text(
                    "ADD TO CART",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white),
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 16),

            // Collapsible Menu Mockups
            const Divider(),
            ListTile(
              title: const Text("Shipping info", style: TextStyle(fontWeight: FontWeight.w500)),
              trailing: const Icon(Icons.chevron_right, size: 20),
              onTap: () {},
            ),
            const Divider(),
            ListTile(
              title: const Text("Support", style: TextStyle(fontWeight: FontWeight.w500)),
              trailing: const Icon(Icons.chevron_right, size: 20),
              onTap: () {},
            ),
            const Divider(),
            
            const SizedBox(height: 24),

            // Related Products Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "You can also like this",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      FutureBuilder<List<Product>>(
                        future: _relatedProductsFuture,
                        builder: (context, snapshot) {
                          final count = snapshot.data?.length ?? 0;
                          return Text(
                            "$count items",
                            style: const TextStyle(color: Colors.grey, fontSize: 13),
                          );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  // Horizontal List of Related Products
                  SizedBox(
                    height: 280,
                    child: FutureBuilder<List<Product>>(
                      future: _relatedProductsFuture,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator());
                        }
                        if (snapshot.hasError) {
                          return Center(child: Text("Error loading related products: ${snapshot.error}"));
                        }
                        final list = snapshot.data ?? [];
                        if (list.isEmpty) {
                          return const Center(child: Text("No related products found"));
                        }

                        return ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: list.length,
                          itemBuilder: (context, index) {
                            final item = list[index];
                            return GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => ProductDetailScreen(product: item),
                                  ),
                                );
                              },
                              child: Container(
                                width: 150,
                                margin: const EdgeInsets.only(right: 14),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: Stack(
                                        children: [
                                          Positioned.fill(
                                            child: ClipRRect(
                                              borderRadius: BorderRadius.circular(12),
                                              child: buildProductImage(item.imageUrl, fit: BoxFit.cover),
                                            ),
                                          ),
                                          Positioned(
                                            bottom: 8,
                                            right: 8,
                                            child: Consumer<CartProvider>(
                                              builder: (context, cart, _) {
                                                final isFav = cart.isFavorite(item);
                                                return GestureDetector(
                                                  onTap: () {
                                                    cart.toggleFavorite(item);
                                                  },
                                                  child: Container(
                                                    width: 32,
                                                    height: 32,
                                                    decoration: const BoxDecoration(
                                                      color: Colors.white,
                                                      shape: BoxShape.circle,
                                                      boxShadow: [
                                                        BoxShadow(
                                                          color: Colors.black12,
                                                          blurRadius: 4,
                                                          offset: Offset(0, 2),
                                                        ),
                                                      ],
                                                    ),
                                                    child: Icon(
                                                      isFav ? Icons.favorite : Icons.favorite_border,
                                                      color: isFav ? Colors.red : Colors.grey,
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
                                    const SizedBox(height: 8),
                                    Text(
                                      item.brand,
                                      style: TextStyle(
                                        color: Colors.grey[500],
                                        fontSize: 11,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      item.productName,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      "${item.discountPrice.toInt()}đ",
                                      style: const TextStyle(color: Color(0xffDB3022), fontWeight: FontWeight.bold, fontSize: 13),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
