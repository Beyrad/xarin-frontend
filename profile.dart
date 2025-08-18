import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:untitled1/login.dart';

class ProfilePage extends StatefulWidget {
  ProfilePage({super.key});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  Socket? channel;

  // Dynamic user data
  String userName = "Loading...";
  String email = "Loading...";
  final String avatarUrl = "https://via.placeholder.com/150"; // constant avatar

  @override
  void initState() {
    super.initState();
    connect();
  }

  void showBar(String text) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(text),
        backgroundColor: Colors.blue[900],
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void connect() {
    Socket.connect('192.168.1.104', 8888).then((s) {
      channel = s;
      showBar('Connected to server');

      channel!.listen(
            (data) {
          var response = utf8.decode(data).trim();
          print('Received: $response');
          handleServerResponse(response);
        },
        onError: (error) {
          showBar('Socket error: $error');
        },
        onDone: () {
          showBar('Socket connection closed');
          channel?.destroy();
        },
      );

      // Fetch user data immediately after connecting
      getUserData();
    }).catchError((e) {
      showBar('Failed to connect to socket: $e');
    });
  }

  void getUserData() {
    // Replace these credentials with real ones or get from Login session
    var data = {
      'method': 'POST',
      'route': '/user/get_data/',
      'payload': {
        'username': 'amin',
        'password': 'wefwef1Q',
      }
    };

    var jdata = jsonEncode(data) + '\n';

    try {
      print("Sending: $jdata");
      channel!.write(jdata);
      channel!.flush();
      showBar('Requested user data from server');
    } catch (e) {
      showBar('Error: $e');
    }
  }

  void handleServerResponse(String response) {
    try {
      var jsonData = jsonDecode(response);

      if (jsonData['status'] == 200) {
        setState(() {
          userName = jsonData['username'] ?? "Unknown";
          email = jsonData['email'] ?? "Unknown";
        });
        showBar("User data updated");
      } else {
        showBar("Failed to get user data");
      }
    } catch (e) {
      showBar("Error parsing server response: $e");
    }
  }

  void _logout() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => Login()),
    );
  }

  @override
  void dispose() {
    channel?.destroy();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "User Profile",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.blue[900],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            const SizedBox(height: 20),
            CircleAvatar(
              radius: 50,
              backgroundImage: NetworkImage(avatarUrl),
            ),
            const SizedBox(height: 20),
            Text(
              userName,
              style: const TextStyle(
                  fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black),
            ),
            const SizedBox(height: 8),
            Text(
              email,
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: _logout,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                minimumSize: const Size(double.infinity, 50),
              ),
              child: const Text(
                "Logout",
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
