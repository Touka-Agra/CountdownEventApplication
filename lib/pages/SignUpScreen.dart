import 'package:countdown_event/Customs/BottomNavBar.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

import '../widgets/CustomButton.dart';
import '../widgets/InputField.dart';

class SignUpScreen extends StatelessWidget {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  SignUpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Get Started',
                  style: TextStyle(
                      fontSize: 32, fontWeight: FontWeight.bold, color: Colors.purple),
                ),
                const SizedBox(height: 30),
                InputField(
                  hintText: "Email Address",
                  obscureText: false,
                  controller: emailController,
                ),
                const SizedBox(height: 10),
                InputField(
                  hintText: "Your Name",
                  obscureText: false,
                  controller: nameController,
                ),
                const SizedBox(height: 10),
                InputField(
                  hintText: "Password",
                  obscureText: true,
                  controller: passwordController,
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: CustomButton(
                    text: 'Sign Up',
                    onPressed: () {
                      _signUp(context);
                    },
                  ),
                ),
                const SizedBox(height: 20),
                const Text('Already have an account?'),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('Sign In'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _signUp(BuildContext context) async {
    try {
      String email = emailController.text.trim();
      String password = passwordController.text.trim();

      // Create a new user with email and password
      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      await userCredential.user?.updateProfile(displayName: nameController.text.trim());

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => BottomNavBar()),
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Account created successfully!')),
      );
    } catch (e) {
      print('Sign Up failed: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Sign Up failed: ${e.toString()}')),
      );
    }
  }
}