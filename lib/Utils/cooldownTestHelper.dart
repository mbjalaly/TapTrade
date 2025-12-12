import 'package:taptrade/Services/CooldownService/cooldownService.dart';

/// Helper class for testing the cooldown mechanism
/// This can be used for debugging and testing purposes
class CooldownTestHelper {
  
  /// Test the cooldown mechanism with sample data
  static Future<void> testCooldownMechanism() async {
    print("=== Testing Cooldown Mechanism ===");
    
    // Clear all existing cooldowns first
    await CooldownService.instance.clearAllCooldowns();
    
    // Test product IDs
    final List<int> testProductIds = [1, 2, 3, 4, 5];
    
    print("1. Testing initial state - no products should be in cooldown");
    for (int productId in testProductIds) {
      final bool inCooldown = await CooldownService.instance.isProductInCooldownAsync(productId);
      print("   Product $productId in cooldown: $inCooldown");
    }
    
    print("\n2. Recording interactions for products 1, 2, and 3");
    await CooldownService.instance.recordProductInteraction(1);
    await CooldownService.instance.recordProductInteraction(2);
    await CooldownService.instance.recordProductInteraction(3);
    
    print("\n3. Checking cooldown status after recording interactions");
    for (int productId in testProductIds) {
      final bool inCooldown = await CooldownService.instance.isProductInCooldownAsync(productId);
      final info = await CooldownService.instance.getCooldownInfo(productId);
      if (info != null) {
        print("   Product $productId in cooldown: $inCooldown (${info['remainingHours']} hours remaining)");
      } else {
        print("   Product $productId in cooldown: $inCooldown (never interacted)");
      }
    }
    
    print("\n4. Testing filter functionality");
    final List<Map<String, dynamic>> testProducts = testProductIds.map((id) => {
      'id': id,
      'name': 'Product $id',
      'price': 100.0 + id
    }).toList();
    
    final filteredProducts = await CooldownService.instance.filterProductsInCooldown(
      testProducts,
      (product) => product['id'] as int
    );
    
    print("   Original products: ${testProducts.length}");
    print("   Filtered products: ${filteredProducts.length}");
    print("   Filtered product IDs: ${filteredProducts.map((p) => p['id']).toList()}");
    
    print("\n5. Getting all products in cooldown");
    final productsInCooldown = await CooldownService.instance.getProductsInCooldown();
    print("   Products in cooldown: $productsInCooldown");
    
    print("\n=== Cooldown Test Complete ===");
  }
  
  /// Simulate a user swiping through products
  static Future<void> simulateUserSwiping() async {
    print("=== Simulating User Swiping ===");
    
    // Clear all cooldowns first
    await CooldownService.instance.clearAllCooldowns();
    
    // Simulate swiping on products 1-10
    final List<int> swipedProducts = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10];
    
    print("User swipes on products: $swipedProducts");
    for (int productId in swipedProducts) {
      await CooldownService.instance.recordProductInteraction(productId);
      print("   Swiped on product $productId");
    }
    
    // Now simulate getting new products from API (including some that were swiped)
    final List<int> newProductsFromAPI = [1, 2, 11, 12, 13, 3, 4, 14, 15];
    print("\nNew products from API: $newProductsFromAPI");
    
    // Filter out products in cooldown
    final List<Map<String, dynamic>> apiProducts = newProductsFromAPI.map((id) => {
      'id': id,
      'name': 'Product $id',
      'price': 100.0 + id
    }).toList();
    
    final filteredProducts = await CooldownService.instance.filterProductsInCooldown(
      apiProducts,
      (product) => product['id'] as int
    );
    
    print("Products shown to user after filtering: ${filteredProducts.map((p) => p['id']).toList()}");
    print("Products filtered out (in cooldown): ${newProductsFromAPI.where((id) => !filteredProducts.any((p) => p['id'] == id)).toList()}");
    
    print("\n=== Swiping Simulation Complete ===");
  }
  
  /// Show cooldown status for all products
  static Future<void> showCooldownStatus() async {
    print("=== Current Cooldown Status ===");
    
    final productsInCooldown = await CooldownService.instance.getProductsInCooldown();
    
    if (productsInCooldown.isEmpty) {
      print("No products are currently in cooldown.");
      return;
    }
    
    print("Products in cooldown: ${productsInCooldown.length}");
    for (int productId in productsInCooldown) {
      final info = await CooldownService.instance.getCooldownInfo(productId);
      if (info != null) {
        final lastInteraction = info['lastInteractionDate'] as DateTime;
        final remainingHours = info['remainingHours'] as int;
        print("   Product $productId: Last swiped ${lastInteraction.toString()}, $remainingHours hours remaining");
      }
    }
    
    print("=== End Cooldown Status ===");
  }
  
  /// Clear cooldown for testing (useful for development)
  static Future<void> clearAllCooldowns() async {
    print("Clearing all product cooldowns...");
    await CooldownService.instance.clearAllCooldowns();
    print("All cooldowns cleared!");
  }
  
  /// Clear cooldown for a specific product (useful for testing)
  static Future<void> clearCooldownForProduct(int productId) async {
    print("Clearing cooldown for product $productId...");
    await CooldownService.instance.clearCooldownForProduct(productId);
    print("Cooldown cleared for product $productId!");
  }
}
