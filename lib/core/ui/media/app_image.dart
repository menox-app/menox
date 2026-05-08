import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter_core/core/theme/app_theme.dart';
import 'package:shimmer/shimmer.dart';

class AppImage extends StatelessWidget {
  final String? url;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;
  final BoxShape shape;
  final Widget? placeholder;
  final Widget? errorWidget;
  final Color backgroundColor;
  final IconData errorIcon;
  final double errorIconSize;

  const AppImage({
    super.key,
    required this.url,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.shape = BoxShape.rectangle,
    this.placeholder,
    this.errorWidget,
    this.backgroundColor = ShadcnColors.secondary,
    this.errorIcon = FluentIcons.image_24_regular,
    this.errorIconSize = 28,
  });

  const AppImage.avatar({
    super.key,
    required this.url,
    double size = 40,
    this.placeholder,
    this.errorWidget,
    this.backgroundColor = ShadcnColors.secondary,
    this.errorIcon = FluentIcons.person_24_regular,
    this.errorIconSize = 18,
  }) : width = size,
       height = size,
       fit = BoxFit.cover,
       borderRadius = null,
       shape = BoxShape.circle;

  @override
  Widget build(BuildContext context) {
    final imageUrl = url?.trim();
    final isLocalFile =
        imageUrl != null &&
        imageUrl.isNotEmpty &&
        (!imageUrl.startsWith('http://') && !imageUrl.startsWith('https://'));

    return _clip(
      SizedBox(
        width: width,
        height: height,
        child: imageUrl == null || imageUrl.isEmpty
            ? _buildError()
            : isLocalFile
            ? Image.file(
                File(
                  imageUrl.startsWith('file://')
                      ? Uri.parse(imageUrl).toFilePath()
                      : imageUrl,
                ),
                width: width,
                height: height,
                fit: fit,
                errorBuilder: (_, __, ___) => _buildError(),
              )
            : CachedNetworkImage(
                imageUrl: imageUrl,
                width: width,
                height: height,
                fit: fit,
                placeholder: (_, __) => _buildPlaceholder(),
                errorWidget: (_, __, ___) => _buildError(),
              ),
      ),
    );
  }

  Widget _clip(Widget child) {
    if (shape == BoxShape.circle) {
      return ClipOval(child: child);
    }

    if (borderRadius != null) {
      return ClipRRect(borderRadius: borderRadius!, child: child);
    }

    return child;
  }

  Widget _buildPlaceholder() {
    if (placeholder != null) return placeholder!;

    return Shimmer.fromColors(
      baseColor: ShadcnColors.mutedForeground.withValues(alpha: 0.10),
      highlightColor: ShadcnColors.primary.withValues(alpha: 0.08),
      child: Container(color: backgroundColor),
    );
  }

  Widget _buildError() {
    if (errorWidget != null) return errorWidget!;

    return Container(
      color: backgroundColor,
      child: Center(
        child: Icon(
          errorIcon,
          color: ShadcnColors.mutedForeground,
          size: errorIconSize,
        ),
      ),
    );
  }
}
