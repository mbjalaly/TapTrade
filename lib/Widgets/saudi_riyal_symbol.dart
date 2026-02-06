import 'package:flutter/material.dart';

/// A widget that displays the Saudi Riyal currency symbol (﷼) using the
/// custom SaudiRiyal font.
/// 
/// The symbol is rendered using the private-use code point U+E900 from
/// the Saudi Riyal Font (https://github.com/emran-alhaddad/Saudi-Riyal-Font)
/// 
/// Usage:
/// ```dart
/// Row(
///   children: [
///     Text('100'),
///     SaudiRiyalSymbol(size: 16, color: Colors.black),
///   ],
/// )
/// ```
class SaudiRiyalSymbol extends StatelessWidget {
  final double size;
  final Color? color;
  final FontWeight fontWeight;

  const SaudiRiyalSymbol({
    Key? key,
    this.size = 16,
    this.color,
    this.fontWeight = FontWeight.normal,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(
      '\uE900', // Private-use code point for Saudi Riyal symbol
      style: TextStyle(
        fontFamily: 'SaudiRiyal',
        fontSize: size,
        color: color ?? Theme.of(context).textTheme.bodyMedium?.color,
        fontWeight: fontWeight,
      ),
    );
  }
}

/// Helper class for formatting currency with Saudi Riyal symbol
class SaudiRiyalFormatter {
  /// Returns a Widget that displays amount with the Riyal symbol
  /// 
  /// Usage:
  /// ```dart
  /// SaudiRiyalFormatter.format(100.50, fontSize: 16)
  /// ```
  static Widget format(
    dynamic amount, {
    double fontSize = 16,
    Color? color,
    FontWeight fontWeight = FontWeight.normal,
  }) {
    final formattedAmount = amount is double 
        ? amount.toStringAsFixed(amount.truncateToDouble() == amount ? 0 : 2)
        : amount.toString();
    
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          formattedAmount,
          style: TextStyle(
            fontSize: fontSize,
            color: color,
            fontWeight: fontWeight,
          ),
        ),
        const SizedBox(width: 2),
        SaudiRiyalSymbol(
          size: fontSize,
          color: color,
          fontWeight: fontWeight,
        ),
      ],
    );
  }
  
  /// Returns a Widget that displays a price range with Riyal symbol
  /// 
  /// Usage:
  /// ```dart
  /// SaudiRiyalFormatter.formatRange(100, 500, fontSize: 16)
  /// ```
  static Widget formatRange(
    dynamic minPrice,
    dynamic maxPrice, {
    double fontSize = 16,
    Color? color,
    FontWeight fontWeight = FontWeight.normal,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '$minPrice - $maxPrice ',
          style: TextStyle(
            fontSize: fontSize,
            color: color,
            fontWeight: fontWeight,
          ),
        ),
        SaudiRiyalSymbol(
          size: fontSize,
          color: color,
          fontWeight: fontWeight,
        ),
      ],
    );
  }
}
