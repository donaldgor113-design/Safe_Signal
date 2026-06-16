import 'dart:async';
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:safe_signal/core/errors/exceptions.dart';

class VideoService {
  CameraController? _controller;
  bool _isRecording = false;

  bool get isRecording => _isRecording;

  Future<CameraController> initCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        throw const CameraUnavailableException();
      }

      final frontCamera = cameras.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.front,
        orElse: () => cameras.first,
      );

      _controller = CameraController(
        frontCamera,
        ResolutionPreset.medium,
        enableAudio: true,
      );

      await _controller!.initialize();
      return _controller!;
    } on CameraException {
      throw const CameraUnavailableException();
    } catch (e) {
      if (e is CameraUnavailableException) rethrow;
      throw const CameraUnavailableException();
    }
  }

  Future<void> startRecording() async {
    if (_controller == null || !_controller!.value.isInitialized) {
      throw const CameraUnavailableException();
    }
    try {
      await _controller!.startVideoRecording();
      _isRecording = true;
    } on CameraException {
      throw const CameraUnavailableException();
    }
  }

  Future<File?> stopRecording() async {
    if (_controller == null || !_isRecording) return null;
    try {
      final xFile = await _controller!.stopVideoRecording();
      _isRecording = false;
      return File(xFile.path);
    } on CameraException {
      _isRecording = false;
      return null;
    }
  }

  CameraController? get controller => _controller;

  void dispose() {
    _isRecording = false;
    _controller?.dispose();
    _controller = null;
  }
}
