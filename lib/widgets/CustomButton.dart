import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final Function onPressed;
  final bool isGoogleButton; 
  const CustomButton({super.key, 
    required this.text,
    required this.onPressed,
    this.isGoogleButton = false, 
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () => onPressed(),
      style: ElevatedButton.styleFrom(
        backgroundColor: isGoogleButton ? Colors.white : Colors.purple, 
        padding: const EdgeInsets.symmetric(vertical: 15),
        textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
        side: isGoogleButton ? const BorderSide(color: Colors.grey) : null,  
      ),
      child: isGoogleButton
          ? Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const FaIcon(FontAwesomeIcons.google, color: Colors.red), 
                 const SizedBox(width: 10),
                Text(
                  text,
                  style: const TextStyle(color: Colors.black), 
                ),
              ],
            )
          : Text(
              text,
              style: const TextStyle(color: Colors.white),
            ),
    );
  }
}