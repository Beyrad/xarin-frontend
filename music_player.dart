import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:permission_handler/permission_handler.dart';

class MusicPlayerPage extends StatefulWidget {
  final List<Map<String, dynamic>> musics;
  // Example: [{'id': 1, 'filename': 'mehrad_hidden_shayea_-_seyl.mp3'}]

  const MusicPlayerPage({super.key, required this.musics});

  @override
  _MusicPlayerPageState createState() => _MusicPlayerPageState();
}

class _MusicPlayerPageState extends State<MusicPlayerPage> {
  late AudioPlayer _player;
  int _currentIndex = 0;
  bool _isPlaying = false;
  bool _hasPermission = false;

  @override
  void initState() {
    super.initState();
    _player = AudioPlayer();
    _checkPermissionAndLoad();
  }

  Future<void> _checkPermissionAndLoad() async {
    _hasPermission = await _requestAudioPermission();
    if (!_hasPermission) return;

    await _loadMusic();
  }

  Future<bool> _requestAudioPermission() async {
    // For Android 13+
    if (await Permission.audio.isGranted) return true;

    // For Android 12 and lower
    if (await Permission.storage.isGranted) return true;

    var statuses = await [
      Permission.audio,
      Permission.storage,
    ].request();

    return statuses[Permission.audio]?.isGranted == true ||
        statuses[Permission.storage]?.isGranted == true;
  }

  Future<void> _loadMusic() async {
    try {
      final filename = widget.musics[_currentIndex]['filename'] as String;
      final fullPath = "/storage/emulated/0/Download/xarin_musics/$filename";

      await _player.setFilePath(fullPath);
      setState(() => _isPlaying = false);
    } catch (e) {
      debugPrint("Error loading music: $e");
    }
  }

  void _playPause() {
    if (!_hasPermission) return;
    if (_player.playing) {
      _player.pause();
      setState(() => _isPlaying = false);
    } else {
      _player.play();
      setState(() => _isPlaying = true);
    }
  }

  void _next() async {
    if (!_hasPermission) return;
    if (_currentIndex < widget.musics.length - 1) {
      _currentIndex++;
      await _loadMusic();
      _player.play();
      setState(() => _isPlaying = true);
    }
  }

  void _previous() async {
    if (!_hasPermission) return;
    if (_currentIndex > 0) {
      _currentIndex--;
      await _loadMusic();
      _player.play();
      setState(() => _isPlaying = true);
    }
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  String _displayName(String filename) {
    return filename.replaceAll('.mp3', '');
  }

  @override
  Widget build(BuildContext context) {
    if (!_hasPermission) {
      return Scaffold(
        appBar: AppBar(title: const Text("Music Player")),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "Audio permission required to play music",
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _checkPermissionAndLoad,
                child: const Text("Grant Permission"),
              ),
            ],
          ),
        ),
      );
    }

    final music = widget.musics[_currentIndex];
    final filename = music['filename'] as String;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _displayName(filename),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.deepPurple,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Album Art Placeholder
          Container(
            height: 250,
            width: 250,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: Colors.deepPurple.shade100,
              image: const DecorationImage(
                image: AssetImage("assets/cover_placeholder.png"),
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(height: 30),

          // Progress bar
          StreamBuilder<Duration?>(
            stream: _player.durationStream,
            builder: (context, snapshot) {
              final duration = snapshot.data ?? Duration.zero;
              return StreamBuilder<Duration>(
                stream: _player.positionStream,
                builder: (context, snapshot) {
                  final position = snapshot.data ?? Duration.zero;
                  return Column(
                    children: [
                      Slider(
                        activeColor: Colors.deepPurple,
                        min: 0,
                        max: duration.inSeconds.toDouble(),
                        value: position.inSeconds
                            .clamp(0, duration.inSeconds)
                            .toDouble(),
                        onChanged: (value) {
                          _player.seek(Duration(seconds: value.toInt()));
                        },
                      ),
                      Text(
                        "${position.toString().split('.').first} / ${duration.toString().split('.').first}",
                        style: const TextStyle(fontSize: 14),
                      ),
                    ],
                  );
                },
              );
            },
          ),

          const SizedBox(height: 20),

          // Controls
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                iconSize: 48,
                icon: const Icon(Icons.skip_previous),
                onPressed: _previous,
              ),
              IconButton(
                iconSize: 64,
                color: Colors.deepPurple,
                icon: Icon(_isPlaying ? Icons.pause_circle : Icons.play_circle),
                onPressed: _playPause,
              ),
              IconButton(
                iconSize: 48,
                icon: const Icon(Icons.skip_next),
                onPressed: _next,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
