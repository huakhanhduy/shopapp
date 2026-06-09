import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../models/review.dart';
import '../../services/review_service.dart';
import '../../core/widgets/image_helper.dart';
import '../../providers/auth_provider.dart';
import 'write_review_dialog.dart';

class ReviewsListScreen extends StatefulWidget {
  final String productId;
  final String productName;

  const ReviewsListScreen({
    super.key,
    required this.productId,
    required this.productName,
  });

  @override
  State<ReviewsListScreen> createState() => _ReviewsListScreenState();
}

class _ReviewsListScreenState extends State<ReviewsListScreen> {
  late Future<List<Review>> _reviewsFuture;
  bool _filterWithPhoto = false;

  @override
  void initState() {
    super.initState();
    _loadReviews();
  }

  void _loadReviews() {
    _reviewsFuture = ReviewService().getReviews(widget.productId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Rating and reviews",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
      ),
      body: FutureBuilder<List<Review>>(
        future: _reviewsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text("Error loading reviews: ${snapshot.error}"));
          }

          final reviews = snapshot.data ?? [];
          final filteredReviews = _filterWithPhoto
              ? reviews.where((r) => r.images.isNotEmpty).toList()
              : reviews;

          // Calculate breakdown stats
          int totalRatings = reviews.length;
          double avgRating = 0;
          Map<int, int> counts = {5: 0, 4: 0, 3: 0, 2: 0, 1: 0};
          
          if (totalRatings > 0) {
            double sum = 0;
            for (var r in reviews) {
              int star = r.rating.clamp(1, 5);
              counts[star] = (counts[star] ?? 0) + 1;
              sum += r.rating;
            }
            avgRating = sum / totalRatings;
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                
                // Score breakdown block
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Large Score Column
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            totalRatings > 0 ? avgRating.toStringAsFixed(1) : "0.0",
                            style: const TextStyle(
                              fontSize: 52,
                              fontWeight: FontWeight.bold,
                              letterSpacing: -1,
                            ),
                          ),
                          Text(
                            "$totalRatings ratings",
                            style: const TextStyle(color: Colors.grey, fontSize: 13),
                          ),
                        ],
                      ),
                      
                      const SizedBox(width: 24),
                      
                      // Bar Charts Column
                      Expanded(
                        child: Column(
                          children: List.generate(5, (index) {
                            int starNum = 5 - index;
                            int count = counts[starNum] ?? 0;
                            double percent = totalRatings > 0 ? count / totalRatings : 0.0;

                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 2.5),
                              child: Row(
                                children: [
                                  // Stars row
                                  Row(
                                    children: List.generate(5, (sIdx) {
                                      return Icon(
                                        Icons.star,
                                        color: sIdx < starNum ? Colors.amber : Colors.transparent,
                                        size: 13,
                                      );
                                    }),
                                  ),
                                  const SizedBox(width: 8),
                                  
                                  // Red progress bar
                                  Expanded(
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(3),
                                      child: LinearProgressIndicator(
                                        value: percent,
                                        minHeight: 8,
                                        backgroundColor: Colors.grey[200],
                                        valueColor: const AlwaysStoppedAnimation<Color>(Color(0xffDB3022)),
                                      ),
                                    ),
                                  ),
                                  
                                  const SizedBox(width: 12),
                                  
                                  // Value text
                                  SizedBox(
                                    width: 18,
                                    child: Text(
                                      "$count",
                                      textAlign: TextAlign.right,
                                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }),
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 24),

                // Review List Title & Filter Header
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "${filteredReviews.length} reviews",
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Row(
                        children: [
                          Checkbox(
                            value: _filterWithPhoto,
                            activeColor: const Color(0xffDB3022),
                            onChanged: (val) {
                              setState(() {
                                _filterWithPhoto = val ?? false;
                              });
                            },
                          ),
                          const Text("With photo", style: TextStyle(fontSize: 14)),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                // Reviews List
                filteredReviews.isEmpty
                    ? const Padding(
                        padding: EdgeInsets.symmetric(vertical: 40, horizontal: 16),
                        child: Center(
                          child: Text(
                            "No reviews found.",
                            style: TextStyle(color: Colors.grey, fontSize: 15),
                          ),
                        ),
                      )
                    : ListView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: filteredReviews.length,
                        itemBuilder: (context, index) {
                          final rev = filteredReviews[index];
                          return _buildReviewItem(rev);
                        },
                      ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FutureBuilder<List<Review>>(
        future: _reviewsFuture,
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const SizedBox.shrink();
          
          final reviews = snapshot.data ?? [];
          final authProvider = Provider.of<AuthProvider>(context, listen: false);
          final currentCustomerId = authProvider.customerId;
          final currentEmail = authProvider.userProfile?['email'];
          
          final hasReviewed = (currentCustomerId != null && currentCustomerId.isNotEmpty && reviews.any((r) => r.customerId == currentCustomerId)) ||
              (currentEmail != null && currentEmail.isNotEmpty && reviews.any((r) => r.customerEmail == currentEmail));
          
          if (hasReviewed) {
            return const SizedBox.shrink();
          }
          
          return FloatingActionButton.extended(
            onPressed: () async {
              final result = await showDialog(
                context: context,
                builder: (_) => WriteReviewDialog(productId: widget.productId),
              );
              if (result == true) {
                setState(() {
                  _loadReviews();
                });
              }
            },
            backgroundColor: const Color(0xffDB3022),
            elevation: 4,
            icon: const Icon(Icons.edit, color: Colors.white, size: 20),
            label: const Text(
              "Write a review",
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          );
        },
      ),
    );
  }

  Widget _buildReviewItem(Review review) {
    String formattedDate = DateFormat('MMMM d, y').format(review.createdAt);

    return Stack(
      children: [
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            boxShadow: const [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 4,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                review.userName,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
              const SizedBox(height: 4),
              
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: List.generate(5, (index) {
                      return Icon(
                        index < review.rating ? Icons.star : Icons.star_border,
                        color: Colors.amber,
                        size: 16,
                      );
                    }),
                  ),
                  Text(
                    formattedDate,
                    style: const TextStyle(color: Colors.grey, fontSize: 11),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              Text(
                review.comment,
                style: const TextStyle(fontSize: 14, height: 1.4, color: Colors.black87),
              ),
              
              // Attachment images preview
              if (review.images.isNotEmpty) ...[
                const SizedBox(height: 14),
                SizedBox(
                  height: 100,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: review.images.length,
                    itemBuilder: (context, idx) {
                      final imgPath = review.images[idx];
                      return Container(
                        width: 80,
                        margin: const EdgeInsets.only(right: 10),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: buildProductImage(imgPath, fit: BoxFit.cover),
                        ),
                      );
                    },
                  ),
                ),
              ],

              const SizedBox(height: 14),
              
              // Helpful button
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  const Text("Helpful", style: TextStyle(color: Colors.grey, fontSize: 12)),
                  const SizedBox(width: 4),
                  IconButton(
                    icon: const Icon(Icons.thumb_up, size: 16, color: Colors.grey),
                    onPressed: () {},
                  ),
                ],
              ),
            ],
          ),
        ),
        
        // Avatar circle mockup
        Positioned(
          left: 4,
          top: 0,
          child: Container(
            padding: const EdgeInsets.all(2),
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: CircleAvatar(
              radius: 18,
              backgroundColor: Colors.grey[200],
              child: Text(
                review.userName.isNotEmpty ? review.userName[0].toUpperCase() : 'A',
                style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black54),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
