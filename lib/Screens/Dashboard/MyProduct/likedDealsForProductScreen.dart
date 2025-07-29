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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(product.title ?? 'Product'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product details at the top
          Card(
            elevation: 4,
            margin: const EdgeInsets.fromLTRB(16, 24, 16, 16), // more top margin
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            child: Padding(
              padding: const EdgeInsets.all(22), // more padding
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
                        Text(product.title ?? '', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
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
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text('Liked by these products:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          ),
          Expanded(
            child: likedDeals.isEmpty
                ? const Center(child: Text('No liked deals for this product.'))
                : ListView.builder(
                    itemCount: likedDeals.length,
                    itemBuilder: (context, index) {
                      final deal = likedDeals[index];
                      final otherProduct = deal.otherProduct;
                      return Card(
                        elevation: 2,
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                          child: Row(
                            children: [
                              (otherProduct?.image != null && otherProduct!.image!.isNotEmpty)
                                  ? Container(
                                      width: 40,
                                      height: 40,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(color: Colors.blueGrey, width: 1.5),
                                        image: DecorationImage(
                                          image: NetworkImage(KeyConstants.imageUrl + otherProduct.image!),
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    )
                                  : CircleAvatar(
                                      radius: 20,
                                      backgroundColor: Colors.grey[200],
                                      child: Icon(Icons.image, size: 22, color: Colors.grey[400]),
                                    ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(otherProduct?.title ?? 'No title', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                                    const SizedBox(height: 4),
                                    Text('Category: ${otherProduct?.category ?? ''}', style: const TextStyle(fontSize: 13, color: Colors.black54)),
                                    Text('Max Price: ${otherProduct?.maxPrice ?? ''}', style: const TextStyle(fontSize: 13, color: Colors.black54)),
                                    Text('Min Price: ${otherProduct?.minPrice ?? ''}', style: const TextStyle(fontSize: 13, color: Colors.black54)),
                                    Text('Status: ${otherProduct?.status ?? ''}', style: const TextStyle(fontSize: 13, color: Colors.black54)),
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