import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'catalog_screen.dart';

class VisualSearchScreen extends StatefulWidget {
  const VisualSearchScreen({super.key});

  @override
  State<VisualSearchScreen> createState() => _VisualSearchScreenState();
}

class _VisualSearchScreenState extends State<VisualSearchScreen> {
  final ImagePicker _picker = ImagePicker();
  bool _isAnalyzing = false;

  Future<void> _processImage(XFile? image) async {
    if (image == null) return;

    setState(() {
      _isAnalyzing = true;
    });

    // Simulate sending image to backend for visual search
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    setState(() {
      _isAnalyzing = false;
    });

    // Navigate to CatalogScreen with visual search results (Category ID "visual_search")
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => const CatalogScreen(
          categoryId: "visual_search",
          categoryName: "Kết quả tìm kiếm ảnh",
        ),
      ),
    );
  }

  void _takePhoto() async {
    final XFile? photo = await _picker.pickImage(source: ImageSource.camera);
    _processImage(photo);
  }

  void _uploadImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    _processImage(image);
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xffDB3022);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Tìm kiếm bằng hình ảnh",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          // Background instruction card
          Positioned.fill(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.camera_alt_outlined,
                  color: Colors.white38,
                  size: 100,
                ),
                const SizedBox(height: 24),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 40),
                  child: Text(
                    "Chụp ảnh trang phục hoặc tải ảnh lên để tìm các sản phẩm tương tự trong cửa hàng của chúng tôi.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      height: 1.5,
                    ),
                  ),
                ),
                const SizedBox(height: 60),
                
                // Take photo button
                SizedBox(
                  width: 250,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: _takePhoto,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                    child: const Text(
                      "CHỤP ẢNH",
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Upload image button
                SizedBox(
                  width: 250,
                  height: 48,
                  child: OutlinedButton(
                    onPressed: _uploadImage,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: const BorderSide(color: Colors.white, width: 2),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                    child: const Text(
                      "TẢI ẢNH LÊN",
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Glassmorphic scanning screen overlay
          if (_isAnalyzing)
            Positioned.fill(
              child: Container(
                color: Colors.black.withOpacity(0.85),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Scanning animation mock
                      SizedBox(
                        width: 150,
                        height: 150,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            const Icon(
                              Icons.center_focus_strong,
                              color: primaryColor,
                              size: 100,
                            ),
                            Positioned(
                              top: 20,
                              child: Container(
                                width: 110,
                                height: 4,
                                color: Colors.greenAccent,
                                // Animates in real app, we use pulse in UI
                              ),
                            ),
                            const CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                              strokeWidth: 4,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        "Đang tìm kết quả tương tự...",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        "Finding similar results...",
                        style: TextStyle(
                          color: Colors.white54,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
