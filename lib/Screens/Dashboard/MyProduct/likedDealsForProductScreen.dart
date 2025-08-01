import 'package:flutter/material.dart';
import 'package:taptrade/Models/MyProductModel/myProductModel.dart';
import 'package:taptrade/Models/LikedProduct/likedProduct.dart';
import 'package:taptrade/Const/globleKey.dart';

class LikedDealsForProductScreen extends StatelessWidget {
  final Data product;
  final List<LikeData> likedDeals;

  const LikedDealsForProductScreen({
    Key? key,
    required this.product,
    required this.likedDeals,
  }) : super(key: key);

  // Remove duplicates based on otherProduct ID
  List<LikeData> get uniqueLikedDeals {
    final Set<int> seenIds = {};
    return likedDeals.where((deal) {
      if (deal.otherProduct?.id == null) return false;
      if (seenIds.contains(deal.otherProduct!.id)) return false;
      seenIds.add(deal.otherProduct!.id!);
      return true;
    }).toList();
  }

  // Helper method to get the correct image URL
  String? getImageUrl(LikeUserProduct? product) {
    if (product == null) return null;
    
    // Try different possible image field names
    String? imagePath = product.image;
    
    // Debug: Print the raw image data
    print('Raw image data: $imagePath');
    print('Product object: $product');
    
    // If image is null or empty, return null
    if (imagePath == null || imagePath.isEmpty) {
      print('Image path is null or empty');
      return null;
    }
    
    // If the image path already contains the full URL, return as is
    if (imagePath.startsWith('http')) {
      print('Image is already a full URL: $imagePath');
      return imagePath;
    }
    
    // Try different path formats
    List<String> possiblePaths = [
      imagePath,
      '/$imagePath',
      'media/$imagePath',
      'media/images/$imagePath',
      'static/$imagePath',
    ];
    
    for (String path in possiblePaths) {
      String testUrl = KeyConstants.imageUrl + path;
      print('Testing URL: $testUrl');
      // You can test these URLs in a browser to see which one works
    }
    
    // Remove leading slash if present to avoid double slashes
    if (imagePath.startsWith('/')) {
      imagePath = imagePath.substring(1);
    }
    
    // If the path doesn't start with 'media/', add it (common Django media structure)
    if (!imagePath.startsWith('media/')) {
      imagePath = 'media/$imagePath';
    }
    
    // Construct the full URL
    final fullUrl = KeyConstants.imageUrl + imagePath;
    print('Constructed image URL: $fullUrl');
    
    return fullUrl;
  }

