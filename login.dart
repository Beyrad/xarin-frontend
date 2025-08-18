import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:r/register.dart';

class Login extends StatefulWidget {
  @override
  LoginState createState() => LoginState();
}

class LoginState extends State<Login> {
  var usernameController = TextEditingController();
  var passwordController = TextEditingController();
  Socket? channel;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
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
    Socket.connect('10.71.110.137', 8888).then((s) {
      channel = s;
      showBar('Connected to server');

      channel!.listen(
            (data) {
          var response = utf8.decode(data).trim();
          print('Received: $response');
          showBar('Server response: $response');

          try {
            var jsonResponse = jsonDecode(response);
            if (jsonResponse['status'] == 200) {
              showBar('Login successful: ${jsonResponse['message']}');
              saveCredentials(usernameController.text, passwordController.text);
            } else if (jsonResponse['status'] == 401) {
              showBar('Login failed: ${jsonResponse['message']}');
            } else {
              showBar('Unexpected response');
            }
          } catch (e) {
            showBar('Error parsing response: $e');
          }
        },
        onError: (error) {
          showBar('Socket error: $error');
        },
        onDone: () {
          showBar('Socket connection closed');
          channel?.destroy();
        },
      );
    }).catchError((e) {
      showBar('Failed to connect to socket: $e');
    });
  }

  Future<void> saveCredentials(String username, String password) async {
    try {
      // Define a visible path in the Downloads folder
      final directory = Directory('/storage/emulated/0/Download/xarin_credentials');
      if (!await directory.exists()) {
        await directory.create(recursive: true);
      }

      final file = File('${directory.path}/credentials.json');
      final credentials = {
        'username': username,
        'password': password,
      };

      await file.writeAsString(jsonEncode(credentials));
      print('Credentials saved to ${file.path}');
      showBar('Credentials saved to Downloads folder');
    } catch (e) {
      print('Failed to save credentials: $e');
      showBar('Failed to save credentials');
    }
  }

  /*Future<void> saveCredentials(String username, String password) async {
    try {
      final directory = Directory('${Directory.systemTemp.path}/xarin_credentials');
      if (!await directory.exists()) {
        await directory.create(recursive: true);
      }

      final file = File('${directory.path}/credentials.json');
      final credentials = {
        'username': username,
        'password': password,
      };

      await file.writeAsString(jsonEncode(credentials));
      print('Credentials saved to ${file.path}');
      showBar('Credentials saved locally');
    } catch (e) {
      print('Failed to save credentials: $e');
      showBar('Failed to save credentials');
    }
  }*/

  void login() {
    if (usernameController.text.isEmpty || passwordController.text.isEmpty) {
      showBar('Please enter username and password');
      return;
    }

    var data = {
      'method': 'POST',
      'route': '/user/login/',
      'payload': {
        'username': usernameController.text,
        'password': passwordController.text,
      }
    };

    var jdata = jsonEncode(data) + '\n';

    try {
      print(jdata);
      channel!.write(jdata);
      channel!.flush();
      showBar('Sent username/password to Server');
    } catch (e) {
      showBar('Error: $e');
    }
  }

  @override
  void dispose() {
    channel?.destroy();
    usernameController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: appBar(),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: 50),
              Icon(
                Icons.lock_outline,
                size: 100,
                color: Colors.blue[900],
              ),
              SizedBox(height: 30),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blue[900]!.withOpacity(0.15),
                      blurRadius: 8,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: TextField(
                  controller: usernameController,
                  style: TextStyle(color: Colors.grey[800], fontSize: 16),
                  decoration: InputDecoration(
                    labelText: 'Username',
                    hintText: 'Enter your Username',
                    labelStyle: TextStyle(color: Colors.blue[900], fontSize: 14),
                    hintStyle: TextStyle(color: Colors.grey[500], fontSize: 14),
                    prefixIcon: Icon(Icons.person, color: Colors.blue[900]),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                  ),
                ),
              ),
              SizedBox(height: 20),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blue[900]!.withOpacity(0.15),
                      blurRadius: 8,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: TextField(
                  controller: passwordController,
                  obscureText: true,
                  style: TextStyle(color: Colors.grey[800], fontSize: 16),
                  decoration: InputDecoration(
                    labelText: 'Password',
                    hintText: 'Enter your password',
                    labelStyle: TextStyle(color: Colors.blue[900], fontSize: 14),
                    hintStyle: TextStyle(color: Colors.grey[500], fontSize: 14),
                    prefixIcon: Icon(Icons.lock, color: Colors.blue[900]),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                  ),
                ),
              ),
              SizedBox(height: 20),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => Register()),
                  );
                },
                child: Text(
                  'Register?',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.blue[900],
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: login,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[900],
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  elevation: 3,
                ),
                child: Text(
                  'Login',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
              SizedBox(height: 50),
            ],
          ),
        ),
      ),
    );
  }

  AppBar appBar() {
    return AppBar(
      title: Text(
        'Xarin',
        style: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
      centerTitle: true,
      backgroundColor: Colors.blue[900],
      elevation: 0,
      leading: Icon(Icons.lock_outline, color: Colors.white),
      actions: [
        IconButton(
          icon: Icon(Icons.info_outline, color: Colors.white),
          onPressed: () {
            showBar('Welcome to Xarin!');
          },
        ),
      ],
    );
  }
}
