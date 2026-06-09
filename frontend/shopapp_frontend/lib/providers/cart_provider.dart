import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../core/constants/api_constants.dart';
import '../core/storage/token_storage.dart';
import '../models/product.dart';

class CartItem {
  final String? id; // UUID from database
  final Product product;
  final String size;
  final String color;
  int quantity;

  CartItem({
    this.id,
    required this.product,
    required this.size,
    required this.color,
    this.quantity = 1,
  });
}

class CartProvider extends ChangeNotifier {
  final List<CartItem> _items = [];
  final List<Product> _wishlist = [];
  
  String? _customerId;
  String? _appliedPromoCode;
  int _discountPercent = 0;
  
  Map<String, dynamic>? _selectedAddress;
  String _selectedShippingMethod = "FedEx";
  Map<String, dynamic>? _selectedPaymentCard;

  List<CartItem> get items => _items;
  List<Product> get wishlist => _wishlist;
  
  String? get appliedPromoCode => _appliedPromoCode;
  int get discountPercent => _discountPercent;
  
  Map<String, dynamic>? get selectedAddress => _selectedAddress;
  String get selectedShippingMethod => _selectedShippingMethod;
  Map<String, dynamic>? get selectedPaymentCard => _selectedPaymentCard;

  Future<Map<String, String>> _headers() async {
    final token = await TokenStorage.getToken();
    return {
      "Content-Type": "application/json",
      if (token != null) "Authorization": "Bearer $token",
    };
  }

  // Load from backend
  Future<void> initializeForUser(String customerId) async {
    _customerId = customerId;
    await Future.wait([
      _loadCartFromServer(),
      _loadWishlistFromServer(),
    ]);
    notifyListeners();
  }

