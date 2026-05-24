import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

import '../../main.dart';

/// Camera or captured-image preview, styled to match the cream/persimmon
/// chat surface. Falls back gracefully when no camera is available
/// (e.g. desktop / web without permission).
class LensPreviewArea extends StatelessWidget {
  final Uint8List? imageBytes;
  final CameraController? cameraController;
  final Future<void>? cameraInitFuture;
  final String? cameraError;

  const LensPreviewArea({
    super.key,
    required this.imageBytes,
    required this.cameraController,
    required this.cameraInitFuture,
    required this.cameraError,
  });

  @override
  Widget build(BuildContext context) {
    final cameraReady = cameraController != null &&
        cameraController!.value.isInitialized &&
        cameraError == null;
    final aspectRatio = (imageBytes == null && cameraReady)
        ? cameraController!.value.aspectRatio
        : 4 / 3;

    Widget child;
    if (imageBytes != null) {
      child = Image.memory(imageBytes!, fit: BoxFit.cover);
    } else if (cameraError != null) {
      child = _CameraMissing(message: cameraError!);
    } else if (cameraController != null && cameraInitFuture != null) {
      child = FutureBuilder<void>(
        future: cameraInitFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done &&
              cameraController!.value.isInitialized) {
            return CameraPreview(cameraController!);
          }
          return const _LoadingFrame();
        },
      );
    } else {
      child = const _LoadingFrame();
    }

    return AspectRatio(
      aspectRatio: aspectRatio,
      child: Container(
        decoration: BoxDecoration(
          color: SeoulPalette.creamDeep,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: SeoulPalette.persimmon.withValues(alpha: 0.18),
          ),
          boxShadow: [
            BoxShadow(
              color: SeoulPalette.hanNavy.withValues(alpha: 0.06),
              blurRadius: 14,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: child,
      ),
    );
  }
}

class _LoadingFrame extends StatelessWidget {
  const _LoadingFrame();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: SizedBox(
        width: 28,
        height: 28,
        child: CircularProgressIndicator(
          strokeWidth: 2.5,
          color: SeoulPalette.persimmon,
        ),
      ),
    );
  }
}

class _CameraMissing extends StatelessWidget {
  final String message;
  const _CameraMissing({required this.message});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: SeoulPalette.persimmon.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.videocam_off_outlined,
              size: 28,
              color: SeoulPalette.persimmon,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: SeoulPalette.hanNavy,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'You can still upload an image from your device.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: SeoulPalette.hanNavy.withValues(alpha: 0.6),
              fontSize: 12.5,
            ),
          ),
        ],
      ),
    );
  }
}
