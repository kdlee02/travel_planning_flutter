import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../main.dart';
import '../models/landmark_analysis.dart';
import '../services/lens_service.dart';
import '../widgets/lens/preview_area.dart';
import '../widgets/lens/result_card.dart';

/// High-level phase of the lens flow.
///
///   idle           – no image, camera streaming
///   pendingConfirm – image captured/picked, awaiting user confirmation
///   analyzing      – Gemini call in flight
///   analyzed       – result rendered below
///   error          – analyze failed, user can retry on the same bytes or
///                    retake from scratch
enum _LensPhase { idle, pendingConfirm, analyzing, analyzed, error }

class LensScreen extends StatefulWidget {
  const LensScreen({super.key});

  @override
  State<LensScreen> createState() => _LensScreenState();
}

class _LensScreenState extends State<LensScreen> with WidgetsBindingObserver {
  final _picker = ImagePicker();
  final _lens = LensService();

  CameraController? _cameraController;
  Future<void>? _cameraInitFuture;
  String? _cameraError;
  List<CameraDescription> _cameras = const [];

  // Captured / picked image (kept around through analyzing so the user sees
  // what they confirmed while Gemini runs).
  Uint8List? _imageBytes;
  String _imageName = 'capture.jpg';

  LandmarkAnalysis? _result;
  String? _error;
  _LensPhase _phase = _LensPhase.idle;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initCamera();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _cameraController?.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final c = _cameraController;
    if (c == null || !c.value.isInitialized) return;
    if (state == AppLifecycleState.inactive) {
      c.dispose();
    } else if (state == AppLifecycleState.resumed) {
      _initCamera();
    }
  }

  // ── Camera lifecycle ──────────────────────────────────────────────────────

  Future<void> _initCamera() async {
    try {
      _cameras = await availableCameras();
    } catch (_) {
      _cameras = const [];
    }

    if (_cameras.isEmpty) {
      if (!mounted) return;
      setState(() {
        _cameraError = 'No camera detected on this device.';
      });
      return;
    }

    final controller = CameraController(
      _cameras.first,
      ResolutionPreset.high,
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.jpeg,
    );
    _cameraController = controller;

    final future = controller.initialize().then((_) {
      if (!mounted) return;
      setState(() => _cameraError = null);
    }).catchError((Object e) {
      if (!mounted) return;
      setState(() => _cameraError = 'Could not start camera: $e');
    });

    if (!mounted) return;
    setState(() => _cameraInitFuture = future);
  }

  /// Tear down the current controller and spin up a fresh one. Without this,
  /// `takePicture()` on Chrome/macOS pauses the stream and the preview shows
  /// a frozen frame after retake.
  Future<void> _rebuildCamera() async {
    final old = _cameraController;
    _cameraController = null;
    _cameraInitFuture = null;
    if (mounted) setState(() {});
    await old?.dispose();
    await _initCamera();
  }

  // ── Capture / upload (no longer triggers analyze) ─────────────────────────

  Future<void> _capture() async {
    final c = _cameraController;
    if (c == null || !c.value.isInitialized) return;
    if (_phase == _LensPhase.analyzing) return;
    try {
      final XFile file = await c.takePicture();
      final bytes = await file.readAsBytes();
      if (!mounted) return;
      setState(() {
        _imageBytes = bytes;
        _imageName = file.name;
        _result = null;
        _error = null;
        _phase = _LensPhase.pendingConfirm;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = 'Could not capture photo: $e');
    }
  }

  Future<void> _pickFromGallery() async {
    if (_phase == _LensPhase.analyzing) return;
    try {
      final XFile? file = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
        maxWidth: 1600,
      );
      if (file == null) return;
      final bytes = await file.readAsBytes();
      if (!mounted) return;
      setState(() {
        _imageBytes = bytes;
        _imageName = file.name;
        _result = null;
        _error = null;
        _phase = _LensPhase.pendingConfirm;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = 'Could not load image: $e');
    }
  }

  // ── Confirm / retake ──────────────────────────────────────────────────────

  Future<void> _confirm() async {
    final bytes = _imageBytes;
    if (bytes == null) return;
    setState(() {
      _phase = _LensPhase.analyzing;
      _result = null;
      _error = null;
    });
    try {
      final result = await _lens.analyze(bytes, _imageName);
      if (!mounted) return;
      setState(() {
        _result = result;
        _phase = _LensPhase.analyzed;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _phase = _LensPhase.error;
      });
    }
  }

  Future<void> _retake() async {
    setState(() {
      _imageBytes = null;
      _result = null;
      _error = null;
      _phase = _LensPhase.idle;
    });
    await _rebuildCamera();
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final showLivePreview = _phase == _LensPhase.idle;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: _buildAppBar(context),
      body: Stack(
        children: [
          const _BackgroundDecor(),
          SafeArea(
            child: SingleChildScrollView(
              padding:
                  const EdgeInsets.fromLTRB(16, kToolbarHeight + 4, 16, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (showLivePreview) const _Tagline(),
                  if (showLivePreview) const SizedBox(height: 12),
                  LensPreviewArea(
                    imageBytes: _imageBytes,
                    cameraController: _cameraController,
                    cameraInitFuture: _cameraInitFuture,
                    cameraError: _cameraError,
                  ),
                  const SizedBox(height: 16),
                  _PhaseActions(
                    phase: _phase,
                    cameraReady: _cameraController != null &&
                        _cameraController!.value.isInitialized,
                    hideCapture: kIsWeb && _cameras.isEmpty,
                    onCapture: _capture,
                    onPick: _pickFromGallery,
                    onConfirm: _confirm,
                    onRetake: _retake,
                    onRetry: _confirm,
                  ),
                  if (_phase == _LensPhase.analyzing) ...[
                    const SizedBox(height: 20),
                    const _LensLoader(),
                  ],
                  if (_phase == _LensPhase.error && _error != null) ...[
                    const SizedBox(height: 16),
                    _ErrorCard(message: _error!),
                  ],
                  if (_result != null) LensResultCard(result: _result!),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      titleSpacing: 16,
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [SeoulPalette.persimmon, SeoulPalette.gold],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: SeoulPalette.persimmon.withValues(alpha: 0.25),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Center(
              child: Text('📸', style: TextStyle(fontSize: 18)),
            ),
          ),
          const SizedBox(width: 12),
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Seoul Lens',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: SeoulPalette.hanNavy,
                ),
              ),
              Text(
                '사진 한 장 · Identify any landmark',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: SeoulPalette.hanNavy.withValues(alpha: 0.55),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ────────────────────────────────────────────────────────────────────────────
// Phase-specific action row
// ────────────────────────────────────────────────────────────────────────────

class _PhaseActions extends StatelessWidget {
  final _LensPhase phase;
  final bool cameraReady;
  final bool hideCapture;
  final VoidCallback onCapture;
  final VoidCallback onPick;
  final VoidCallback onConfirm;
  final VoidCallback onRetake;
  final VoidCallback onRetry;

  const _PhaseActions({
    required this.phase,
    required this.cameraReady,
    required this.hideCapture,
    required this.onCapture,
    required this.onPick,
    required this.onConfirm,
    required this.onRetake,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    switch (phase) {
      case _LensPhase.idle:
        return _IdleActions(
          onCapture: cameraReady ? onCapture : null,
          onPick: onPick,
          hideCapture: hideCapture,
        );
      case _LensPhase.pendingConfirm:
        return _TwoButtonRow(
          primary: _PrimaryButton(
            icon: Icons.check_circle_outline,
            label: 'Use this photo',
            onTap: onConfirm,
          ),
          secondary: _SecondaryButton(
            icon: Icons.refresh_rounded,
            label: 'Retake',
            onTap: onRetake,
          ),
        );
      case _LensPhase.analyzing:
        // Buttons disabled while Gemini is in flight.
        return const _TwoButtonRow(
          primary: _PrimaryButton(
            icon: Icons.check_circle_outline,
            label: 'Identifying…',
            onTap: null,
          ),
          secondary: _SecondaryButton(
            icon: Icons.refresh_rounded,
            label: 'Retake',
            onTap: null,
          ),
        );
      case _LensPhase.analyzed:
        return _SecondaryButton(
          icon: Icons.refresh_rounded,
          label: 'Take another',
          onTap: onRetake,
        );
      case _LensPhase.error:
        return _TwoButtonRow(
          primary: _PrimaryButton(
            icon: Icons.replay_rounded,
            label: 'Try again',
            onTap: onRetry,
          ),
          secondary: _SecondaryButton(
            icon: Icons.refresh_rounded,
            label: 'Retake',
            onTap: onRetake,
          ),
        );
    }
  }
}

class _IdleActions extends StatelessWidget {
  final VoidCallback? onCapture;
  final VoidCallback? onPick;
  final bool hideCapture;

  const _IdleActions({
    required this.onCapture,
    required this.onPick,
    required this.hideCapture,
  });

  @override
  Widget build(BuildContext context) {
    final captureBtn = _PrimaryButton(
      icon: Icons.camera_alt_rounded,
      label: 'Take picture',
      onTap: onCapture,
    );
    final pickBtn = _SecondaryButton(
      icon: Icons.photo_library_outlined,
      label: 'Upload image',
      onTap: onPick,
    );
    if (hideCapture) {
      return SizedBox(width: double.infinity, child: pickBtn);
    }
    return _TwoButtonRow(primary: captureBtn, secondary: pickBtn);
  }
}

class _TwoButtonRow extends StatelessWidget {
  final Widget primary;
  final Widget secondary;

  const _TwoButtonRow({required this.primary, required this.secondary});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: primary),
        const SizedBox(width: 12),
        Expanded(child: secondary),
      ],
    );
  }
}

// ────────────────────────────────────────────────────────────────────────────
// Shared sub-widgets (unchanged styling)
// ────────────────────────────────────────────────────────────────────────────

class _BackgroundDecor extends StatelessWidget {
  const _BackgroundDecor();

  @override
  Widget build(BuildContext context) {
    return const Positioned.fill(
      child: IgnorePointer(
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                SeoulPalette.creamDeep,
                SeoulPalette.cream,
                SeoulPalette.cream,
              ],
              stops: [0.0, 0.4, 1.0],
            ),
          ),
        ),
      ),
    );
  }
}

