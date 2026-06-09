import 'package:flutter/material.dart';

class SizeBottomSheet extends StatefulWidget {
  final String? selectedSize;
  final Function(String) onSizeSelected;

  const SizeBottomSheet({
    super.key,
    this.selectedSize,
    required this.onSizeSelected,
  });

  @override
  State<SizeBottomSheet> createState() => _SizeBottomSheetState();
}

class _SizeBottomSheetState extends State<SizeBottomSheet> {
  late String? _selected;

  final List<String> sizes = ["XS", "S", "M", "L", "XL"];

  @override
  void initState() {
    super.initState();
    _selected = widget.selectedSize;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(24),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            width: 48,
            height: 5,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(10),
            ),
          ),

          const SizedBox(height: 20),

          const Text(
            "Select size",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 20),

          // Size grid
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: sizes.map((size) {
              final isSelected = _selected == size;
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selected = size;
                  });
                },
                child: Container(
                  width: (MediaQuery.of(context).size.width - 72) / 3,
                  height: 48,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color(0xffDB3022)
                        : Colors.white,
                    border: Border.all(
                      color: isSelected
                          ? const Color(0xffDB3022)
                          : Colors.grey.shade300,
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    size,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: isSelected
                          ? Colors.white
                          : Colors.black,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 20),

          // Size info
          const Divider(),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text(
              "Size info",
              style: TextStyle(fontSize: 16),
            ),
            trailing: const Icon(
              Icons.chevron_right,
            ),
            onTap: () {},
          ),
          const Divider(),

          const SizedBox(height: 16),

          // Add to cart button
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: _selected != null
                  ? () {
                      widget.onSizeSelected(_selected!);
                      Navigator.pop(context);
                    }
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xffDB3022),
                disabledBackgroundColor: Colors.grey.shade300,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(26),
                ),
              ),
              child: const Text(
                "ADD TO CART",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
