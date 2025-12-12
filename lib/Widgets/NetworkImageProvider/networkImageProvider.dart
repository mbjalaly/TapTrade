import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:taptrade/Const/globleKey.dart';
import 'package:taptrade/Utills/appColors.dart';

class NetworkImageProvider extends StatelessWidget {
  final String url;
  final BoxFit fit;
  final BorderRadiusGeometry borderRadius;
  final Widget errorWidget;
  final double width;
  final double height;
  final Alignment alignment;
  final Duration fadeInDuration;
  final Duration fadeOutDuration;
  final bool skipLag;

  NetworkImageProvider({
    super.key,
    required this.url,
    this.alignment = Alignment.center,
    this.fit = BoxFit.fill,
    this.width = double.infinity,
    this.height = double.infinity,
    this.borderRadius = BorderRadius.zero,
    this.skipLag = true,
    this.fadeOutDuration = const Duration(milliseconds: 1000),
    this.fadeInDuration = const Duration(milliseconds: 500),
    Widget? errorWidget,
  })  : errorWidget = errorWidget ?? Image.network(KeyConstants.imagePlaceHolder, fit: BoxFit.cover);

  @override
  Widget build(BuildContext context) {
    final validWidth = width.isFinite ? width : double.infinity;
    final validHeight = height.isFinite ? height : double.infinity;
    return ClipRRect(
      borderRadius: borderRadius,
      clipBehavior: Clip.antiAlias,
      child: CachedNetworkImage(
        fadeInDuration: fadeInDuration,
        fadeOutDuration: fadeOutDuration,
        imageUrl: url,
        fit: fit,
        width: validWidth,
        height: validHeight,
        progressIndicatorBuilder: (context, url, downloadProgress) => const Center(child: CircularProgressIndicator(color: AppColors.secondaryColor,)),
        errorWidget: (context, url, error) {
          print('Error loading image from $url: $error');
          return errorWidget;
        },
        alignment: alignment,
      ),
    );
  }
}

