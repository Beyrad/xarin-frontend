// import 'dart:convert';
//
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:r/register.dart';
// import 'package:web_socket_channel/web_socket_channel.dart';
//
// class Login extends StatefulWidget {
//   @override
//   LoginState createState() => LoginState();
// }
//
// class LoginState  extends State<Login> {
//
//   var usernameController = TextEditingController();
//   var passwordController = TextEditingController();
//   WebSocketChannel? channel;
//   bool isLoading = false;
//
//   @override
//   void initState() {
//     super.initState();
//     channel = WebSocketChannel.connect(Uri.parse('wss://echo.websocket.org'));
//
//
//     channel!.stream.listen(
//           (message) {
//         // Show server response in SnackBar
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Server response: $message')),
//         );
//         print('sent to server');
//       },
//       onError: (error) {
//         // Handle errors (e.g., connection issues)
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('WebSocket error: $error')),
//         );
//       },
//       onDone: () {
//         // Handle connection closure
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('WebSocket connection closed')),
//         );
//       },
//     );
//   }
//
//   void login() {
//
//     var data = {
//       'method': 'POST',
//       'route': '/user/login/',
//       'payload': {
//         'username': usernameController.text,
//         'password': passwordController.text,
//       }
//     };
//
//     var jdata = jsonEncode(data);
//
//     try {
//       channel!.sink.add(jdata);
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Sent username/password to Server'))
//       );
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Error: $e'))
//       );
//     }
//   }
//
//   @override
//   void dispose() {
//     channel?.sink.close();
//     usernameController.dispose();
//     passwordController.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: appBar(),
//       body: SingleChildScrollView(
//         child: Column(
//           children: [
//             SizedBox(height: 125),
//             TextField(
//               controller: usernameController,
//               decoration: InputDecoration(
//                   labelText: 'Username',
//                   hintText: 'Enter your Username',
//                   filled: true,
//                   fillColor: Colors.white,
//                   border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(20),
//                       borderSide: BorderSide.none
//                   )
//               ),
//             ),
//             SizedBox(height: 50),
//             TextField(
//               controller: passwordController,
//               obscureText: true,
//               decoration: InputDecoration(
//                   labelText: 'Password',
//                   hintText: 'Enter your password',
//                   filled: true,
//                   fillColor: Colors.white,
//                   border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(20),
//                       borderSide: BorderSide.none
//                   )
//               ),
//             ),
//             SizedBox(height: 50),
//             GestureDetector(
//               onTap: () {
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(builder: (context) => register()), // Navigate to RegisterPage
//                 );
//               },
//               child: Text(
//                 'Register?',
//                 style: TextStyle(
//                   fontSize: 12,
//                   fontWeight: FontWeight.bold,
//                   color: Colors.blue,
//                   decoration: TextDecoration.underline, // Adds an underline effect
//                 ),
//               ),
//             ),
//             SizedBox(height: 50),
//             OutlinedButton(
//               onPressed: () {
//                 print('OutlinedButton pressed!');
//                 login();
//               },
//               child: Text('Login'),
//             )
//           ],
//         )
//       )
//     );
//   }
// }
//
// AppBar appBar() {
//   return AppBar(
//     title: Text('Xarin'),
//     centerTitle: true,
//   );
// }

