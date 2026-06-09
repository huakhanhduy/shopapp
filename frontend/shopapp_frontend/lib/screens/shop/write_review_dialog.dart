import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../services/review_service.dart';

class WriteReviewDialog extends StatefulWidget {
  final String productId;

  const WriteReviewDialog({super.key, required this.productId});

  @override
  State<WriteReviewDialog> createState() => _WriteReviewDialogState();
}

class _WriteReviewDialogState extends State<WriteReviewDialog> {
  int _selectedRating = 0;
  final TextEditingController _commentController = TextEditingController();
  final List<XFile> _selectedImages = [];
  final Map<String, Uint8List> _imageBytes = {};
  final ImagePicker _picker = ImagePicker();
  bool _loading = false;

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );
      if (image != null) {
        final bytes = await image.readAsBytes();
        setState(() {
          _selectedImages.add(image);
          _imageBytes[image.path] = bytes;
        });
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error picking image: $e")),
      );
    }
  }

  void _removeImage(int index) {
    final imageFile = _selectedImages[index];
    setState(() {
      _selectedImages.removeAt(index);
      _imageBytes.remove(imageFile.path);
    });
  }

  Future<void> _submitReview() async {
    if (_selectedRating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select a rating")),
      );
      return;
    }

    if (_commentController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please share your opinion about the product")),
      );
      return;
    }

    setState(() => _loading = true);

    try {
      await ReviewService().createReview(
        productId: widget.productId,
        rating: _selectedRating,
        comment: _commentController.text.trim(),
        images: _selectedImages,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Review posted successfully!")),
      );
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceAll("Exception: ", ""))),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
      elevation: 16,
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Top drag/indicator line mockup
                Container(
                  width: 60,
                  height: 6,
                  decoration: BoxDecoration(
                    color: Colors.grey[350],
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
                
                const SizedBox(height: 24),

                // Title 1
                const Text(
                  "What is you rate?",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                  ),
                ),
                
                const SizedBox(height: 16),

                // Star Picker
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(5, (index) {
                    int starValue = index + 1;
                    return IconButton(
                      icon: Icon(
                        starValue <= _selectedRating ? Icons.star : Icons.star_border,
                        size: 40,
                      ),
                      color: starValue <= _selectedRating ? Colors.amber : Colors.grey[300],
                      onPressed: () {
                        setState(() {
                          _selectedRating = starValue;
                        });
                      },
                    );
                  }),
                ),

                const SizedBox(height: 24),

                // Title 2
                const Text(
                  "Please share your opinion\nabout the product",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    height: 1.3,
                  ),
                ),
                
                const SizedBox(height: 18),

                // Comment Text Field Card
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 8,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _commentController,
                    maxLines: 5,
                    decoration: const InputDecoration(
                      hintText: "I'm super happy with these! I've never bought jeans online before...",
                      hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
                      contentPadding: EdgeInsets.all(16),
                      border: InputBorder.none,
                    ),
                  ),
                ),
                
                const SizedBox(height: 24),

                // Image Upload/Removal row
                SizedBox(
                  height: 90,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _selectedImages.length + 1,
                    itemBuilder: (context, index) {
                      if (index == _selectedImages.length) {
                        // Camera Button
                        return GestureDetector(
                          onTap: _pickImage,
                          child: Container(
                            width: 80,
                            margin: const EdgeInsets.only(right: 8),
                            decoration: BoxDecoration(
                              color: Colors.grey[50],
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.grey[200]!),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                CircleAvatar(
                                  radius: 20,
                                  backgroundColor: const Color(0xffDB3022),
                                  child: const Icon(Icons.camera_alt, color: Colors.white, size: 18),
                                ),
                                const SizedBox(height: 6),
                                const Text(
                                  "Add your photos",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                        );
                      }
                      
                      // Uploaded image thumbnail with X delete
                      final imgFile = _selectedImages[index];
                      final bytes = _imageBytes[imgFile.path];
                      return Stack(
                        children: [
                          Container(
                            width: 80,
                            margin: const EdgeInsets.only(right: 8),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              image: bytes != null
                                  ? DecorationImage(
                                      image: MemoryImage(bytes),
                                      fit: BoxFit.cover,
                                    )
                                  : null,
                            ),
                            child: bytes == null
                                ? const Center(child: CircularProgressIndicator())
                                : null,
                          ),
                          Positioned(
                            top: 4,
                            right: 12,
                            child: GestureDetector(
                              onTap: () => _removeImage(index),
                              child: Container(
                                padding: const EdgeInsets.all(2),
                                decoration: const BoxDecoration(
                                  color: Colors.black54,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.close, color: Colors.white, size: 12),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),

                const SizedBox(height: 28),

                // Submit Button
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _loading ? null : _submitReview,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xffDB3022),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(26),
                      ),
                      elevation: 3,
                    ),
                    child: _loading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            "SEND REVIEW",
                            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: Colors.white),
                          ),
                  ),
                ),
              ],
            ),
          ),
          
          // Close button at top right
          Positioned(
            top: 8,
            right: 8,
            child: IconButton(
              icon: const Icon(Icons.close, color: Colors.black54),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ],
      ),
    );
  }
}
