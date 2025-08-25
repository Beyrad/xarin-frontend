import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:untitled1/profile.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:untitled1/constants.dart';
import 'package:file_selector/file_selector.dart';
import 'package:audio_metadata_reader/audio_metadata_reader.dart';

import 'music_player.dart'; 


class _HomePageState extends State<HomePage> {
  Map<String, dynamic> selectedPlaylist = {'id': 0, 'name': 'All'};
  List<Map<String, dynamic>> playlists = [
  ];


  // Store musicName + uuid internally
  List<Map<String, String>> carouselSongs = [];

  final Map<String, List<Map<String, dynamic>>> playlistSongs = {
    "All": [

    ],
    "Likes": [
    ]
  };

  String? _username;
  String? _password;

  @override
  void initState() {
    super.initState();
    _initUserAndLoad();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadAllPlaylistSongs(); 
  }

  void showBar(String text) {
    /*ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(text),
        backgroundColor: Colors.blue[900],
        duration: const Duration(seconds: 2),
      ),
    );*/
  }

  Future<void> _initUserAndLoad() async {
    final creds = await _loadCredentials();
    if (creds != null) {
      _username = creds['username'];
      _password = creds['password'];

      final file = File(
          '/storage/emulated/0/Download/xarin/xarin_data.json');
      if (!await file.exists()) {
        await file.create(recursive: true);
        await file.writeAsString(jsonEncode([]), flush: true);
      }

      _requestPlaylists();
      _loadAllPlaylistSongs();
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
  String formatDuration(int seconds) {
    final minutes = (seconds ~/ 60).toString().padLeft(1, '0');
    final secs = (seconds % 60).toString().padLeft(2, '0');
    return "$minutes:$secs";
  }

  Future<void> _loadAllPlaylistSongs() async {
    if (_username == null || _password == null) return;
    // Make sure playlists are loaded first
    if (playlists.isEmpty) await _requestPlaylists();
    print(playlists.length);
    for (var playlist in playlists) {
      final playlistId = playlist['id'].toString();
      final playlistName = playlist['name'] ?? 'Unknown';
      print("play list number : ");
      print(playlistName);
      final request = {
        "route": "/playlist/" + playlistId + "/",
        "method": "post",
        "payload": {
          "username": _username,
          "password": _password,
        }
      };
      print(playlistId);
      final response = await _sendRequest(request);
      print("wef2");
      print(response);
      if (response != null && response['status'] == 200 &&
          response['playlist'] != null) {
        final playlistData = response['playlist'];
        final musicsList = playlistData['musics'] as List? ?? [];
        final file = File(
            '/storage/emulated/0/Download/xarin/xarin_data.json');

        String content = await file.readAsString();
        var jsonData = jsonDecode(content) as List;
        final Map<String, String> uuidToPath = {
          for (var item in jsonData) item['uuid']: item['path']
        };

        final musics = await Future.wait(
            musicsList.map<Future<Map<String, dynamic>>>((audio) async {
              final fullPath = uuidToPath[audio['id']] ?? "";
              print("dadash");
              print(fullPath);
              String title = audio['musicName'] ?? "Unknown";
              String artist = audio['authorName'] ?? "Unknown";
              String durationStr = audio['duration'] != null ? formatDuration(
                  audio['duration']) : "0:00";

              if (fullPath.isNotEmpty) {
                try {
                  final meta = await readMetadata(File(fullPath));
                  print(meta.title);
                  if (meta.title != null && meta.title!.isNotEmpty)
                    title = meta.title!;
                  if (meta.artist != null && meta.artist!.isNotEmpty)
                    artist = meta.artist!;
                  if (meta.duration != null)
                    durationStr = formatDuration(meta.duration!.inSeconds);
                } catch (e) {
                  // fallback to server data
                }
              }
              print("finally");
              print(title);
              return {
                "title": title,
                "artist": artist,
                "filename": fullPath ?? "",
                "duration": durationStr,
                "id": audio['id'] ?? "",
                "filePath": fullPath,
                "fileSize": audio['fileSize'] ?? 0,
              };
            }
            )
        );
        setState(() {
          playlistSongs[playlistName] = musics;
        });
      } else {
        print("nabayad");
        setState(() {
          playlistSongs[playlistName] = []; // empty if error
        });

        showBar('Failed to load songs for $playlistName');
      }
    }
  }

  Future<void> _onSongOptions(Map<String, dynamic> song) async {
    final choice = await showModalBottomSheet<String>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.playlist_add, color: Colors.green),
              title: const Text("Add to Playlist"),
              onTap: () => Navigator.pop(ctx, "add"),
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text("Remove from Playlist"),
              onTap: () => Navigator.pop(ctx, "remove"),
            ),
          ],
        ),
      ),
    );

    if (choice == null) return;

    if (choice == "add") {
      final targetPlaylist = await showDialog<Map<String, dynamic>>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text("Select Playlist"),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: playlists.length,
              itemBuilder: (c, i) {
                final pl = playlists[i];
                return ListTile(
                  title: Text(pl['name']),
                  onTap: () => Navigator.pop(ctx, pl),
                );
              },
            ),
          ),
        ),
      );

      if (targetPlaylist == null) return;

      final request = {
        "route": "/playlist/${targetPlaylist['id']}/add/",
        "method": "post",
        "payload": {
          "username": _username,
          "password": _password,
          "uuid": song['id'], // uuid of selected song
        }
      };

      final res = await _sendRequest(request);
      if (res != null && res['status'] == 200) {
        showBar("Added to ${targetPlaylist['name']}");
        await _loadAllPlaylistSongs();
      } else {
        showBar("Failed to add: ${res?['message']}");
      }
    }

    if (choice == "remove") {
      final request = {
        "route": "/playlist/${selectedPlaylist['id']}/remove/",
        "method": "post",
        "payload": {
          "username": _username,
          "password": _password,
          "uuid": song['id'], // uuid of selected song
        }
      };

      final res = await _sendRequest(request);
      if (res != null && res['status'] == 200) {
        showBar("Removed from ${selectedPlaylist['name']}");
        await _loadAllPlaylistSongs();
      } else {
        showBar("Failed to remove: ${res?['message']}");
      }
    }
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
          .map<Map<String, dynamic>>((playlist) => {
        'id': playlist['id'],
        'name': playlist['name'] as String,
      })
          .toList();
      print("mast");
      print(fetchedPlaylists[1]);
      setState(() {
        playlists = fetchedPlaylists.isNotEmpty
            ? fetchedPlaylists
            : [
          {'id': 0, 'name': "All"},
        ];
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
    print("wtf");
    print(response);
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
      setState(() {
        _loadAllPlaylistSongs();
      });
    } catch (e) {
      showBar("Download failed: $e");
    }
  }

  Future<void> _addPlaylistDialog() async {
    final controller = TextEditingController();

    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("New Playlist"),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: "Enter playlist name",
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            onPressed: () async {
              final name = controller.text.trim();
              if (name.isEmpty) {
                showBar("Playlist name cannot be empty");
                return;
              }
              Navigator.pop(ctx); // close dialog

              final request = {
                "route": "/playlist/add/",
                "method": "post",
                "payload": {
                  "username": _username,
                  "password": _password,
                  "name": name, // ✅ send playlist name too
                  "maxSize": 30
                }
              };

              final response = await _sendRequest(request);
              if (response != null && response['status'] == 201) {
                setState(() {
                  playlists.add({'id': playlists.length + 1, 'name': name});
                  _requestPlaylists();
                });
                showBar("Playlist created: $name");
              } else {
                showBar("Failed to create playlist: ${response?['message']}");
              }
            },
            child: const Text("Add"),
          ),
        ],
      ),
    );
  }

  Future<void> _removePlaylist() async {
    if (selectedPlaylist['id'] == 0 || selectedPlaylist['id'] == 1) {
      showBar("Cannot remove default playlist");
      return;
    }

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Remove Playlist"),
        content: Text("Are you sure you want to remove '${selectedPlaylist['name']}'?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text("Remove"),
          ),
        ],
      ),
    );

    if (confirm != true) return;
    print("wayyyyy");
    print(selectedPlaylist['id']);
    print(selectedPlaylist['name']);
    final request = {
      "route": "/playlist/remove/",
      "method": "post",
      "payload": {
        "username": _username,
        "password": _password,
        "id": selectedPlaylist['id'],
      }
    };

    final response = await _sendRequest(request);
    if (response != null && response['status'] == 200) {
      setState(() {
        playlists.removeWhere((p) => p['id'] == selectedPlaylist['id']);
        _requestPlaylists();
        selectedPlaylist = playlists.isNotEmpty ? playlists.first : {'id': 0, 'name': 'All'};
      });
      showBar("Removed the playlist!");
    } else {
      showBar("Failed to remove: ${response?['message']}");
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

      final saveDir = Directory('/storage/emulated/0/Download/xarin_musics');
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
      setState(() {
        _loadAllPlaylistSongs();
      });
    } catch (e) {
      showBar("Error picking or uploading file: $e");
    }
  }


  void _playMusic(List<Map<String, dynamic>> song,int index) {
    final rotated = [
      ...song.sublist(index),
      ...song.sublist(0, index),
    ];
    Navigator.push(
        context, MaterialPageRoute(builder: (_) => MusicPlayerPage(musics: rotated)));
  }

  @override
  Widget build(BuildContext context) {
    final currentSongs = playlistSongs[selectedPlaylist['name']] ?? [];

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
              child: Row(
                children: [
                  Expanded(
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
                              _loadAllPlaylistSongs();
                            });
                          },
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 6),
                            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
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
                                name['name'],
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
                  IconButton(
                    icon: const Icon(Icons.add_circle, color: Colors.green, size: 30),
                    onPressed: _addPlaylistDialog,
                  ),
                ],
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
                        onPressed: _removePlaylist, // ✅ hook it up
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
                            onTap: () => _playMusic(currentSongs, index),
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
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(song["duration"]!,
                                    style: TextStyle(
                                        color: Colors.blue[900],
                                        fontWeight: FontWeight.w500)),
                                IconButton(
                                  icon: const Icon(Icons.more_vert, color: Colors.grey),
                                  onPressed: () => _onSongOptions(song),
                                ),
                              ],
                            ),
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
  final Map<String, dynamic> song;
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
