import 'dart:convert';
import 'dart:io';
import 'package:untitled1/login.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:permission_handler/permission_handler.dart';

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
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(text),
        backgroundColor: Colors.blue[900],
        duration: const Duration(seconds: 3),
      ),
    );
  }
  Socket? channel;
  String username="";
  String email="";
  String password="";
  late AudioPlayer _player;
  int _currentIndex = 0;
  bool _isPlaying = false;
  bool _isLiked = false;
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
    if (await Permission.audio.isGranted) return true;
    if (await Permission.storage.isGranted) return true;

    var statuses = await [
      Permission.audio,
      Permission.storage,
    ].request();

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
          Socket.connect('192.168.1.104', 8888).then((s) {
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

            var req = {
              'method': 'POST',
              'route': '/is_liked/',
              'payload': {
                'username': username,
                'password': password,
                'uuid': musicId,
              }
            };

            var jdata = jsonEncode(req) + '\n';
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
      final fullPath = "/storage/emulated/0/Download/xarin_musics/$filename";
      final music = widget.musics[_currentIndex];
      final musicId_ = music['id'] as String;
      is_liked(musicId_);
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
    Socket.connect('192.168.1.104', 8888).then((s) {
      channel = s;
      showBar('Connected to server');

      channel!.listen(
            (data) {
          var response = utf8.decode(data).trim();
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

      // Fetch user data with credentials
      add_to_play_list(playlist, id);
    }).catchError((e) {
      showBar('Failed to connect to socket: $e');
    });
  }
  void add_to_play_list(int playlist, String id) {
    var data = {
      'method': 'POST',
      'route': '/playlist/' + playlist.toString() + '/add/',
      'payload': {
        'username': username,
        'password': password,
        'uuid' : id,
      }
    };

    var jdata = jsonEncode(data) + '\n';

    try {
      print("Sending: $jdata");
      channel!.write(jdata);
      channel!.flush();
    } catch (e) {
      print('Error: $e');
    }
  }
  // ---------------- NEW CODE ----------------
  Future<void> like(String musicId) async {
    debugPrint("rinned wef");
      final directory = Directory('/storage/emulated/0/Download/xarin_credentials');
      final file = File('${directory.path}/credentials.json');

      if (await file.exists()) {
        try {
          final content = await file.readAsString();
          final data = jsonDecode(content);
          username = data['username'];
          password = data['password'];

          if (username != null && password != null) {
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
        // No credentials, go back to login page
        _redirectToLogin();
      }
  }
  // ------------------------------------------

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

          const SizedBox(height: 30),

          // ---------------- NEW BUTTON ----------------
          ElevatedButton.icon(
            icon: Icon(Icons.favorite,
                color: _isLiked ? Colors.red : Colors.grey),
            label: _isLiked ? const Text('liked') : const Text('like'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepPurple,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              final musicId = music['id'] as String;
              like(musicId);
              is_liked(musicId); // refresh after liking
            },
          ),
          // --------------------------------------------
        ],
      ),
    );
  }
}
