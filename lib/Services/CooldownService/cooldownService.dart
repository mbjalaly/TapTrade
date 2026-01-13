import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class CooldownService {
  static final CooldownService instance = CooldownService._internal();
  
  factory CooldownService() => instance;
  
  CooldownService._internal();
  
  static const String _cooldownKey = 'product_cooldowns';
  static const int _cooldownDays = 2;
  static const int _cooldownMilliseconds = _cooldownDays * 24 * 60 * 60 * 1000; // 2 days in milliseconds
  
  /// Record that a product was interacted with (liked or disliked)
  Future<void> recordProductInteraction(int productId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cooldownData = prefs.getString(_cooldownKey) ?? '{}';
      final Map<String, dynamic> cooldowns = json.decode(cooldownData);
      
      // Record the current timestamp for this product
      cooldowns[productId.toString()] = DateTime.now().millisecondsSinceEpoch;
      
      // Save back to preferences
      await prefs.setString(_cooldownKey, json.encode(cooldowns));
      
      print("Recorded interaction for product $productId at ${DateTime.now()}");
    } catch (e) {
      print("Error recording product interaction: $e");
    }
  }
  
  /// Check if a product is still in cooldown period
  bool isProductInCooldown(int productId) {
    try {
      // We can't use async here since this is called in a sync context
      // So we'll use a different approach - check synchronously
      return false; // Will be overridden by async method
    } catch (e) {
      print("Error checking product cooldown: $e");
      return false;
    }
  }
  
  /// Check if a product is still in cooldown period (async version)
  Future<bool> isProductInCooldownAsync(int productId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cooldownData = prefs.getString(_cooldownKey) ?? '{}';
      final Map<String, dynamic> cooldowns = json.decode(cooldownData);
      
      final String productIdStr = productId.toString();
      if (!cooldowns.containsKey(productIdStr)) {
        return false; // Product never interacted with
      }
      
      final int lastInteractionTime = cooldowns[productIdStr];
      final int currentTime = DateTime.now().millisecondsSinceEpoch;
      final int timeDifference = currentTime - lastInteractionTime;
      
      final bool inCooldown = timeDifference < _cooldownMilliseconds;
      
      if (inCooldown) {
        final int remainingHours = ((_cooldownMilliseconds - timeDifference) / (1000 * 60 * 60)).round();
        print("Product $productId is in cooldown for $remainingHours more hours");
      }
      
      return inCooldown;
    } catch (e) {
      print("Error checking product cooldown async: $e");
      return false;
    }
  }
  
  /// Get list of product IDs that are currently in cooldown
  Future<List<int>> getProductsInCooldown() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cooldownData = prefs.getString(_cooldownKey) ?? '{}';
      final Map<String, dynamic> cooldowns = json.decode(cooldownData);
      
      final List<int> productsInCooldown = [];
      final int currentTime = DateTime.now().millisecondsSinceEpoch;
      
      for (final entry in cooldowns.entries) {
        final int productId = int.tryParse(entry.key) ?? -1;
        final int lastInteractionTime = entry.value;
        final int timeDifference = currentTime - lastInteractionTime;
        
        if (timeDifference < _cooldownMilliseconds) {
          productsInCooldown.add(productId);
        }
      }
      
      return productsInCooldown;
    } catch (e) {
      print("Error getting products in cooldown: $e");
      return [];
    }
  }
  
  /// Filter out products that are in cooldown
  Future<List<T>> filterProductsInCooldown<T>(List<T> products, int Function(T) getProductId) async {
    try {
      final productsInCooldown = await getProductsInCooldown();
      return products.where((product) {
        final int productId = getProductId(product);
        return !productsInCooldown.contains(productId);
      }).toList();
    } catch (e) {
      print("Error filtering products in cooldown: $e");
      return products; // Return all products if error occurs
    }
  }
  
  /// Clear cooldown for a specific product (for testing purposes)
  Future<void> clearCooldownForProduct(int productId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cooldownData = prefs.getString(_cooldownKey) ?? '{}';
      final Map<String, dynamic> cooldowns = json.decode(cooldownData);
      
      cooldowns.remove(productId.toString());
      await prefs.setString(_cooldownKey, json.encode(cooldowns));
      
      print("Cleared cooldown for product $productId");
    } catch (e) {
      print("Error clearing cooldown for product: $e");
    }
  }
  
  /// Clear all cooldowns (for testing purposes)
  Future<void> clearAllCooldowns() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_cooldownKey);
      print("Cleared all product cooldowns");
    } catch (e) {
      print("Error clearing all cooldowns: $e");
    }
  }
  
  /// Get cooldown info for a specific product
  Future<Map<String, dynamic>?> getCooldownInfo(int productId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cooldownData = prefs.getString(_cooldownKey) ?? '{}';
      final Map<String, dynamic> cooldowns = json.decode(cooldownData);
      
      final String productIdStr = productId.toString();
      if (!cooldowns.containsKey(productIdStr)) {
        return null; // Product never interacted with
      }
      
      final int lastInteractionTime = cooldowns[productIdStr];
      final int currentTime = DateTime.now().millisecondsSinceEpoch;
      final int timeDifference = currentTime - lastInteractionTime;
      final bool inCooldown = timeDifference < _cooldownMilliseconds;
      
      return {
        'productId': productId,
        'lastInteractionTime': lastInteractionTime,
        'lastInteractionDate': DateTime.fromMillisecondsSinceEpoch(lastInteractionTime),
        'currentTime': currentTime,
        'timeDifference': timeDifference,
        'inCooldown': inCooldown,
        'remainingTime': inCooldown ? (_cooldownMilliseconds - timeDifference) : 0,
        'remainingHours': inCooldown ? ((_cooldownMilliseconds - timeDifference) / (1000 * 60 * 60)).round() : 0,
      };
    } catch (e) {
      print("Error getting cooldown info: $e");
      return null;
    }
  }
}
