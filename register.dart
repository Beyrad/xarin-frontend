import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class Register extends StatefulWidget {
  @override
  RegisterState createState() => RegisterState();
}

class RegisterState extends State<Register> {
  var usernameController = TextEditingController();
  var emailController = TextEditingController();
  var passwordController = TextEditingController();
  WebSocketChannel? channel;

  @override
  void initState() {
    super.initState();
    try {
      channel = WebSocketChannel.connect(Uri.parse('wss://echo.websocket.org'));
      channel!.stream.listen(
            (message) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Server response: $message'),
              backgroundColor: Colors.blue[900],
              duration: Duration(seconds: 2),
            ),
          );
          print('Received: $message');
        },
        onError: (error) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('WebSocket error: $error'),
              backgroundColor: Colors.blue[900],
              duration: Duration(seconds: 2),
            ),
          );
        },
        onDone: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('WebSocket connection closed'),
              backgroundColor: Colors.blue[900],
              duration: Duration(seconds: 2),
            ),
          );
        },
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to connect to WebSocket: $e'),
          backgroundColor: Colors.blue[900],
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  void register() {
    if (usernameController.text.isEmpty ||
        emailController.text.isEmpty ||
        passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please enter all fields'),
          backgroundColor: Colors.blue[900],
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    var data = {
      'method': 'POST',
      'route': '/user/register/',
      'payload': {
        'username': usernameController.text,
        'email': emailController.text,
        'password': passwordController.text,
      }
    };

    var jdata = jsonEncode(data);

    try {
      channel!.sink.add(jdata);
      /*ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Sent registration data to Server'),
          backgroundColor: Colors.blue[900],
          duration: Duration(seconds: 2),
        ),
      );*/
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.blue[900],
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  void dispose() {
    channel!.sink.close();
    usernameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Register',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.blue[900],
        elevation: 0,
        leading: Icon(Icons.person_add, color: Colors.white),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: 50),
              Icon(
                Icons.person_add,
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
                  controller: emailController,
                  style: TextStyle(color: Colors.grey[800], fontSize: 16),
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    hintText: 'Enter your Email',
                    labelStyle: TextStyle(color: Colors.blue[900], fontSize: 14),
                    hintStyle: TextStyle(color: Colors.grey[500], fontSize: 14),
                    prefixIcon: Icon(Icons.email, color: Colors.blue[900]),
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
              ElevatedButton(
                onPressed: register,
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
                  'Register',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
              SizedBox(height: 20),
              GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                },
                child: Text(
                  'Already have an account? Login',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.blue[900],
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
              SizedBox(height: 50),
            ],
          ),
        ),
      ),
    );
  }
}