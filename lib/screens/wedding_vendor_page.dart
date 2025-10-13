import 'package:flutter/material.dart';
import 'package:wedding_planner/screens/select_package_page.dart';
import 'package:wedding_planner/screens/chat_detail_screen.dart';
import 'package:wedding_planner/services/review_service.dart';
import 'package:http/http.dart' as http;
import 'package:wedding_planner/config/api_config.dart';
import 'dart:convert';

import 'package:wedding_planner/widgets/rating_dialog%20.dart';

class WeddingVendorPage extends StatefulWidget {
  final Map<String, dynamic> service;

  WeddingVendorPage({required this.service});

  @override
  _WeddingVendorPageState createState() => _WeddingVendorPageState();
}

class _WeddingVendorPageState extends State<WeddingVendorPage> {
  late Future<List<dynamic>> _packagesFuture;
  late Future<List<dynamic>> _reviewsFuture;
  int dealsCompleted = 0;
  String joinDate = '';
  double averageRating = 0.0;
  int reviewCount = 0;
  String address = 'Not specified';

  @override
  void initState() {
    super.initState();
    _packagesFuture = _fetchPackages();
    _reviewsFuture = ReviewService().getReviews(widget.service['vendorId']);
    _fetchVendorDetails();
  }

  Future<List<dynamic>> _fetchPackages() async {
    try {
      final headers = await ApiConfig.getAuthHeaders();
      final response = await http.get(
        Uri.parse('${ApiConfig.userEndpoint}/packages'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final packages = data['packages'] ?? [];
        final filteredPackages = packages
            .where((pkg) => pkg['serviceId'] == widget.service['_id'])
            .toList();
        
        return filteredPackages;
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  Future<void> _fetchVendorDetails() async {
    try {
      final headers = await ApiConfig.getAuthHeaders();
      final response = await http.get(
        Uri.parse('${ApiConfig.userEndpoint}/vendor-profile/${widget.service['vendorId']}'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        setState(() {
          dealsCompleted = data['vendor']['dealsCompleted'] ?? 0;
          joinDate = _formatJoinDate(data['vendor']['createdAt']);
          address = data['vendor']['address'] ?? widget.service['address'] ?? 'Address not provided';
        });
      } else {
        // Fallback to service data if vendor profile fetch fails
        setState(() {
          address = widget.service['address'] ?? 'Address not provided';
          joinDate = _formatJoinDate(widget.service['createdAt']);
        });
      }
    } catch (e) {
      // Fallback to service data
      setState(() {
        address = widget.service['address'] ?? 'Address not provided';
        joinDate = _formatJoinDate(widget.service['createdAt']);
      });
    }
  }

  // Calculate average rating from reviews
  void _calculateRatingFromReviews(List<dynamic> reviews) {
    if (reviews.isEmpty) {
      setState(() {
        averageRating = 0.0;
        reviewCount = 0;
      });
      return;
    }

    double totalRating = 0.0;
    int validReviews = 0;

    for (var review in reviews) {
      final rating = _parseRating(review['rating']);
      if (rating > 0) {
        totalRating += rating;
        validReviews++;
      }
    }

    setState(() {
      averageRating = validReviews > 0 ? totalRating / validReviews : 0.0;
      reviewCount = validReviews;
    });
  }

  String _formatJoinDate(String? dateString) {
    if (dateString == null) return 'Unknown';
    try {
      final date = DateTime.parse(dateString);
      return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
    } catch (e) {
      return 'Unknown';
    }
  }

  @override
  Widget build(BuildContext context) {
    final mediaUrls = widget.service['mediaUrls'] as List<dynamic>? ?? [];
    final vendorName = widget.service['vendorName'] ?? '';
    final serviceName = widget.service['serviceName'] ?? '';
    final description = widget.service['description'] ?? '';
    final paymentPolicy = widget.service['paymentPolicy'] ?? '';
    final phone = widget.service['phone'] ?? 'Not available';

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 250,
            pinned: true,
            leading: IconButton(
              icon: Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              IconButton(
                icon: Icon(Icons.favorite_border, color: Colors.white),
                onPressed: () {},
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF00E7AC), Color(0xFF00B8E4)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  image: DecorationImage(
                    image:
                        mediaUrls.isNotEmpty && mediaUrls[0] != null
                            ? NetworkImage(mediaUrls[0])
                            : AssetImage('assets/images/couple.jpg')
                                as ImageProvider,
                    fit: BoxFit.cover,
                    colorFilter: ColorFilter.mode(
                      Colors.black.withOpacity(0.3),
                      BlendMode.darken,
                    ),
                  ),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.7),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Container(
              color: Colors.white,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          serviceName,
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(Icons.person, color: Colors.grey, size: 16),
                            SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                vendorName,
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.location_on,
                              color: Colors.grey,
                              size: 16,
                            ),
                            SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                address,
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(Icons.phone, color: Colors.grey, size: 16),
                            SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                phone,
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.calendar_today,
                              color: Colors.grey,
                              size: 16,
                            ),
                            SizedBox(width: 4),
                            Text(
                              'On Archadul since $joinDate',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(Icons.verified, color: Colors.blue, size: 16),
                            SizedBox(width: 4),
                            Text(
                              'No. of Deals Completed: $dealsCompleted',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.attach_money,
                              color: Colors.grey,
                              size: 16,
                            ),
                            SizedBox(width: 4),
                            Text(
                              widget.service['basePrice'] != null
                                  ? '${widget.service['basePrice']}LKR per day'
                                  : 'Price not specified',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(Icons.star, color: Colors.orange, size: 20),
                            SizedBox(width: 4),
                            Text(
                              averageRating > 0 
                                  ? '${averageRating.toStringAsFixed(1)} ($reviewCount ${reviewCount == 1 ? 'review' : 'reviews'})'
                                  : 'No ratings yet',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (_) => ChatDetailScreen(
                                          otherUserId:
                                              widget.service['vendorId'],
                                          otherUserName:
                                              widget.service['vendorName'],
                                        ),
                                  ),
                                );
                              },
                              child: Text(
                                'Message Vendor',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                                padding: EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 12,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Divider(),
                  Container(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Description',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          description.isNotEmpty
                              ? description
                              : 'No description provided',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Divider(),
                  Container(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Payment Policy',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          paymentPolicy.isNotEmpty
                              ? paymentPolicy
                              : 'No payment policy provided',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Divider(),
                  Container(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Packages',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 12),
                        FutureBuilder<List<dynamic>>(
                          future: _packagesFuture,
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return Center(child: CircularProgressIndicator());
                            } else if (snapshot.hasError) {
                              return Text('Error loading packages: ${snapshot.error}');
                            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                              return Text('No packages available.');
                            }
                            
                            return Column(
                              children: snapshot.data!.map<Widget>((pkg) {
                                return Padding(
                                  padding: EdgeInsets.only(bottom: 12),
                                  child: _packageCard(
                                    pkg['packageName'] ?? 'Unnamed Package',
                                    pkg['packagePrice']?.toString() ?? '0',
                                    pkg['description'] ?? 'No description',
                                  ),
                                );
                              }).toList(),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  Divider(),
                  Container(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Reviews',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder:
                                      (context) => RatingDialog(
                                        vendorId: widget.service['vendorId'],
                                      ),
                                );
                              },
                              child: Text(
                                'Add Review',
                                style: TextStyle(color: Colors.blue),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 12),
                        FutureBuilder<List<dynamic>>(
                          future: _reviewsFuture,
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return Container(
                                height: 100,
                                child: Center(child: CircularProgressIndicator()),
                              );
                            } 
                            
                            if (snapshot.hasError) {
                              return Container(
                                padding: EdgeInsets.all(16),
                                child: Text(
                                  'Error loading reviews: ${snapshot.error}',
                                  style: TextStyle(color: Colors.red),
                                ),
                              );
                            }
                            
                            if (!snapshot.hasData || snapshot.data!.isEmpty) {
                              return Container(
                                padding: EdgeInsets.all(16),
                                child: Text(
                                  'No reviews yet. Be the first to leave a review!',
                                  style: TextStyle(color: Colors.grey[600]),
                                ),
                              );
                            }
                            
                            final reviews = snapshot.data!;
                            
                            // Calculate average rating when reviews are loaded
                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              _calculateRatingFromReviews(reviews);
                            });
                            
                            return Container(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Reviews summary
                                  Container(
                                    padding: EdgeInsets.symmetric(vertical: 8),
                                    child: Text(
                                      'Showing ${reviews.length} ${reviews.length == 1 ? 'review' : 'reviews'}',
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  // Reviews list
                                  ...reviews.map<Widget>((review) {
                                    final rating = _parseRating(review['rating']);
                                    final comment = review['comment']?.toString() ?? '';
                                    final userName = review['userId']?['name']?.toString() ?? 'Anonymous';
                                    final date = _formatReviewDate(review['createdAt']);
                                    
                                    return Container(
                                      margin: EdgeInsets.only(bottom: 12),
                                      child: _reviewCard(rating, comment, userName, date),
                                    );
                                  }).toList(),
                                ],
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  Divider(),
                  Container(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'FAQ\'s',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            TextButton(
                              onPressed: () {},
                              child: Text(
                                'See All',
                                style: TextStyle(color: Colors.blue),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 12),
                        _faqItem('Oct 14, 23', 'How to Add Budget of Wedding'),
                        SizedBox(height: 8),
                        _faqItem('Oct 14, 23', 'How to Add Budget of Wedding'),
                        SizedBox(height: 8),
                        _faqItem('Oct 14, 23', 'How to Add Budget of Wedding'),
                      ],
                    ),
                  ),
                  Divider(),
                  Container(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Advertisement',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 12),
                        Container(
                          height: 120,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            image: DecorationImage(
                              image: AssetImage('assets/ad_image.jpg'),
                              fit: BoxFit.cover,
                            ),
                          ),
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              gradient: LinearGradient(
                                colors: [
                                  Colors.transparent,
                                  Colors.black.withOpacity(0.7),
                                ],
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                'SPECTACULAR\nBACKGROUND',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Container(
            width: double.infinity,
            margin: EdgeInsets.symmetric(horizontal: 16),
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (_) => SelectPackagePage(
                          vendorId: widget.service['vendorId'],
                          serviceId: widget.service['_id'],
                          vendorName: widget.service['vendorName'],
                        ),
                  ),
                );
              },
              child: Text(
                'Select Package',
                style: TextStyle(
                  color: Colors.cyan,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.cyan,
                padding: EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: BorderSide(color: Colors.cyan),
                ),
                elevation: 2,
              ),
            ),
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  // Helper method to parse rating safely
  int _parseRating(dynamic rating) {
    if (rating == null) return 0;
    if (rating is int) return rating;
    if (rating is double) return rating.round();
    if (rating is String) {
      return int.tryParse(rating) ?? 0;
    }
    return 0;
  }

  Widget _socialMediaIcon(IconData icon, Color color, String url) {
    return GestureDetector(
      onTap: () {
        // Implement URL launching logic here, e.g., using url_launcher
      },
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        child: Icon(icon, color: Colors.white),
      ),
    );
  }

  Widget _packageCard(String title, String price, String description) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
              Text(
                'Rs $price',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.green,
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Text(
            description,
            style: TextStyle(color: Colors.grey[600], fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _reviewCard(int rating, String comment, String userName, String date) {
    return Card(
      elevation: 2,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Rating stars row
            Row(
              children: [
                // Generate star icons based on rating
                ...List.generate(5, (index) {
                  return Container(
                    margin: EdgeInsets.only(right: 2),
                    child: Icon(
                      index < rating ? Icons.star : Icons.star_outline,
                      color: index < rating ? Colors.amber : Colors.grey[400],
                      size: 20,
                    ),
                  );
                }),
                SizedBox(width: 8),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.orange[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '$rating/5',
                    style: TextStyle(
                      color: Colors.orange[800],
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            
            // Comment section
            if (comment.isNotEmpty) ...[
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  comment,
                  style: TextStyle(
                    color: Colors.grey[800],
                    fontSize: 14,
                    height: 1.5,
                  ),
                ),
              ),
            ] else ...[
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'No written review provided',
                  style: TextStyle(
                    color: Colors.grey[500],
                    fontSize: 14,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            ],
            
            SizedBox(height: 12),
            
            // User info row
            Row(
              children: [
                // User avatar
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.blue[400]!, Colors.blue[600]!],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Icon(
                    Icons.person,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                SizedBox(width: 12),
                
                // User name and date
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        userName.isNotEmpty ? userName : 'Anonymous User',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          color: Colors.grey[800],
                        ),
                      ),
                      SizedBox(height: 2),
                      Row(
                        children: [
                          Icon(
                            Icons.schedule,
                            size: 12,
                            color: Colors.grey[500],
                          ),
                          SizedBox(width: 4),
                          Text(
                            date,
                            style: TextStyle(
                              color: Colors.grey[500],
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                
                // Verified badge (optional)
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.green[100],
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.verified,
                        size: 12,
                        color: Colors.green[700],
                      ),
                      SizedBox(width: 2),
                      Text(
                        'Verified',
                        style: TextStyle(
                          color: Colors.green[700],
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatReviewDate(String? dateString) {
    if (dateString == null) return 'Unknown';
    try {
      final date = DateTime.parse(dateString);
      return '${date.day.toString().padLeft(2, '0')} ${getMonthName(date.month)}, ${date.year}';
    } catch (e) {
      return 'Unknown';
    }
  }

  String getMonthName(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return months[month - 1];
  }

  Widget _faqItem(String date, String question) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                date,
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
              ),
              SizedBox(height: 4),
              Text(
                question,
                style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
              ),
            ],
          ),
          Spacer(),
          Icon(Icons.keyboard_arrow_down, color: Colors.blue),
        ],
      ),
    );
  }
}