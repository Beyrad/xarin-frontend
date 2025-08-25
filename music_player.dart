import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:untitled1/login.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:audio_metadata_reader/audio_metadata_reader.dart';
import 'package:untitled1/constants.dart';

// import profile.dart to access getCredentials
import 'profile.dart';

class MusicPlayerPage extends StatefulWidget {
  final List<Map<String, dynamic>> musics;

  const MusicPlayerPage({super.key, required this.musics});

  @override
  _MusicPlayerPageState createState() => _MusicPlayerPageState();
}

class _MusicPlayerPageState extends State<MusicPlayerPage> {
  void showBar(String text) {
    // ScaffoldMessenger.of(context).showSnackBar(
    //   SnackBar(
    //     content: Text(text),
    //     backgroundColor: Colors.blue[900],
    //     duration: const Duration(seconds: 3),
    //   ),
    // );
  }

  Socket? channel;
  String username = "";
  String email = "";
  String password = "";
  late AudioPlayer _player;
  int _currentIndex = 0;
  bool _isPlaying = false;
  bool _isLiked = false;
  bool _hasPermission = false;

  // metadata state
  String _trackTitle = "";
  Uint8List? _albumArt; // embedded cover bytes (if any)

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
    if (await Permission.audio.isGranted) return true;
    if (await Permission.storage.isGranted) return true;

    final statuses = await [Permission.audio, Permission.storage].request();

    return statuses[Permission.audio]?.isGranted == true ||
        statuses[Permission.storage]?.isGranted == true;
  }

  Future<void> is_liked(String musicId) async {
    final directory = Directory('/storage/emulated/0/Download/xarin_credentials');
    final file = File('${directory.path}/credentials.json');

    if (await file.exists()) {
      try {
        final content = await file.readAsString();
        final data = jsonDecode(content);
        username = data['username'];
        password = data['password'];

        if (username.isNotEmpty && password.isNotEmpty) {
          Socket.connect(host, port).then((s) {
            channel = s;

            channel!.listen(
                  (data) {
                final response = utf8.decode(data).trim();
                debugPrint("is_liked response: $response");

                try {
                  final jsonResp = jsonDecode(response);
                  if (jsonResp['status'] == 200) {
                    setState(() => _isLiked = true);
                  } else {
                    setState(() => _isLiked = false);
                  }
                } catch (e) {
                  debugPrint("Error parsing is_liked response: $e");
                }

                channel?.destroy();
              },
              onError: (err) {
                debugPrint("Socket error in is_liked: $err");
                channel?.destroy();
              },
              onDone: () {
                channel?.destroy();
              },
            );

            final req = {
              'method': 'POST',
              'route': '/is_liked/',
              'payload': {
                'username': username,
                'password': password,
                'uuid': musicId,
              }
            };

            final jdata = jsonEncode(req) + '\n';
            channel!.write(jdata);
            channel!.flush();
          }).catchError((e) {
            debugPrint("Failed to connect for is_liked: $e");
          });
        } else {
          _redirectToLogin();
        }
      } catch (e) {
        showBar("Error reading credentials: $e");
        _redirectToLogin();
      }
    } else {
      _redirectToLogin();
    }
  }

  Future<void> _loadMusic() async {
    try {
      final filename = widget.musics[_currentIndex]['filename'] as String;
      final fullPath = "$filename";
      final music = widget.musics[_currentIndex];
      final musicId_ = music['id'] as String;

      // clear old art while loading a new track
      setState(() {
        _albumArt = null;
      });

      // Read metadata (including embedded images)
      final meta = readMetadata(File(fullPath), getImage: true); 
      Uint8List? artBytes;
      if (meta.pictures.isNotEmpty) {
        // Prefer the "front cover" if present
        final front = meta.pictures.where((p) => p.pictureType == PictureType.coverFront);
        artBytes = (front.isNotEmpty ? front.first : meta.pictures.first).bytes;
      }

      setState(() {
        _trackTitle = meta.title ?? filename.replaceAll('.mp3', '');
        _albumArt = artBytes;
      });

      await is_liked(musicId_);
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

  void _redirectToLogin() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => Login()),
    );
  }

  void connecttoadd(int playlist, String id) {
    Socket.connect(host, port).then((s) {
      channel = s;
      showBar('Connected to server');

      channel!.listen(
            (data) {
          final response = utf8.decode(data).trim();
          print('Received wef: $response');
        },
        onError: (error) {
          showBar('Socket error: $error');
        },
        onDone: () {
          showBar('Socket connection closed');
          channel?.destroy();
        },
      );

      add_to_play_list(playlist, id);
    }).catchError((e) {
      showBar('Failed to connect to socket: $e');
    });
  }

  void add_to_play_list(int playlist, String id) {
    final data = {
      'method': 'POST',
      'route': _isLiked
          ? '/playlist/${playlist.toString()}/remove/'
          : '/playlist/${playlist.toString()}/add/',
      'payload': {
        'username': username,
        'password': password,
        'uuid': id,
      }
    };

    final jdata = jsonEncode(data) + '\n';

    try {
      print("Sending: $jdata");
      channel!.write(jdata);
      channel!.flush();
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<void> like(String musicId) async {
    final directory = Directory('/storage/emulated/0/Download/xarin_credentials');
    final file = File('${directory.path}/credentials.json');

    if (await file.exists()) {
      try {
        final content = await file.readAsString();
        final data = jsonDecode(content);
        username = data['username'];
        password = data['password'];

        if (username.isNotEmpty && password.isNotEmpty) {
          connecttoadd(1, musicId);
        } else {
          showBar("Invalid credentials file");
          _redirectToLogin();
        }
      } catch (e) {
        showBar("Error reading credentials: $e");
        _redirectToLogin();
      }
    } else {
      _redirectToLogin();
    }
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
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

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _trackTitle.isNotEmpty ? _trackTitle : music['filename'],
        ),
        centerTitle: true,
        backgroundColor: Colors.blue[900],
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Cover art (embedded) or placeholder
          Container(
            height: 250,
            width: 250,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: Colors.deepPurple.shade100,
              image: DecorationImage(
                image: _albumArt != null
                    ? MemoryImage(_albumArt!)
                    : const AssetImage("assets/cover_placeholder.png") as ImageProvider,
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            _trackTitle.isNotEmpty ? _trackTitle : music['filename'],
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 30),

          // playback progress
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
                        activeColor: Colors.blue[900],
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
                color: Colors.blue[900],
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

          const SizedBox(height: 30),

          ElevatedButton.icon(
            icon: Icon(
              Icons.favorite,
              color: _isLiked ? Colors.red : Colors.grey,
            ),
            label: _isLiked ? const Text('liked') : const Text('like'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue[900],
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              final musicId = music['id'] as String;
              like(musicId);
              sleep(const Duration(milliseconds: 200)); // consider replacing with Future.delayed
              is_liked(musicId);
            },
          ),
        ],
      ),
    );
  }
}
