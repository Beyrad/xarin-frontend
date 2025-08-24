import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:untitled1/profile.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:untitled1/constants.dart';
import 'package:file_selector/file_selector.dart';

class _HomePageState extends State<HomePage> {
  String selectedPlaylist = "All";
  List<String> playlists = ["All"];

  // Store musicName + uuid internally
  List<Map<String, String>> carouselSongs = [];

  final Map<String, List<Map<String, String>>> playlistSongs = {
    "All": [
      {"title": "wefbywefdedsd", "artist": "amin", "duration": "2:31"},
      {"title": "ewewewrŵrewrwrw", "artist": "behnan", "duration": "4:50"},
      {"title": "wercokr9ojeerjg", "artist": "salam", "duration": "7:00"},
      {"title": "werwerewrer", "artist": "reza sadeghi", "duration": "23:01"},
    ],
    "Likes": [
      {"title": "like1", "artist": "amin", "duration": "2:01"},
    ]
  };

  String? _username;
  String? _password;

  @override
  void initState() {
    super.initState();
    _initUserAndLoad();
  }

  void showBar(String text) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(text),
        backgroundColor: Colors.blue[900],
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _initUserAndLoad() async {
    final creds = await _loadCredentials();
    if (creds != null) {
      _username = creds['username'];
      _password = creds['password'];
      _requestPlaylists();
      _requestCarouselSongs();
    } else {
      showBar("Credentials not found!");
    }
  }

  Future<Map<String, String>?> _loadCredentials() async {
    try {
      final directory =
      Directory('/storage/emulated/0/Download/xarin_credentials');
      final file = File('${directory.path}/credentials.json');

      if (await file.exists()) {
        final content = await file.readAsString();
        final data = jsonDecode(content);
        if (data['username'] != null && data['password'] != null) {
          return {"username": data['username'], "password": data['password']};
        }
      }
    } catch (e) {
      showBar("Error reading credentials: $e");
    }
    return null;
  }

  Future<Map<String, dynamic>?> _sendRequest(
      Map<String, dynamic> request) async {
    try {
      final socket = await Socket.connect(host, port,
          timeout: const Duration(seconds: 5));

      socket.write(jsonEncode(request) + "\n");
      await socket.flush();

      final completer = Completer<Map<String, dynamic>?>();
      socket.listen(
            (data) {
          final response = utf8.decode(data).trim();
          try {
            final jsonResponse = jsonDecode(response);
            completer.complete(jsonResponse);
          } catch (e) {
            completer.completeError("Invalid JSON: $e");
          } finally {
            socket.destroy();
          }
        },
        onError: (error) {
          showBar("Socket error: $error");
          completer.complete(null);
          socket.destroy();
        },
        onDone: () {
          socket.destroy();
        },
      );

      return completer.future;
    } catch (e) {
      showBar("Failed to connect: $e");
      return null;
    }
  }

  Future<void> _requestPlaylists() async {
    if (_username == null || _password == null) return;

    final request = {
      "route": "/playlist/",
      "method": "post",
      "payload": {"username": _username, "password": _password}
    };

    showBar("Requesting playlists...");
    final response = await _sendRequest(request);

    if (response == null) return;
    if (response['status'] == 200 && response['playlists'] != null) {
      final fetchedPlaylists = (response['playlists'] as List)
          .map<String>((playlist) => playlist['name'] as String)
          .toList();

      setState(() {
        playlists =
        fetchedPlaylists.isNotEmpty ? fetchedPlaylists : ["All", "Likes"];
        selectedPlaylist = playlists.first;
      });
      showBar('Playlists loaded successfully');
    } else {
      showBar('Failed to load playlists: ${response['message']}');
    }
  }

  Future<void> _requestCarouselSongs() async {
    if (_username == null || _password == null) return;

    final request = {
      "route": "/audio/get/",
      "method": "post",
      "payload": {"username": _username, "password": _password}
    };

    showBar("Requesting carousel songs...");
    final response = await _sendRequest(request);

    if (response == null) return;

    if (response['status'] == 200 && response['audios'] is List) {
      final fetchedSongs = (response['audios'] as List)
          .where((audio) =>
      audio['musicName'] != null && audio['id'] != null)
          .map<Map<String, String>>((audio) => {
        "musicName": audio['musicName'] as String,
        "uuid": audio['id'] as String, // note: use "id" from API
      })
          .toList();

      setState(() {
        carouselSongs = fetchedSongs; // assign Map with musicName + uuid
      });
      showBar('Carousel songs loaded');
    } else {
      showBar(
          'Failed to load carousel: ${response['message'] ?? "invalid format"}');
    }
  }

