import 'package:camera/camera.dart';

class CameraService {
  CameraController? _controller;
  List<CameraDescription>? _cameras;
  bool _isInitialized = false;

  CameraController? get controller => _controller;
  bool get isInitialized => _isInitialized;

  Future<void> initialize() async {
    try {
      _cameras = await availableCameras();
      if (_cameras == null || _cameras!.isEmpty) {
        print('CameraService: No cameras available');
        return;
      }

      print('CameraService: Found ${_cameras!.length} cameras');

      // Try to find front camera, otherwise use the first available
      CameraDescription? selectedCamera;

      try {
        selectedCamera = _cameras!.firstWhere(
          (camera) => camera.lensDirection == CameraLensDirection.front,
        );
        print('CameraService: Selected Front Camera');
      } catch (e) {
        print('CameraService: Front camera not found, trying others');
      }

      // Fallback to first camera if no front camera or selection failed
      selectedCamera ??= _cameras!.first;
      print('CameraService: Using camera: ${selectedCamera.name}');

      _controller = CameraController(
        selectedCamera,
        ResolutionPreset.medium,
        enableAudio: false,
      );

      await _controller!.initialize();
      _isInitialized = true;
      print('CameraService: Initialized successfully');
    } catch (e) {
      print('CameraService: Error initializing camera: $e');
      _isInitialized = false;
      // Don't swallow the error completely, let the caller know
    }
  }

  Future<void> dispose() async {
    _isInitialized = false;
    await _controller?.dispose();
    _controller = null;
  }

  Future<XFile?> takePicture() async {
    if (_controller == null || !_controller!.value.isInitialized) {
      return null;
    }

    try {
      return await _controller!.takePicture();
    } catch (e) {
      print('Error taking picture: $e');
      return null;
    }
  }
}
