import 'package:flutter/material.dart';
import 'package:chat/components/rounded_button.dart';
import 'package:animated_text_kit/animated_text_kit.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with SingleTickerProviderStateMixin {
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
                Container(
                  child: Hero(
                    child: Image.asset('images/logo.png'),
                    tag: 'logo',
                  ),
                  height: 60,
                ),
                AnimatedTextKit(
                  animatedTexts: [
                    TypewriterAnimatedText(
                      'Flash Chat',
                      textStyle: TextStyle(
                          fontFamily: 'Nexa',
                          fontSize: 45,
                          fontWeight: FontWeight.bold,
                          color: Colors.black),
                    ),
                  ],
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
