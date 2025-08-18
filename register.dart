import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:r/login.dart';

class Register extends StatefulWidget {
  @override
  RegisterState createState() => RegisterState();
}

class RegisterState extends State<Register> {
  var usernameController = TextEditingController();
  var passwordController = TextEditingController();
  var emailController = TextEditingController();
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

  void register() {
    if (usernameController.text.isEmpty ||
        passwordController.text.isEmpty ||
        emailController.text.isEmpty) {
      showBar('Please fill all fields');
      return;
    }

    var data = {
      'method': 'POST',
      'route': '/user/signup/',
      'payload': {
        'username': usernameController.text,
        'password': passwordController.text,
        'email': emailController.text,
      }
    };

    var jdata = jsonEncode(data) + '\n';

    try {
      print(jdata);
      channel!.write(jdata);
      channel!.flush();
      showBar('Sent registration data to Server');
    } catch (e) {
      showBar('Error: $e');
    }
  }

  @override
  void dispose() {
    channel?.destroy();
    usernameController.dispose();
    passwordController.dispose();
    emailController.dispose();
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
                Icons.person_add_alt_1,
                size: 100,
                color: Colors.blue[900],
              ),
              SizedBox(height: 30),

              // Username
              textFieldContainer(
                controller: usernameController,
                label: 'Username',
                hint: 'Enter your username',
                icon: Icons.person,
              ),
              SizedBox(height: 20),

              // Email
              textFieldContainer(
                controller: emailController,
                label: 'Email',
                hint: 'Enter your email',
                icon: Icons.email,
              ),
              SizedBox(height: 20),

              // Password
              textFieldContainer(
                controller: passwordController,
                label: 'Password',
                hint: 'Enter your password',
                icon: Icons.lock,
                obscure: true,
              ),
              SizedBox(height: 30),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => Login()),
                  );
                },
                child: Text(
                  'Login?',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.blue[900],
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
              SizedBox(height: 30),
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
              SizedBox(height: 50),
            ],
          ),
        ),
      ),
    );
  }

  Widget textFieldContainer({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    bool obscure = false,
  }) {
    return Container(
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
        controller: controller,
        obscureText: obscure,
        style: TextStyle(color: Colors.grey[800], fontSize: 16),
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          labelStyle: TextStyle(color: Colors.blue[900], fontSize: 14),
          hintStyle: TextStyle(color: Colors.grey[500], fontSize: 14),
          prefixIcon: Icon(icon, color: Colors.blue[900]),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        ),
      ),
    );
  }

  AppBar appBar() {
    return AppBar(
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
      actions: [
        IconButton(
          icon: Icon(Icons.info_outline, color: Colors.white),
          onPressed: () {
            showBar('Create a new account!');
          },
        ),
      ],
    );
  }
}