  @override
  Widget build(BuildContext context) {
    final uniqueDeals = uniqueLikedDeals;
    
    // Debug: Print the total number of deals
    print('Total liked deals: ${likedDeals.length}');
    print('Unique deals: ${uniqueDeals.length}');
    
    return Scaffold(
      appBar: AppBar(
        title: Text(product.title ?? 'Product'),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        titleTextStyle: const TextStyle(
          color: Colors.black,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product details at the top
          Card(
            elevation: 4,
            margin: const EdgeInsets.fromLTRB(16, 24, 16, 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            child: Padding(
              padding: const EdgeInsets.all(22),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  (product.image != null && product.image!.isNotEmpty)
                      ? Container(
                          width: 90,
                          height: 90,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.blueGrey, width: 2.5),
                            image: DecorationImage(
                              image: NetworkImage(KeyConstants.imageUrl + product.image!),
                              fit: BoxFit.cover,
                              onError: (exception, stackTrace) {
                                // Handle image loading error
                              },
                            ),
                          ),
                        )
                      : CircleAvatar(
                          radius: 45,
                          backgroundColor: Colors.grey[200],
                          child: Icon(Icons.image, size: 44, color: Colors.grey[400]),
                        ),
                  const SizedBox(width: 28),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          product.title ?? '', 
                          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)
                        ),
                        const SizedBox(height: 12),
                        Text('Category: ${product.category ?? ''}', style: const TextStyle(fontSize: 17)),
                        const SizedBox(height: 6),
                        Text('Max Price: ${product.maxPrice ?? ''}', style: const TextStyle(fontSize: 17)),
                        const SizedBox(height: 6),
                        Text('Min Price: ${product.minPrice ?? ''}', style: const TextStyle(fontSize: 17)),
                        const SizedBox(height: 6),
                        Text('Status: ${product.status ?? ''}', style: const TextStyle(fontSize: 17)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              'Liked by these products (${uniqueDeals.length}):', 
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)
            ),
          ),
          Expanded(
            child: uniqueDeals.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.favorite_border, size: 64, color: Colors.grey),
                        SizedBox(height: 16),
                        Text(
                          'No liked deals for this product yet.',
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: uniqueDeals.length,
                    itemBuilder: (context, index) {
                      final deal = uniqueDeals[index];
                      final otherProduct = deal.otherProduct;
                      
                      if (otherProduct == null) return const SizedBox.shrink();
                      
                      // Debug: Print product info to console
                      print('Product ID: ${otherProduct.id}');
                      print('Product Title: ${otherProduct.title}');
                      print('Product Image: ${otherProduct.image}');
                      print('Product Category: ${otherProduct.category}');
                      print('Product Max Price: ${otherProduct.maxPrice}');
                      print('Product Min Price: ${otherProduct.minPrice}');
                      print('Product Status: ${otherProduct.status}');
                      print('Product User: ${otherProduct.user}');
                      print('Product Condition: ${otherProduct.productCondition}');
                      
                      // Debug: Print the entire deal object to see all available fields
                      print('Full deal object: $deal');
                      print('Full otherProduct object: $otherProduct');
                      
                      // Try to get image from different possible sources
                      String? imageUrl = getImageUrl(otherProduct);
                      
                      // If no image found, try alternative approaches
                      if (imageUrl == null) {
                        print('No image found in primary field, checking alternatives...');
                        // You might need to check if there are other fields in the API response
                        // For now, we'll use a placeholder
                        imageUrl = KeyConstants.imagePlaceHolder;
                      }
                      
                      // Test with a known working image to see if the loading mechanism works
                      // Uncomment the next line to test with a placeholder image
                      // imageUrl = 'https://via.placeholder.com/60x60?text=Test';
                      
                      return Card(
                        elevation: 2,
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                          child: Row(
                            children: [
                              // Product image with better error handling
                              Container(
                                width: 60,
                                height: 60,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.blueGrey, width: 1.5),
                                  color: Colors.grey[100],
                                ),
                                child: ClipOval(
                                  child: imageUrl != null
                                      ? Image.network(
                                          imageUrl,
                                          fit: BoxFit.cover,
                                          errorBuilder: (context, error, stackTrace) {
                                            print('Image loading error for $imageUrl: $error');
                                            return Container(
                                              color: Colors.grey[200],
                                              child: Icon(
                                                Icons.image,
                                                size: 30,
                                                color: Colors.grey[400],
                                              ),
                                            );
                                          },
                                          loadingBuilder: (context, child, loadingProgress) {
                                            if (loadingProgress == null) return child;
                                            return Container(
                                              color: Colors.grey[200],
                                              child: const Center(
                                                child: CircularProgressIndicator(
                                                  strokeWidth: 2,
                                                ),
                                              ),
                                            );
                                          },
                                        )
                                      : Container(
                                          color: Colors.grey[200],
                                          child: Icon(
                                            Icons.image,
                                            size: 30,
                                            color: Colors.grey[400],
                                          ),
                                        ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      otherProduct.title ?? 'No title', 
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold, 
                                        fontSize: 16
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 6),
                                    if (otherProduct.category != null)
                                      Text(
                                        'Category: ${otherProduct.category}', 
                                        style: const TextStyle(fontSize: 13, color: Colors.black54)
                                      ),
                                    if (otherProduct.maxPrice != null && otherProduct.maxPrice!.isNotEmpty)
                                      Text(
                                        'Max Price: ${otherProduct.maxPrice}', 
                                        style: const TextStyle(fontSize: 13, color: Colors.black54)
                                      ),
                                    if (otherProduct.minPrice != null && otherProduct.minPrice!.isNotEmpty)
                                      Text(
                                        'Min Price: ${otherProduct.minPrice}', 
                                        style: const TextStyle(fontSize: 13, color: Colors.black54)
                                      ),
                                    if (otherProduct.status != null && otherProduct.status!.isNotEmpty)
                                      Text(
                                        'Status: ${otherProduct.status}', 
                                        style: const TextStyle(fontSize: 13, color: Colors.black54)
                                      ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
} 