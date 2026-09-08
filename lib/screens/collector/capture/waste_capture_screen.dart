import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

import '../classification/material_classification_screen.dart';

class WasteCaptureScreen extends StatefulWidget {
  const WasteCaptureScreen({super.key});

  @override
  State<WasteCaptureScreen> createState() => _WasteCaptureScreenState();
}

class _WasteCaptureScreenState extends State<WasteCaptureScreen> {
  CameraController? _controller;
  List<CameraDescription> _cameras = [];
  bool _initializing = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {
    try {
      _cameras = await availableCameras();
      if (_cameras.isEmpty) {
        throw Exception('No camera found.');
      }

      final camera = _cameras.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.back,
        orElse: () => _cameras.first,
      );

      final controller = CameraController(
        camera,
        ResolutionPreset.medium,
        enableAudio: false,
      );
      await controller.initialize();

      if (!mounted) {
        await controller.dispose();
        return;
      }

      setState(() {
        _controller = controller;
        _initializing = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _initializing = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _capture() async {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) return;

    try {
      final file = await controller.takePicture();
      if (!mounted) return;

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => MaterialClassificationScreen(
            imageFile: File(file.path),
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not capture photo: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Capture E-Waste')),
      body: _initializing
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text('Camera error:\n$_error', textAlign: TextAlign.center),
                  ),
                )
              : Stack(
                  fit: StackFit.expand,
                  children: [
                    CameraPreview(_controller!),
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: FloatingActionButton.large(
                          onPressed: _capture,
                          child: const Icon(Icons.camera_alt),
                        ),
                      ),
                    ),
                  ],
                ),
    );
  }
}
