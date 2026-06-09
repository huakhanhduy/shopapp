import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../constants/api_constants.dart';

Widget buildProductImage(String path, {double? width, double? height, BoxFit fit = BoxFit.cover}) {
  if (path.isEmpty) {
    return Container(
      width: width,
      height: height,
      color: Colors.grey[200],
      child: const Icon(Icons.image, color: Colors.grey),
    );
  }

  if (path.startsWith('http://') || path.startsWith('https://')) {
    return CachedNetworkImage(
      imageUrl: path,
      width: width,
      height: height,
      fit: fit,
      placeholder: (context, url) => Container(color: Colors.grey[100], child: const Center(child: CircularProgressIndicator(strokeWidth: 2))),
      errorWidget: (context, url, error) => const Icon(Icons.broken_image, color: Colors.grey),
    );
  }

  final filename = path.split('/').last;
  final isPreBundled = filename.startsWith('pro') ||
      filename.startsWith('banner') ||
      filename.startsWith('black_tag') ||
      filename.startsWith('menhoddie_tag') ||
      filename.startsWith('new_collection_tag');

  if (path.startsWith('assets/') && isPreBundled) {
    return Image.asset(
      path,
      width: width,
      height: height,
      fit: fit,
      errorBuilder: (context, error, stackTrace) {
        return CachedNetworkImage(
          imageUrl: "${ApiConstants.baseUrl}/$path",
          width: width,
          height: height,
          fit: fit,
          placeholder: (context, url) => Container(color: Colors.grey[100]),
          errorWidget: (context, url, error) => const Icon(Icons.broken_image, color: Colors.grey),
        );
      },
    );
  }

  final url = path.startsWith('/') ? "${ApiConstants.baseUrl}$path" : "${ApiConstants.baseUrl}/$path";
  return CachedNetworkImage(
    imageUrl: url,
    width: width,
    height: height,
    fit: fit,
    placeholder: (context, url) => Container(color: Colors.grey[100], child: const Center(child: CircularProgressIndicator(strokeWidth: 2))),
    errorWidget: (context, url, error) => const Icon(Icons.broken_image, color: Colors.grey),
  );
}