  void _goToProfile() {
    Navigator.push(context, MaterialPageRoute(builder: (_) => ProfilePage()));
  }

  Future<void> _onCarouselTap(String musicName) async {
    final song =
    carouselSongs.firstWhere((element) => element['musicName'] == musicName);
    final uuid = song['uuid']!;

    final dataFile = File('/storage/emulated/0/Download/xarin/xarin_data.json');
    if (!await dataFile.exists()) {
      await dataFile.create(recursive: true);
      await dataFile.writeAsString(jsonEncode([]), flush: true);
    }

    final content = await dataFile.readAsString();
    List<dynamic> mappings = [];
    if (content.isNotEmpty) mappings = jsonDecode(content);

    final existing = mappings.any((element) => element['uuid'] == uuid);
    if (existing) {
      showBar("File already downloaded!");
      return;
    }

    final request = {
      "route": "/audio/download/$uuid/",
      "method": "post",
      "payload": {"username": _username, "password": _password}
    };
    showBar("Downloading $musicName...");

    try {
      final socket = await Socket.connect(host, port);
      socket.write(jsonEncode(request) + "\n");
      await socket.flush();
      final completer = Completer<String>();
      final buffer = StringBuffer();

      socket.listen(
            (data) {
          buffer.write(utf8.decode(data));

          // check if end marker reached
          if (buffer.toString().contains("*") && !completer.isCompleted) {
            completer.complete(buffer.toString().trim());
            socket.destroy(); // stop reading further
          }
        },
        onError: (error) {
          showBar("Socket error: $error");
          if (!completer.isCompleted) completer.completeError(error);
          socket.destroy();
        },
      );

      final base64Str = await completer.future;
      if (base64Str == "E") {
        showBar("Server returned error!");
        return;
      }

      if (!base64Str.startsWith("G") || !base64Str.endsWith("*")) {
        showBar("Invalid response format!");
        return;
      }

      // Extract pure base64 between G and *
      final pureBase64 = base64Str.substring(1, base64Str.length - 1);
      final bytes = base64Decode(pureBase64);

      final saveDir = Directory('/storage/emulated/0/Download/xarin_musics/');
      if (!await saveDir.exists()) await saveDir.create(recursive: true);

      final savedFile = File('${saveDir.path}/$musicName.mp3');
      await savedFile.writeAsBytes(bytes, flush: true);

      mappings.add({"uuid": uuid, "path": savedFile.path});
      await dataFile.writeAsString(jsonEncode(mappings), flush: true);

      showBar("$musicName downloaded successfully!");
    } catch (e) {
      showBar("Download failed: $e");
    }
  }

  Future<void> _uploadMusic() async {
    if (_username == null || _password == null) {
      showBar("Missing credentials");
      return;
    }

    try {
      const typeGroup =
      XTypeGroup(label: 'audio', extensions: ['mp3'], mimeTypes: ['audio/mpeg']);
      final XFile? pickedFile =
      await openFile(acceptedTypeGroups: [typeGroup]);

      if (pickedFile == null) return;

      final file = File(pickedFile.path);
      if (!await file.exists()) {
        showBar("File not found");
        return;
      }

      final saveDir = Directory('/storage/emulated/0/Download/xarin_musics/');
      if (!await saveDir.exists()) await saveDir.create(recursive: true);

      final savedFile =
      await file.copy('${saveDir.path}/${file.uri.pathSegments.last}');

      final fileBytes = await savedFile.readAsBytes();
      final base64Str = base64Encode(fileBytes);

      showBar("Uploading music...");

      final request = {
        "route": "/audio/upload/",
        "method": "post",
        "payload": {
          "username": _username,
          "password": _password,
          "base64": base64Str,
        }
      };

      final response = await _sendRequest(request);

      if (response == null || response['status'] != 200) {
        showBar("Upload failed: ${response?['message'] ?? 'Unknown error'}");
        return;
      }

      final uuid = response['uuid'];

      final dataFile = File('/storage/emulated/0/Download/xarin/xarin_data.json');
      if (!await dataFile.exists()) {
        await dataFile.create(recursive: true);
        await dataFile.writeAsString(jsonEncode([]), flush: true);
      }

      final content = await dataFile.readAsString();
      List<dynamic> mappings = [];
      if (content.isNotEmpty) {
        mappings = jsonDecode(content);
      }

      mappings.add({"uuid": uuid, "path": savedFile.path});
      await dataFile.writeAsString(jsonEncode(mappings), flush: true);

      showBar("Upload successful!");
    } catch (e) {
      showBar("Error picking or uploading file: $e");
    }
  }

