import 'dart:io' as io;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../core/storage_service.dart';
import '../core/app_scope.dart';

class AppImage extends StatelessWidget {
  final String? url;
  final String? storagePath;
  final BoxFit fit;
  final BorderRadius borderRadius;
  final double? height;
  final double? width;
  const AppImage({
    super.key,
    this.url,
    this.storagePath,
    this.fit = BoxFit.cover,
    this.borderRadius = BorderRadius.zero,
    this.height,
    this.width,
  });
  @override
  Widget build(BuildContext context) {
    final inTest = !_isWeb() && io.Platform.environment.containsKey('FLUTTER_TEST');
    if (inTest) {
      return _placeholder(borderRadius);
    }
    final app = AppScope.of(context);
    if (storagePath != null && app.firebaseReady) {
      return ClipRRect(
        borderRadius: borderRadius,
        child: FutureBuilder<String>(
          future: StorageService.instance.getDownloadUrl(storagePath!),
          builder: (context, snap) {
            if (!snap.hasData) return _placeholder(BorderRadius.zero);
            return Image.network(
              snap.data!,
              fit: fit,
              height: height,
              width: width,
              errorBuilder: (c, e, s) => _placeholder(BorderRadius.zero),
            );
          },
        ),
      );
    }
    if (url != null && url!.isNotEmpty) {
      if (url!.startsWith('assets/')) {
        return ClipRRect(
          borderRadius: borderRadius,
          child: Image.asset(
            url!,
            fit: fit,
            height: height,
            width: width,
            errorBuilder: (c, e, s) => _placeholder(BorderRadius.zero),
          ),
        );
      }
      return ClipRRect(
        borderRadius: borderRadius,
        child: Image.network(
          url!,
          fit: fit,
          height: height,
          width: width,
          errorBuilder: (c, e, s) => _placeholder(BorderRadius.zero),
        ),
      );
    }
    return _placeholder(borderRadius);
  }
}

bool _isWeb() => kIsWeb;

Widget _placeholder(BorderRadius br) {
  return ClipRRect(
    borderRadius: br,
    child: Container(
      color: const Color(0xFFEAEAEA),
      child: const Center(
        child: Icon(Icons.image, color: Colors.grey, size: 36),
      ),
    ),
  );
}
