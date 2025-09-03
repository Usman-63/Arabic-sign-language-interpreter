import 'dart:async';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class PhraseVideoPlayer extends StatefulWidget {
  final String title;
  final String videoUrl;

  const PhraseVideoPlayer({
    super.key,
    required this.title,
    required this.videoUrl,
  });

  @override
  State<PhraseVideoPlayer> createState() => _PhraseVideoPlayerState();
}

class _PhraseVideoPlayerState extends State<PhraseVideoPlayer> {
  late VideoPlayerController _controller;
  bool _isLoading = true;
  bool _showControls = true;
  Timer? _controlsTimer;

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

 Future<void> _initializeVideo() async {
  _controller = VideoPlayerController.network(widget.videoUrl)
    ..addListener(() {
      if (_controller.value.isPlaying) {
        setState(() => _isLoading = false);
      }
    });

  try {
    await _controller.initialize();
    await _controller.setVolume(0.0); // 🔇 mute audio
    setState(() {});
    _controller.play();
    _startControlsTimer();
  } catch (e) {
    setState(() => _isLoading = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Failed to load video: $e'), backgroundColor: Colors.red),
    );
  }
}


  void _startControlsTimer() {
    _controlsTimer?.cancel();
    _controlsTimer = Timer(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() => _showControls = false);
      }
    });
  }

  void _toggleControls() {
    setState(() {
      _showControls = !_showControls;
      if (_showControls) {
        _startControlsTimer();
      }
    });
  }

  @override
  void dispose() {
    _controlsTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        centerTitle: true,
        backgroundColor: const Color(0xFF7E22CE),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Video Player
          Center(
            child:
                _controller.value.isInitialized
                    ? GestureDetector(
                      onTap: _toggleControls,
                      child: AspectRatio(
                        aspectRatio: _controller.value.aspectRatio,
                        child: Stack(
                          children: [
                            VideoPlayer(_controller),
                            if (_isLoading)
                              const Center(
                                child: CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Color(0xFF7E22CE),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    )
                    : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Color(0xFF7E22CE),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          'Loading video...',
                          style: TextStyle(
                            color: Colors.grey[300],
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
          ),

          // Controls Overlay
          if (_showControls && _controller.value.isInitialized)
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withOpacity(0.7),
                      Colors.transparent,
                      Colors.transparent,
                      Colors.black.withOpacity(0.7),
                    ],
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Removed duplicate back button from here
                    Expanded(
                      child: Center(
                        child: IconButton(
                          icon: Icon(
                            _controller.value.isPlaying
                                ? Icons.pause
                                : Icons.play_arrow,
                            size: 50,
                            color: Colors.white,
                          ),
                          onPressed: () {
                            setState(() {
                              if (_controller.value.isPlaying) {
                                _controller.pause();
                              } else {
                                _controller.play();
                              }
                            });
                            _startControlsTimer();
                          },
                        ),
                      ),
                    ),
                    VideoProgressIndicator(
                      _controller,
                      allowScrubbing: true,
                      padding: const EdgeInsets.all(10),
                      colors: const VideoProgressColors(
                        playedColor: Color(0xFF7E22CE),
                        bufferedColor: Colors.grey,
                        backgroundColor: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