  Future<void> _loadCartFromServer() async {
    debugPrint("_loadCartFromServer: customerId=$_customerId");
    if (_customerId == null) return;
    try {
      final uri = Uri.parse("${ApiConstants.baseUrl}/api/customers/$_customerId/cart");
      debugPrint("_loadCartFromServer: GET $uri");
      final response = await http.get(uri, headers: await _headers());
      debugPrint("_loadCartFromServer: response status=${response.statusCode}, body=${response.body}");
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
        _items.clear();
        for (var json in data) {
          _items.add(CartItem(
            id: json["id"],
            product: Product.fromJson(json["product"]),
            size: json["size"] ?? "M",
            color: json["color"] ?? "White",
            quantity: json["quantity"] ?? 1,
          ));
        }
        debugPrint("_loadCartFromServer completed: loaded ${_items.length} items");
      }
    } catch (e) {
      debugPrint("Lỗi tải giỏ hàng: $e");
    }
  }

  Future<void> _loadWishlistFromServer() async {
    debugPrint("_loadWishlistFromServer: customerId=$_customerId");
    if (_customerId == null) return;
    try {
      final uri = Uri.parse("${ApiConstants.baseUrl}/api/customers/$_customerId/wishlist");
      debugPrint("_loadWishlistFromServer: GET $uri");
      final response = await http.get(uri, headers: await _headers());
      debugPrint("_loadWishlistFromServer: response status=${response.statusCode}, body=${response.body}");
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
        _wishlist.clear();
        for (var json in data) {
          _wishlist.add(Product.fromJson(json));
        }
        debugPrint("_loadWishlistFromServer completed: loaded ${_wishlist.length} items");
      }
    } catch (e) {
      debugPrint("Lỗi tải danh sách yêu thích: $e");
    }
  }

  void addToCart(Product product, String size, String color, {int qty = 1}) async {
    debugPrint("addToCart: product=${product.productName}, size=$size, color=$color, qty=$qty, customerId=$_customerId");
    if (_customerId != null) {
      try {
        final uri = Uri.parse("${ApiConstants.baseUrl}/api/customers/$_customerId/cart")
            .replace(queryParameters: {
          "productId": product.id,
          "quantity": qty.toString(),
          "size": size,
          "color": color,
        });
        debugPrint("addToCart: POST to $uri");
        final response = await http.post(uri, headers: await _headers());
        debugPrint("addToCart: response status=${response.statusCode}, body=${response.body}");
        if (response.statusCode == 200) {
          await _loadCartFromServer();
          notifyListeners();
          return;
        } else {
          debugPrint("addToCart backend failed, status code ${response.statusCode}");
        }
      } catch (e) {
        debugPrint("Lỗi thêm vào giỏ hàng trên DB: $e");
      }
    }
    
    // Fallback locally
    for (var item in _items) {
      if (item.product.id == product.id && item.size == size && item.color == color) {
        item.quantity += qty;
        notifyListeners();
        return;
      }
    }
    _items.add(CartItem(product: product, size: size, color: color, quantity: qty));
    notifyListeners();
  }

  void incrementQuantity(int index) async {
    if (index >= 0 && index < _items.length) {
      final item = _items[index];
      if (_customerId != null && item.id != null) {
        try {
          final uri = Uri.parse("${ApiConstants.baseUrl}/api/customers/cart/items/${item.id}")
              .replace(queryParameters: {"quantity": (item.quantity + 1).toString()});
          final response = await http.put(uri, headers: await _headers());
          if (response.statusCode == 200) {
            await _loadCartFromServer();
            notifyListeners();
            return;
          }
        } catch (e) {
          debugPrint("Lỗi tăng số lượng trên DB: $e");
        }
      }

      _items[index].quantity++;
      notifyListeners();
    }
  }

  void decrementQuantity(int index) async {
    if (index >= 0 && index < _items.length) {
      final item = _items[index];
      if (_customerId != null && item.id != null) {
        try {
          final uri = Uri.parse("${ApiConstants.baseUrl}/api/customers/cart/items/${item.id}")
              .replace(queryParameters: {"quantity": (item.quantity - 1).toString()});
          final response = await http.put(uri, headers: await _headers());
          if (response.statusCode == 200) {
            await _loadCartFromServer();
            notifyListeners();
            return;
          }
        } catch (e) {
          debugPrint("Lỗi giảm số lượng trên DB: $e");
        }
      }

      if (_items[index].quantity > 1) {
        _items[index].quantity--;
      } else {
        _items.removeAt(index);
      }
      notifyListeners();
    }
  }

  void removeFromCart(int index) async {
    if (index >= 0 && index < _items.length) {
      final item = _items[index];
      if (_customerId != null && item.id != null) {
        try {
          final uri = Uri.parse("${ApiConstants.baseUrl}/api/customers/cart/items/${item.id}");
          final response = await http.delete(uri, headers: await _headers());
          if (response.statusCode == 200) {
            await _loadCartFromServer();
            notifyListeners();
            return;
          }
        } catch (e) {
          debugPrint("Lỗi xóa sản phẩm khỏi giỏ hàng trên DB: $e");
        }
      }

      _items.removeAt(index);
      notifyListeners();
    }
  }

  void clearCart() async {
    if (_customerId != null) {
      try {
        final uri = Uri.parse("${ApiConstants.baseUrl}/api/customers/$_customerId/cart/clear");
        final response = await http.delete(uri, headers: await _headers());
        if (response.statusCode == 200) {
          await _loadCartFromServer();
          _appliedPromoCode = null;
          _discountPercent = 0;
          notifyListeners();
          return;
        }
      } catch (e) {
        debugPrint("Lỗi xóa sạch giỏ hàng trên DB: $e");
      }
    }

    _items.clear();
    _appliedPromoCode = null;
    _discountPercent = 0;
    notifyListeners();
  }

  double get subtotal {
    double sum = 0;
    for (var item in _items) {
      double price = item.product.discountPrice > 0 
          ? item.product.discountPrice 
          : item.product.regularPrice;
      sum += price * item.quantity;
    }
    return sum;
  }

  double get deliveryFee {
    if (_items.isEmpty) return 0;
    return subtotal > 500000 ? 0 : 30000;
  }

  double get discountAmount {
    return (subtotal * _discountPercent) / 100;
  }

  double get total {
    if (_items.isEmpty) return 0;
    return subtotal + deliveryFee - discountAmount;
  }

  void applyPromoCode(String code, int percent) {
    _appliedPromoCode = code;
    _discountPercent = percent;
    notifyListeners();
  }

  void removePromoCode() {
    _appliedPromoCode = null;
    _discountPercent = 0;
    notifyListeners();
  }

  // Wishlist / Favorites
  void toggleFavorite(Product product) async {
    final isFav = _wishlist.any((p) => p.id == product.id);
    debugPrint("toggleFavorite: product=${product.productName}, isFav=$isFav, customerId=$_customerId");
    if (_customerId != null) {
      try {
        final uri = Uri.parse("${ApiConstants.baseUrl}/api/customers/$_customerId/wishlist")
            .replace(queryParameters: {"productId": product.id});
        debugPrint("toggleFavorite: call ${isFav ? 'DELETE' : 'POST'} to $uri");
        final response = isFav 
            ? await http.delete(uri, headers: await _headers())
            : await http.post(uri, headers: await _headers());
        debugPrint("toggleFavorite: response status=${response.statusCode}, body=${response.body}");
        if (response.statusCode == 200) {
          await _loadWishlistFromServer();
          notifyListeners();
          return;
        } else {
          debugPrint("toggleFavorite backend failed, status code ${response.statusCode}");
        }
      } catch (e) {
        debugPrint("Lỗi cập nhật yêu thích trên DB: $e");
      }
    }

    if (isFav) {
      _wishlist.removeWhere((p) => p.id == product.id);
    } else {
      _wishlist.add(product);
    }
    notifyListeners();
  }

  bool isFavorite(Product product) {
    return _wishlist.any((p) => p.id == product.id);
  }

  // Checkout choices
  void selectAddress(Map<String, dynamic> address) {
    _selectedAddress = address;
    notifyListeners();
  }

  void selectShippingMethod(String method) {
    _selectedShippingMethod = method;
    notifyListeners();
  }

  void selectPaymentCard(Map<String, dynamic> card) {
    _selectedPaymentCard = card;
    notifyListeners();
  }
}