class _Tagline extends StatelessWidget {
  const _Tagline();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 4),
      child: Text(
        'Point, snap, learn ✨',
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: SeoulPalette.hanNavy.withValues(alpha: 0.65),
        ),
      ),
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  const _PrimaryButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;
    return Material(
      color: enabled
          ? SeoulPalette.persimmon
          : SeoulPalette.persimmon.withValues(alpha: 0.35),
      borderRadius: BorderRadius.circular(28),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(28),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SecondaryButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  const _SecondaryButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;
    return Material(
      color: enabled
          ? SeoulPalette.creamDeep
          : SeoulPalette.creamDeep.withValues(alpha: 0.5),
      borderRadius: BorderRadius.circular(28),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(28),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: SeoulPalette.persimmon.withValues(alpha: 0.25),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: SeoulPalette.persimmon, size: 20),
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  color: SeoulPalette.hanNavy,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LensLoader extends StatelessWidget {
  const _LensLoader();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: SeoulPalette.persimmon.withValues(alpha: 0.12),
        ),
      ),
      child: Row(
        children: [
          const SizedBox(
            width: 22,
            height: 22,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              color: SeoulPalette.persimmon,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              'Identifying landmark and checking Seoul Open Data…',
              style: TextStyle(
                color: SeoulPalette.hanNavy.withValues(alpha: 0.85),
                fontSize: 13.5,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorCard extends StatelessWidget {
  final String message;
  const _ErrorCard({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: SeoulPalette.persimmonSoft.withValues(alpha: 0.25),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: SeoulPalette.persimmon.withValues(alpha: 0.35),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.error_outline,
            color: SeoulPalette.persimmon,
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                color: SeoulPalette.hanNavy,
                fontSize: 13,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