  void _removePlaylist() {}

  void _playMusic(Map<String, String> song) {
    Navigator.push(
        context, MaterialPageRoute(builder: (_) => PlayMusic(song: song)));
  }

  @override
  Widget build(BuildContext context) {
    final currentSongs = playlistSongs[selectedPlaylist] ?? [];

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.blue[900],
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            GestureDetector(
              onTap: _goToProfile,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  _username ?? "User",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
            const Spacer(),
            const Text(
              "Xarin",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 22,
                color: Colors.white,
              ),
            ),
            const Spacer(flex: 2),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Colors.white),
            onPressed: _uploadMusic,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 45,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: playlists.length,
                itemBuilder: (context, index) {
                  final name = playlists[index];
                  final isSelected = name == selectedPlaylist;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedPlaylist = name;
                      });
                    },
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 6),
                      padding:
                      const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.blue[900] : Colors.white,
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(color: Colors.blue[900]!),
                        boxShadow: isSelected
                            ? [
                          BoxShadow(
                            color: Colors.blue.shade200,
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          )
                        ]
                            : [],
                      ),
                      child: Center(
                        child: Text(
                          name,
                          style: TextStyle(
                            color: isSelected ? Colors.white : Colors.blue[900],
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 100,
              child: carouselSongs.isEmpty
                  ? const Center(child: Text("No songs yet"))
                  : CarouselSlider(
                options: CarouselOptions(
                  height: 100,
                  autoPlay: true,
                  autoPlayInterval: const Duration(seconds: 2),
                  autoPlayAnimationDuration:
                  const Duration(milliseconds: 800),
                  viewportFraction: 0.35,
                  enlargeCenterPage: true,
                  enableInfiniteScroll: true,
                  scrollPhysics: const BouncingScrollPhysics(),
                ),
                items: carouselSongs.map((song) {
                  final musicName = song['musicName']!;
                  return Builder(
                    builder: (BuildContext context) {
                      return GestureDetector(
                        onTap: () => _onCarouselTap(musicName),
                        child: Align(
                          alignment: Alignment.center,
                          child: Container(
                            width: 120,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [Colors.blue[400]!, Colors.blue[900]!],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: const [
                                BoxShadow(
                                  color: Colors.black26,
                                  blurRadius: 6,
                                  offset: Offset(0, 3),
                                )
                              ],
                            ),
                            child: Center(
                              child: Text(
                                musicName,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  shadows: [
                                    Shadow(
                                        color: Colors.black54,
                                        blurRadius: 4,
                                        offset: Offset(1, 1))
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blue[900]!.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Align(
                      alignment: Alignment.centerRight,
                      child: IconButton(
                        icon: Icon(Icons.remove_circle,
                            color: Colors.red[700], size: 28),
                        onPressed: _removePlaylist,
                      ),
                    ),
                    Expanded(
                      child: ListView.separated(
                        itemCount: currentSongs.length,
                        separatorBuilder: (_, __) => Divider(
                          height: 1,
                          color: Colors.grey[300],
                          indent: 16,
                          endIndent: 16,
                        ),
                        itemBuilder: (context, index) {
                          final song = currentSongs[index];
                          return ListTile(
                            onTap: () => _playMusic(song),
                            leading: CircleAvatar(
                              backgroundColor: Colors.blue[100],
                              child: Icon(Icons.music_note, color: Colors.blue[900]),
                            ),
                            title: Text(
                              song["title"]!,
                              style: TextStyle(
                                  color: Colors.grey[900],
                                  fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text(song["artist"]!,
                                style: TextStyle(color: Colors.grey[600])),
                            trailing: Text(song["duration"]!,
                                style: TextStyle(
                                    color: Colors.blue[900],
                                    fontWeight: FontWeight.w500)),
                          );
                        },
                      ),
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
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class PlayMusic extends StatelessWidget {
  final Map<String, String> song;
  const PlayMusic({Key? key, required this.song}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Text(
          "Playing: ${song["title"]}",
          style: const TextStyle(color: Colors.white, fontSize: 24),
        ),
      ),
    );
  }
} 
