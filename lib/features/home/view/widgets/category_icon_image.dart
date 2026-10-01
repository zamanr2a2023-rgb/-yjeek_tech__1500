import 'dart:async';
import 'dart:collection';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:yjeek_app/core/services/cache_service.dart';
import 'package:yjeek_app/core/widgets/app_network_image.dart';

const _knockoutThreshold = 16;
const _decodeWidth = 320;

final Map<String, Future<ui.Image>> _categoryIconCache = {};

Future<ui.Image> categoryIconImage(String url) {
  final existing = _categoryIconCache[url];
  if (existing != null) return existing;
  final future = _decodeCategoryIcon(url);
  _categoryIconCache[url] = future;
  future.then((_) {}, onError: (_) => _categoryIconCache.remove(url));
  return future;
}

Future<ui.Image> _decodeCategoryIcon(String url) async {
  final file = await appCacheManager.getSingleFile(url);
  final bytes = await file.readAsBytes();
  final codec = await ui.instantiateImageCodec(bytes, targetWidth: _decodeWidth);
  final frame = await codec.getNextFrame();
  final source = frame.image;
  final byteData = await source.toByteData(format: ui.ImageByteFormat.rawRgba);
  final width = source.width;
  final height = source.height;
  source.dispose();
  if (byteData == null) {
    throw StateError('Could not read category icon pixels');
  }
  final pixels = byteData.buffer.asUint8List(
    byteData.offsetInBytes,
    byteData.lengthInBytes,
  );
  final painted = _cornersAreNearBlack(pixels, width, height)
      ? _knockOutEdgeBlack(pixels, width, height)
      : pixels;
  final completer = Completer<ui.Image>();
  ui.decodeImageFromPixels(
    painted,
    width,
    height,
    ui.PixelFormat.rgba8888,
    completer.complete,
  );
  return completer.future;
}

bool _cornersAreNearBlack(Uint8List pixels, int width, int height) {
  if (width < 2 || height < 2) return false;
  bool nearBlack(int x, int y) {
    final offset = (y * width + x) * 4;
    return pixels[offset] <= _knockoutThreshold &&
        pixels[offset + 1] <= _knockoutThreshold &&
        pixels[offset + 2] <= _knockoutThreshold;
  }

  final hits = [
    nearBlack(0, 0),
    nearBlack(width - 1, 0),
    nearBlack(0, height - 1),
    nearBlack(width - 1, height - 1),
  ].where((hit) => hit).length;
  return hits >= 3;
}

Uint8List _knockOutEdgeBlack(Uint8List pixels, int width, int height) {
  final copy = Uint8List.fromList(pixels);
  final count = width * height;
  final seen = Uint8List(count);
  final queue = ListQueue<int>();

  bool isBackground(int index) {
    final offset = index * 4;
    return copy[offset] <= _knockoutThreshold &&
        copy[offset + 1] <= _knockoutThreshold &&
        copy[offset + 2] <= _knockoutThreshold;
  }

  void push(int index) {
    if (index < 0 || index >= count || seen[index] != 0 || !isBackground(index)) {
      return;
    }
    seen[index] = 1;
    queue.add(index);
  }

  for (var x = 0; x < width; x++) {
    push(x);
    push((height - 1) * width + x);
  }
  for (var y = 0; y < height; y++) {
    push(y * width);
    push(y * width + width - 1);
  }

  while (queue.isNotEmpty) {
    final index = queue.removeFirst();
    final offset = index * 4;
    copy[offset] = 255;
    copy[offset + 1] = 255;
    copy[offset + 2] = 255;
    copy[offset + 3] = 255;
    final x = index % width;
    if (x + 1 < width) push(index + 1);
    if (x > 0) push(index - 1);
    if (index + width < count) push(index + width);
    if (index - width >= 0) push(index - width);
  }
  return copy;
}

/// Category icon with a white background.
///
/// Uploaded icons were saved as JPEG, so the empty area is black pixels, not
/// transparency. A white box behind the image cannot show through those pixels.
class CategoryIconImage extends StatefulWidget {
  const CategoryIconImage({
    super.key,
    required this.url,
    required this.size,
  });

  final String url;
  final double size;

  @override
  State<CategoryIconImage> createState() => _CategoryIconImageState();
}

class _CategoryIconImageState extends State<CategoryIconImage> {
  ui.Image? _image;
  bool _failed = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void didUpdateWidget(covariant CategoryIconImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.url != widget.url) {
      _image = null;
      _failed = false;
      _load();
    }
  }

  Future<void> _load() async {
    final url = widget.url;
    try {
      final image = await categoryIconImage(url);
      if (!mounted || url != widget.url) return;
      setState(() => _image = image);
    } catch (_) {
      if (!mounted || url != widget.url) return;
      setState(() => _failed = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_failed) {
      return AppNetworkImage(
        url: widget.url,
        width: widget.size,
        height: widget.size,
        fit: BoxFit.cover,
      );
    }
    final image = _image;
    if (image == null) {
      return SizedBox(width: widget.size, height: widget.size);
    }
    return RawImage(
      image: image,
      width: widget.size,
      height: widget.size,
      fit: BoxFit.cover,
    );
  }
}
