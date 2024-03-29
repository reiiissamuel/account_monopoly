import 'package:flutter/material.dart';

class GameIconButtonBuilder extends StatelessWidget {

  final String imgPath;
  final Function() onPressed;
  final String title;

  const GameIconButtonBuilder({super.key, required this.imgPath, required this.title, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return  Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
      child: GestureDetector(
        onTap: onPressed,
        child: Column(
          children: [
            SizedBox(
              height: 60.0,
              width: 60.0,
              child: Image.asset(imgPath,
                  fit: BoxFit.contain),
            ),
            Text(title, style: const TextStyle(letterSpacing: 2.0, color: Colors.white, fontSize: 15.0))
          ],
        ),
      ),
    );
  }


}
