import 'package:flutter/material.dart';

class FiltersScreen extends StatefulWidget {
  final double initialMinPrice;
  final double initialMaxPrice;
  final String? initialSize;
  final String? initialColor;
  final String? initialSort;

  const FiltersScreen({
    super.key,
    required this.initialMinPrice,
    required this.initialMaxPrice,
    this.initialSize,
    this.initialColor,
    this.initialSort,
  });

  @override
  State<FiltersScreen> createState() => _FiltersScreenState();
}

class _FiltersScreenState extends State<FiltersScreen> {
  late RangeValues _priceRange;
  String? _selectedSize;
  String? _selectedColor;
  String? _selectedSort;

  final List<String> _sizes = ["XS", "S", "M", "L", "XL"];
  final List<Map<String, dynamic>> _colors = [
    {"name": "Black", "color": Colors.black},
    {"name": "White", "color": Colors.white},
    {"name": "Red", "color": Colors.red},
    {"name": "Grey", "color": Colors.grey},
    {"name": "Yellow", "color": Colors.amber},
  ];

  @override
  void initState() {
    super.initState();
    _priceRange = RangeValues(widget.initialMinPrice, widget.initialMaxPrice);
    _selectedSize = widget.initialSize;
    _selectedColor = widget.initialColor;
    _selectedSort = widget.initialSort;
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xffDB3022);

    return Scaffold(
      backgroundColor: const Color(0xffF9F9F9),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Filters",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                _priceRange = const RangeValues(0, 2000000);
                _selectedSize = null;
                _selectedColor = null;
                _selectedSort = null;
              });
            },
            child: const Text(
              "Clear",
              style: TextStyle(color: Colors.black87, fontSize: 16),
            ),
          )
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Price section
                const Text(
                  "Khoảng giá",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("${_priceRange.start.toInt()}đ"),
                    Text("${_priceRange.end.toInt()}đ"),
                  ],
                ),
                RangeSlider(
                  values: _priceRange,
                  min: 0,
                  max: 2000000,
                  divisions: 20,
                  activeColor: primaryColor,
                  inactiveColor: Colors.grey[300],
                  labels: RangeLabels(
                    "${_priceRange.start.toInt()}đ",
                    "${_priceRange.end.toInt()}đ",
                  ),
                  onChanged: (RangeValues values) {
                    setState(() {
                      _priceRange = values;
                    });
                  },
                ),
                const Divider(height: 32),

                // Colors section
                const Text(
                  "Màu sắc",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 50,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _colors.length,
                    itemBuilder: (context, index) {
                      final item = _colors[index];
                      final name = item["name"] as String;
                      final colorVal = item["color"] as Color;
                      final isSelected = _selectedColor == name;

                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedColor = isSelected ? null : name;
                          });
                        },
                        child: Container(
                          margin: const EdgeInsets.only(right: 16),
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: colorVal,
                            border: Border.all(
                              color: isSelected ? primaryColor : Colors.grey.shade300,
                              width: isSelected ? 3 : 1,
                            ),
                          ),
                          child: isSelected
                              ? Icon(
                                  Icons.check,
                                  color: colorVal == Colors.white ? Colors.black : Colors.white,
                                )
                              : null,
                        ),
                      );
                    },
                  ),
                ),
                const Divider(height: 32),

                // Sizes section
                const Text(
                  "Kích cỡ",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 12,
                  children: _sizes.map((size) {
                    final isSelected = _selectedSize == size;
                    return ChoiceChip(
                      label: Text(size),
                      selected: isSelected,
                      selectedColor: primaryColor,
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : Colors.black,
                        fontWeight: FontWeight.w600,
                      ),
                      onSelected: (selected) {
                        setState(() {
                          _selectedSize = selected ? size : null;
                        });
                      },
                    );
                  }).toList(),
                ),
                const Divider(height: 32),

                // Sort section
                const Text(
                  "Sắp xếp theo",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: _selectedSort,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  items: const [
                    DropdownMenuItem(value: "newest", child: Text("Mới nhất (Newest)")),
                    DropdownMenuItem(value: "price_low", child: Text("Giá thấp -> cao (Low to High)")),
                    DropdownMenuItem(value: "price_high", child: Text("Giá cao -> thấp (High to Low)")),
                  ],
                  hint: const Text("Chọn kiểu sắp xếp"),
                  onChanged: (val) {
                    setState(() {
                      _selectedSort = val;
                    });
                  },
                ),
              ],
            ),
          ),
          
          // Action Buttons
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: const BorderSide(color: Colors.black54),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                    child: const Text(
                      "HỦY",
                      style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context, {
                        "minPrice": _priceRange.start,
                        "maxPrice": _priceRange.end,
                        "size": _selectedSize,
                        "color": _selectedColor,
                        "sort": _selectedSort,
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                    child: const Text(
                      "ÁP DỤNG",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
