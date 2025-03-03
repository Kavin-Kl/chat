import 'package:flutter/material.dart';
import 'package:chat/components/rounded_button.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Container(child: Image.asset('images/logo.png'), height: 60),
                Text(
                  'Flash Chat',
                  style: TextStyle(fontSize: 45, fontWeight: FontWeight.w900),
                ),
              ],
            ),
            SizedBox(
              height: 48.0,
            ),
            RoundedButton(
              text: 'Log In',
              onPressed: () {
                Navigator.pushNamed(context, '/login');
              },
            ),
            SizedBox(
              height: 25.0,
            ),
            RoundedButton(
              text: 'Register',
              onPressed: () {
                Navigator.pushNamed(context, '/registration');
              },
            ),
          ],
        ),
      ),
    );
  }
}
