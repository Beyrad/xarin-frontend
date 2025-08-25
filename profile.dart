import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:untitled1/login.dart';
import 'package:untitled1/constants.dart';

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
    _checkCredentials();
  }

  void showBar(String text) {
   /* ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(text),
        backgroundColor: Colors.blue[900],
        duration: const Duration(seconds: 3),
      ),
    );*/
  }

  /// Check if credentials.json exists
  Future<void> _checkCredentials() async {
    final directory = Directory('/storage/emulated/0/Download/xarin_credentials');
    final file = File('${directory.path}/credentials.json');

    if (await file.exists()) {
      try {
        final content = await file.readAsString();
        final data = jsonDecode(content);
        final username = data['username'];
        final password = data['password'];

        if (username != null && password != null) {
          connect(username, password);
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

  void _redirectToLogin() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => Login()),
    );
  }

  void connect(String username, String password) {
    Socket.connect(host, port).then((s) {
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

      // Fetch user data with credentials
      getUserData(username, password);
    }).catchError((e) {
      showBar('Failed to connect to socket: $e');
    });
  }

  void getUserData(String username, String password) {
    var data = {
      'method': 'POST',
      'route': '/user/get_data/',
      'payload': {
        'username': username,
        'password': password,
      }
    };

    var jdata = jsonEncode(data) + '\n';
    print("alo");
    print(jdata);
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

  void _logout() async {
    try {
      final directory = Directory('/storage/emulated/0/Download/xarin_credentials');
      final file = File('${directory.path}/credentials.json');

      if (await file.exists()) {
        await file.delete();
        showBar("Credentials deleted");
      }

      final js = File('/storage/emulated/0/Download/xarin/xarin_data.json');
      if (await js.exists()) {
        await js.delete();
        showBar("json file deleted");
      }

    } catch (e) {
      showBar("Error deleting credentials: $e");
    }

    _redirectToLogin();
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