// import 'dart:convert';
//
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:r/register.dart';
// import 'package:web_socket_channel/web_socket_channel.dart';
//
// class Login extends StatefulWidget {
//   @override
//   LoginState createState() => LoginState();
// }
//
// class LoginState extends State<Login> {
//   var usernameController = TextEditingController();
//   var passwordController = TextEditingController();
//   WebSocketChannel? channel;
//   bool isLoading = false;
//
//   @override
//   void initState() {
//     super.initState();
//     channel = WebSocketChannel.connect(Uri.parse('wss://echo.websocket.org'));
//
//     channel!.stream.listen(
//           (message) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text('Server response: $message', style: TextStyle(color: Colors.white)),
//             backgroundColor: Colors.grey[800],
//           ),
//         );
//         print('sent to server');
//       },
//       onError: (error) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text('WebSocket error: $error', style: TextStyle(color: Colors.white)),
//             backgroundColor: Colors.grey[800],
//           ),
//         );
//       },
//       onDone: () {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text('WebSocket connection closed', style: TextStyle(color: Colors.white)),
//             backgroundColor: Colors.grey[800],
//           ),
//         );
//       },
//     );
//   }
//
//   void login() {
//     var data = {
//       'method': 'POST',
//       'route': '/user/login/',
//       'payload': {
//         'username': usernameController.text,
//         'password': passwordController.text,
//       }
//     };
//
//     var jdata = jsonEncode(data);
//
//     try {
//       channel!.sink.add(jdata);
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text('Sent username/password to Server', style: TextStyle(color: Colors.white)),
//           backgroundColor: Colors.grey[800],
//         ),
//       );
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text('Error: $e', style: TextStyle(color: Colors.white)),
//           backgroundColor: Colors.grey[800],
//         ),
//       );
//     }
//   }
//
//   @override
//   void dispose() {
//     channel?.sink.close();
//     usernameController.dispose();
//     passwordController.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.grey[900],
//       appBar: appBar(),
//       body: SingleChildScrollView(
//         child: Padding(
//           padding: EdgeInsets.symmetric(horizontal: 32),
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               SizedBox(height: 50),
//               Icon(Icons.lock, size: 100, color: Colors.white), // Placeholder for logo
//               SizedBox(height: 50),
//               Container(
//                 decoration: BoxDecoration(
//                   color: Colors.grey[800],
//                   borderRadius: BorderRadius.circular(20),
//                   boxShadow: [
//                     BoxShadow(
//                       color: Colors.black26,
//                       blurRadius: 10,
//                       offset: Offset(0, 5),
//                     ),
//                   ],
//                 ),
//                 child: TextField(
//                   controller: usernameController,
//                   style: TextStyle(color: Colors.white),
//                   decoration: InputDecoration(
//                     labelText: 'Username',
//                     hintText: 'Enter your Username',
//                     labelStyle: TextStyle(color: Colors.white),
//                     hintStyle: TextStyle(color: Colors.white70),
//                     prefixIcon: Icon(Icons.person, color: Colors.white),
//                     border: InputBorder.none,
//                     contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
//                   ),
//                 ),
//               ),
//               SizedBox(height: 20),
//               Container(
//                 decoration: BoxDecoration(
//                   color: Colors.grey[800],
//                   borderRadius: BorderRadius.circular(20),
//                   boxShadow: [
//                     BoxShadow(
//                       color: Colors.black26,
//                       blurRadius: 10,
//                       offset: Offset(0, 5),
//                     ),
//                   ],
//                 ),
//                 child: TextField(
//                   controller: passwordController,
//                   obscureText: true,
//                   style: TextStyle(color: Colors.white),
//                   decoration: InputDecoration(
//                     labelText: 'Password',
//                     hintText: 'Enter your password',
//                     labelStyle: TextStyle(color: Colors.white),
//                     hintStyle: TextStyle(color: Colors.white70),
//                     prefixIcon: Icon(Icons.lock, color: Colors.white),
//                     border: InputBorder.none,
//                     contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
//                   ),
//                 ),
//               ),
//               SizedBox(height: 20),
//               GestureDetector(
//                 onTap: () {
//                   Navigator.push(
//                     context,
//                     MaterialPageRoute(builder: (context) => register()),
//                   );
//                 },
//                 child: Text(
//                   'Register?',
//                   style: TextStyle(
//                     fontSize: 16,
//                     fontWeight: FontWeight.bold,
//                     color: Colors.white,
//                     decoration: TextDecoration.underline,
//                   ),
//                 ),
//               ),
//               SizedBox(height: 20),
//               ElevatedButton(
//                 onPressed: () {
//                   print('ElevatedButton pressed!');
//                   login();
//                 },
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: Colors.blueAccent,
//                   foregroundColor: Colors.white,
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(20),
//                   ),
//                   padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
//                 ),
//                 child: Text('Login', style: TextStyle(fontSize: 16)),
//               ),
//               SizedBox(height: 50),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   AppBar appBar() {
//     return AppBar(
//       title: Text('Xarin'),
//       centerTitle: true,
//       backgroundColor: Colors.black,
//     );
//   }
// }

import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:r/register.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

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
    Socket.connect('192.168.0.149', 8888).then((s) {
      channel = s;
      showBar('Connected to server');

      channel!.listen(
        (data) {
          var response = utf8.decode(data).trim();
          showBar('Server response: $response');
          print('Received: $response');
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