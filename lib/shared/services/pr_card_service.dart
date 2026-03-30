import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class PrCardService {
  static Future<void> sharePrCard(GlobalKey cardKey, BuildContext context) async {
    Rect? shareOrigin;
    final box = context.findRenderObject();
    if (box is RenderBox) {
      shareOrigin = box.localToGlobal(Offset.zero) & box.size;
    }

    final renderObject = cardKey.currentContext?.findRenderObject();
    if (renderObject is! RenderRepaintBoundary) {
      throw StateError('PR card is not ready to render');
    }

    final image = await renderObject.toImage(pixelRatio: 3.0);
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    if (byteData == null) {
      throw StateError('Failed to encode PR card image');
    }
    final bytes = byteData.buffer.asUint8List();

    final directory = await getTemporaryDirectory();
    final file = File(
      '${directory.path}/pr_card_${DateTime.now().millisecondsSinceEpoch}.png',
    );
    await file.writeAsBytes(bytes);

    await SharePlus.instance.share(
      ShareParams(
        files: [XFile(file.path)],
        text: 'Just hit a new PR on FORJA!',
        sharePositionOrigin: shareOrigin,
      ),
    );
  }
}
