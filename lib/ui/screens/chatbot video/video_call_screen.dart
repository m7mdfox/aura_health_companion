import 'dart:async';
import 'dart:typed_data';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:permission_handler/permission_handler.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'services/camera_service.dart';
import 'services/gemini_service.dart';
import 'services/stt_service.dart';
import 'services/tts_service.dart';
import 'services/coqui_tts_service.dart';

class VideoCallScreen extends StatefulWidget {
  const VideoCallScreen({super.key});

  @override
  State<VideoCallScreen> createState() => _VideoCallScreenState();
}

class _VideoCallScreenState extends State<VideoCallScreen>
    with WidgetsBindingObserver {
  final CameraService _cameraService = CameraService();
  final TtsService _ttsService = TtsService();
  final CoquiTtsService _coquiTtsService = CoquiTtsService();
  final SttService _sttService = SttService();
  final GeminiService _geminiService = GeminiService();

  bool _isInitialized = false;
  bool _isListening = false;
  bool _isCallActive = false;
  bool _hasPermissions = false;
  bool _useCoquiTts = false;
  bool _showCamera = false;
  bool _cameraPermissionAsked = false;
  bool _isCameraInitializing = false;
  String _coquiUrl =
      kIsWeb ? "http://localhost:5003" : "http://192.168.1.10:5002";
  String _statusText = "Initializing...";
  String _partialText = "";
  double _cameraSize = 150.0;
  Offset _cameraPosition = Offset.zero;
  bool _isCameraDragging = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeServices();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      _stopListening();
      _ttsService.stop();
      _coquiTtsService.stop();
    } else if (state == AppLifecycleState.resumed) {
      if (_isCallActive) {
        _startListening();
      }
      // Reinitialize camera if it was showing
      if (_showCamera && _hasPermissions) {
        _initializeCamera();
      }
    }
  }

  Future<void> _initializeServices() async {
    // Initialize non-camera services first
    await _ttsService.initialize();
    await _sttService.initialize();

    _ttsService.setCompletionHandler(() {
      if (mounted && _isCallActive) {
        setState(() {
          _statusText = "Listening...";
        });
      }
    });

    _coquiTtsService.setCompletionHandler(() {
      if (mounted && _isCallActive) {
        setState(() {
          _statusText = "Listening...";
        });
      }
    });

    setState(() {
      _isInitialized = true;
      _statusText = "Ready. Tap mic to start chat.";
    });
  }

  Future<void> _checkCameraPermission() async {
    if (_cameraPermissionAsked) return;

    final shouldEnableCamera = await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (context) => CameraPermissionDialog(),
        ) ??
        false;

    setState(() {
      _cameraPermissionAsked = true;
    });

    if (shouldEnableCamera) {
      await _initializeCamera();
    } else {
      setState(() {
        _showCamera = false;
        _hasPermissions = false;
        _statusText = "Ready (No Camera). Tap mic to start chat.";
      });
    }
  }

  Future<void> _initializeCamera() async {
    if (_isCameraInitializing) return;

    setState(() {
      _isCameraInitializing = true;
      _statusText = "Initializing Camera...";
    });

    try {
      // Request permissions
      Map<Permission, PermissionStatus> statuses = await [
        Permission.camera,
        Permission.microphone,
      ].request();

      final cameraGranted =
          statuses[Permission.camera] == PermissionStatus.granted;
      final micGranted =
          statuses[Permission.microphone] == PermissionStatus.granted;

      if (!cameraGranted) {
        setState(() {
          _hasPermissions = false;
          _showCamera = false;
          _isCameraInitializing = false;
          _statusText = "Camera permission denied. Working without camera.";
        });
        return;
      }

      // Initialize camera service
      await _cameraService.initialize();

      if (_cameraService.isInitialized && _cameraService.controller != null) {
        setState(() {
          _hasPermissions = true;
          _showCamera = true;
          _isCameraInitializing = false;
          _statusText = "Ready. Tap mic to start chat.";

          // Set initial camera position
          final screenWidth = MediaQuery.of(context).size.width;
          _cameraPosition = Offset(screenWidth - _cameraSize - 20, 20);
        });
      } else {
        setState(() {
          _hasPermissions = false;
          _showCamera = false;
          _isCameraInitializing = false;
          _statusText = "Camera initialization failed. Working without camera.";
        });
      }
    } catch (e) {
      print('Camera initialization error: $e');
      setState(() {
        _hasPermissions = false;
        _showCamera = false;
        _isCameraInitializing = false;
        _statusText = "Camera error. Working without camera.";
      });
    }
  }

  Future<void> _toggleCall() async {
    if (!_isInitialized) return;

    if (_isCallActive) {
      setState(() {
        _isCallActive = false;
        _statusText = "Call Paused.";
        _partialText = "";
      });
      await _stopListening();
      await _ttsService.stop();
      await _coquiTtsService.stop();
    } else {
      setState(() {
        _isCallActive = true;
      });
      await _startListening();
    }
  }

  Future<void> _startListening() async {
    if (!_isInitialized) return;

    setState(() {
      _isListening = true;
      _statusText = "Listening...";
      _partialText = "";
    });

    await _sttService.startListening(
      onResult: (text) {
        _ttsService.stop();
        _coquiTtsService.stop();
        _processUserQuery(text);
      },
      onPartialResult: (text) {
        _ttsService.stop();
        _coquiTtsService.stop();
        setState(() {
          _partialText = text;
        });
      },
    );
  }

  Future<void> _stopListening() async {
    await _sttService.stopListening();
    setState(() {
      _isListening = false;
    });
  }

  void _showTextInput() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        margin: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.6),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF0D1B4C), Color(0xFF162C7A)],
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Type Your Message',
                      style: GoogleFonts.mulish(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: TextField(
                        autofocus: true,
                        style: GoogleFonts.mulish(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: "Type your message...",
                          hintStyle: GoogleFonts.mulish(color: Colors.white70),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.all(16),
                        ),
                        onSubmitted: (text) {
                          Navigator.pop(context);
                          if (text.trim().isNotEmpty) {
                            _ttsService.stop();
                            _coquiTtsService.stop();
                            _processUserQuery(text);
                          }
                        },
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.pop(context),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.white,
                              side: const BorderSide(color: Colors.white54),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text(
                              'Cancel',
                              style: GoogleFonts.mulish(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              final text = _partialText;
                              Navigator.pop(context);
                              if (text.trim().isNotEmpty) {
                                _ttsService.stop();
                                _coquiTtsService.stop();
                                _processUserQuery(text);
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: const Color(0xFF0D1B4C),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 4,
                            ),
                            child: Text(
                              'Send',
                              style: GoogleFonts.mulish(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _processUserQuery(String text) async {
    await _stopListening();

    setState(() {
      _statusText = "Thinking...";
      _partialText = text;
    });

    XFile? imageFile;
    Uint8List? imageBytes;

    if (_showCamera && _hasPermissions && _cameraService.isInitialized) {
      imageFile = await _cameraService.takePicture();
      if (imageFile != null) {
        imageBytes = await imageFile.readAsBytes();
      }
    }

    String? response = await _geminiService.sendMessage(text, imageBytes);

    if (response != null) {
      setState(() {
        _statusText = "Speaking...";
        _partialText = "";
      });

      try {
        if (_useCoquiTts) {
          _coquiTtsService.setBaseUrl(_coquiUrl);
          await _coquiTtsService.speak(response);
        } else {
          await _ttsService.speak(response);
        }
      } catch (e) {
        setState(() {
          _statusText = "TTS Error: $e";
        });
      }

      if (_isCallActive && mounted) {
        await _startListening();
      }
    } else {
      setState(() {
        _statusText = "Error connecting to AI.";
      });
      if (_isCallActive && mounted) {
        await _startListening();
      }
    }
  }

  void _showSettings() {
    TextEditingController urlController = TextEditingController(
      text: _coquiUrl,
    );

    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(20),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 30,
                offset: const Offset(0, 20),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Settings",
                      style: GoogleFonts.mulish(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF0D1B4C),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Container(
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          shape: BoxShape.circle,
                        ),
                        padding: const EdgeInsets.all(4),
                        child: const Icon(
                          Icons.close,
                          color: Colors.grey,
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: SwitchListTile(
                    title: Text(
                      "Use Coqui TTS",
                      style: GoogleFonts.mulish(
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF0D1B4C),
                      ),
                    ),
                    value: _useCoquiTts,
                    onChanged: (value) {
                      setState(() {
                        _useCoquiTts = value;
                      });
                    },
                    activeColor: const Color(0xFF0D1B4C),
                  ),
                ),
                if (_useCoquiTts) ...[
                  const SizedBox(height: 16),
                  buildEnhancedInputField(
                    controller: urlController,
                    label: "Coqui Server URL",
                    onChanged: (value) {
                      _coquiUrl = value;
                    },
                  ),
                ],
                const SizedBox(height: 16),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: SwitchListTile(
                    title: Text(
                      "Show Camera",
                      style: GoogleFonts.mulish(
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF0D1B4C),
                      ),
                    ),
                    value: _showCamera,
                    onChanged: (value) async {
                      if (value &&
                          !_hasPermissions &&
                          !_cameraPermissionAsked) {
                        Navigator.pop(context);
                        await _checkCameraPermission();
                      } else if (value && !_hasPermissions) {
                        Navigator.pop(context);
                        await _initializeCamera();
                      } else {
                        setState(() {
                          _showCamera = value;
                        });
                      }
                    },
                    activeColor: const Color(0xFF0D1B4C),
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0D1B4C),
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 50),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 4,
                  ),
                  child: Text(
                    'Save Settings',
                    style: GoogleFonts.mulish(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _toggleCameraVisibility() {
    if (!_showCamera && !_cameraPermissionAsked) {
      _checkCameraPermission();
    } else if (!_showCamera && _hasPermissions) {
      _initializeCamera();
    } else {
      setState(() {
        _showCamera = !_showCamera;
      });
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _cameraService.dispose();
    _ttsService.stop();
    _coquiTtsService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF0D1B4C),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF0D1B4C).withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
          ),
        ),
        title: Text(
          'AI Video Call',
          style: GoogleFonts.mulish(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(30),
              bottomRight: Radius.circular(30),
            ),
            gradient: LinearGradient(
              colors: [Color(0xFF00177E), Color(0xFF0F1120)],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
          ),
        ),
      ),
      body: Stack(
        children: [
          // Background Pattern
          Positioned(
            top: 0,
            right: 0,
            child: Opacity(
              opacity: 0.1,
              child: Image.asset(
                'assets/PatternLogin.png',
                width: MediaQuery.of(context).size.width * 0.8,
                height: MediaQuery.of(context).size.height * 0.4,
                fit: BoxFit.cover,
                errorBuilder: (ctx, err, stack) => const SizedBox(),
              ),
            ),
          ),

          // Main Content
          Column(
            children: [
              // Main AI Animation Area
              Expanded(
                flex: 2,
                child: Center(
                  child: Container(
                    width: 300,
                    height: 300,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFF0D1B4C).withOpacity(0.05),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF0D1B4C).withOpacity(0.1),
                          blurRadius: 30,
                          spreadRadius: 0,
                        ),
                      ],
                    ),
                    child: Lottie.asset(
                      'assets/animation.json',
                      fit: BoxFit.contain,
                      frameRate: FrameRate(60),
                      errorBuilder: (context, error, stackTrace) {
                        return Icon(
                          Icons.smart_toy_outlined,
                          color: const Color(0xFF0D1B4C),
                          size: 80,
                        );
                      },
                    ),
                  ),
                ),
              ),

              // Controls Section
              Expanded(
                flex: 1,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.white, Color(0xFFF8F9FF)],
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // Status and Partial Text
                      Column(
                        children: [
                          if (_partialText.isNotEmpty)
                            Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade50,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: Colors.grey.shade200),
                              ),
                              child: Text(
                                _partialText,
                                textAlign: TextAlign.center,
                                style: GoogleFonts.mulish(
                                  color: const Color(0xFF0D1B4C),
                                  fontSize: 14,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF0D1B4C).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(30),
                              border: Border.all(
                                color: const Color(0xFF0D1B4C).withOpacity(0.2),
                              ),
                            ),
                            child: Text(
                              _statusText,
                              textAlign: TextAlign.center,
                              style: GoogleFonts.mulish(
                                color: const Color(0xFF0D1B4C),
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),

                      // Control Buttons
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildControlButton(
                            icon: Icons.settings,
                            onTap: _showSettings,
                            color: Colors.grey.shade600,
                          ),
                          _buildControlButton(
                            icon: Icons.keyboard,
                            onTap: _showTextInput,
                            color: Colors.grey.shade600,
                          ),
                          _buildControlButton(
                            icon: _showCamera
                                ? Icons.videocam_off
                                : Icons.videocam,
                            onTap: _toggleCameraVisibility,
                            color: _showCamera
                                ? Colors.green
                                : Colors.grey.shade600,
                          ),
                          _buildMainButton(
                            isActive: _isCallActive,
                            onTap: _toggleCall,
                          ),
                          _buildControlButton(
                            icon: Icons.call_end,
                            onTap: () => Navigator.of(context).pop(),
                            color: Colors.red,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // Floating Camera Window
          if (_showCamera &&
              _cameraService.controller != null &&
              _cameraService.isInitialized)
            Positioned(
              top: _cameraPosition.dy,
              left: _cameraPosition.dx,
              child: GestureDetector(
                onPanStart: (details) {
                  setState(() {
                    _isCameraDragging = true;
                  });
                },
                onPanUpdate: (details) {
                  setState(() {
                    _cameraPosition += details.delta;
                  });
                },
                onPanEnd: (details) {
                  setState(() {
                    _isCameraDragging = false;
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: _cameraSize,
                  height: _cameraSize,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(
                          _isCameraDragging ? 0.4 : 0.3,
                        ),
                        blurRadius: _isCameraDragging ? 20 : 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                    border: Border.all(
                      color: _isCameraDragging ? Colors.blue : Colors.white,
                      width: _isCameraDragging ? 3 : 2,
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: Stack(
                      children: [
                        CameraPreview(_cameraService.controller!),
                        // Close button for camera
                        Positioned(
                          top: 4,
                          right: 4,
                          child: GestureDetector(
                            onTap: _toggleCameraVisibility,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.5),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.close,
                                color: Colors.white,
                                size: 16,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

          // Camera initialization overlay
          if (_isCameraInitializing)
            Positioned.fill(
              child: Container(
                color: Colors.black.withOpacity(0.3),
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const CircularProgressIndicator(
                          color: Color(0xFF0D1B4C),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Initializing Camera...',
                          style: GoogleFonts.mulish(
                            color: const Color(0xFF0D1B4C),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required VoidCallback onTap,
    required Color color,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Icon(icon, color: color, size: 22),
        ),
      ),
    );
  }

  Widget _buildMainButton({
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(25),
        child: Container(
          width: 70,
          height: 70,
          decoration: BoxDecoration(
            gradient: isActive
                ? const LinearGradient(
                    colors: [Color(0xFFFF6B6B), Color(0xFFEE5A5A)],
                  )
                : const LinearGradient(
                    colors: [Color(0xFF0D1B4C), Color(0xFF162C7A)],
                  ),
            borderRadius: BorderRadius.circular(25),
            boxShadow: [
              BoxShadow(
                color: isActive
                    ? const Color(0xFFFF6B6B).withOpacity(0.4)
                    : const Color(0xFF0D1B4C).withOpacity(0.4),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Icon(
            isActive ? Icons.mic_off : Icons.mic,
            color: Colors.white,
            size: 28,
          ),
        ),
      ),
    );
  }
}

class CameraPermissionDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Lottie.asset(
              'assets/animation.json',
              width: 80,
              height: 80,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 16),
            Text(
              'Camera Access',
              style: GoogleFonts.mulish(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF0D1B4C),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'This app needs camera access to send visual context to the AI assistant. Would you like to enable the camera?',
              textAlign: TextAlign.center,
              style: GoogleFonts.mulish(color: Colors.grey.shade600),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF0D1B4C),
                      side: const BorderSide(color: Color(0xFF0D1B4C)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Continue Without',
                      style: GoogleFonts.mulish(fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0D1B4C),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Enable Camera',
                      style: GoogleFonts.mulish(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// Reuse the same input field style from medicine screen
Widget buildEnhancedInputField({
  required TextEditingController controller,
  required String label,
  TextInputType? keyboardType,
  String? Function(String?)? validator,
  void Function(String)? onChanged,
}) {
  return TextFormField(
    controller: controller,
    keyboardType: keyboardType,
    validator: validator,
    onChanged: onChanged,
    style: GoogleFonts.mulish(
      color: const Color(0xFF0D1B4C),
      fontWeight: FontWeight.w500,
    ),
    decoration: InputDecoration(
      labelText: label,
      labelStyle: GoogleFonts.mulish(
        color: Colors.grey.shade600,
        fontWeight: FontWeight.w500,
      ),
      filled: true,
      fillColor: Colors.grey.shade50,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300, width: 1.5),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF0D1B4C), width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.red.shade400, width: 1.5),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.red.shade400, width: 2),
      ),
      errorStyle: GoogleFonts.mulish(
        color: Colors.red.shade400,
        fontSize: 12,
        fontWeight: FontWeight.w500,
      ),
    ),
  );
}
