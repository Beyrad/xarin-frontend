import 'dart:async';
import 'package:flutter/material.dart';
import 'package:r/profile.dart';
import 'package:carousel_slider/carousel_slider.dart';

class HomePage extends StatefulWidget {
  final String username;
  const HomePage({Key? key, required this.username}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String selectedPlaylist = "All";

  final List<String> playlists = [
    "All",
    "Liked",
    "Sonati",
    "Rap",
    "Pop",
    "Rock"
  ];

  final List<String> carouselSongs = [
    "eshgh_to",
    "az_aval",
    "aali_boodi",
    "be_khodam",
    "royaye_shirin",
    "delbare_man",
    "ashegh_shodam",
  ];

  final Map<String, List<Map<String, String>>> playlistSongs = {
    "All": [
      {"title": "wefbywefdedsd", "artist": "amin", "duration": "2:31"},
      {"title": "ewewewrŵrewrwrw", "artist": "behnan", "duration": "4:50"},
      {"title": "wercokr9ojeerjg", "artist": "salam", "duration": "7:00"},
      {"title": "werwerewrer", "artist": "reza sadeghi", "duration": "23:01"},
    ],
    "Liked": [
      {"title": "love_song", "artist": "ali", "duration": "3:15"},
      {"title": "happy_day", "artist": "mohammad", "duration": "4:12"},
    ],
    "Rap": [
      {"title": "rap_shah", "artist": "mc x", "duration": "2:45"},
      {"title": "underground", "artist": "yasin", "duration": "3:40"},
    ],
  };

  void _goToProfile() {
    Navigator.push(context, MaterialPageRoute(builder: (_) => ProfilePage()));
  }

  void _uploadMusic() {
    // TODO: implement upload API call
  }

  void _removePlaylist() {
    // TODO: implement remove playlist API call
  }

  void _playMusic(Map<String, String> song) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => PlayMusic(song: song)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentSongs = playlistSongs[selectedPlaylist] ?? [];

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.blue[900],
        elevation: 0,
        automaticallyImplyLeading: false, // disable default leading slot
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
                  widget.username,
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
            Text(
              "Xarin",
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 22,
                color: Colors.white,
              ),
            ),
            const Spacer(flex: 2), // pushes add button to far right
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
            // Playlists row (clickable)
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
                      padding: const EdgeInsets.symmetric(
                          horizontal: 18, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.blue[900] : Colors.white,
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(color: Colors.blue[900]!),
                        boxShadow: isSelected
                            ? [
                          BoxShadow(
                            color: Colors.blue.shade200,
                            blurRadius: 8,
                            offset: Offset(0, 4),
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

            // Big Rotating store songs (Carousel)
            // Small centered sliding boxes (Carousel)
            SizedBox(
              height: 100,
              child: CarouselSlider(
                options: CarouselOptions(
                  height: 100,
                  autoPlay: true,
                  autoPlayInterval: Duration(seconds: 2),
                  autoPlayAnimationDuration: Duration(milliseconds: 800),
                  viewportFraction: 0.35, // smaller width per item
                  enlargeCenterPage: true,
                  enableInfiniteScroll: true,
                  scrollPhysics: BouncingScrollPhysics(),
                ),
                items: carouselSongs.map((song) {
                  return Builder(
                    builder: (BuildContext context) {
                      return Align(
                        alignment: Alignment.center,
                        child: Container(
                          width: 120,
                          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Colors.blue[400]!, Colors.blue[900]!],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black26,
                                blurRadius: 6,
                                offset: Offset(0, 3),
                              )
                            ],
                          ),
                          child: Center(
                            child: Text(
                              song,
                              textAlign: TextAlign.center,
                              style: TextStyle(
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
                      );
                    },
                  );
                }).toList(),
              ),
            ),

            const SizedBox(height: 20),

            // Songs list
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blue[900]!.withOpacity(0.1),
                      blurRadius: 8,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Negative sign at top
                    Align(
                      alignment: Alignment.centerRight,
                      child: IconButton(
                        icon: Icon(Icons.remove_circle,
                            color: Colors.red[700], size: 28),
                        onPressed: _removePlaylist,
                      ),
                    ),

                    // Songs list
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
                              child: Icon(Icons.music_note,
                                  color: Colors.blue[900]),
                            ),
                            title: Text(
                              song["title"]!,
                              style: TextStyle(
                                color: Colors.grey[900],
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Text(
                              song["artist"]!,
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                            trailing: Text(
                              song["duration"]!,
                              style: TextStyle(
                                color: Colors.blue[900],
                                fontWeight: FontWeight.w500,
                              ),
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

class PlayMusic extends StatelessWidget {
  final Map<String, String> song;
  const PlayMusic({Key? key, required this.song}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.black,
        body: Center(
            child: Text("Playing: ${song["title"]}",
                style: TextStyle(color: Colors.white, fontSize: 24))));
  }
}
