import 'package:flutter/material.dart';

class GameIconButtonBuilder extends StatelessWidget {

  final String imgPath;
  final Function() onPressed;
  final String? title;
  final double? height;
  final double? width;
  final double? textFontSize;
  final bool disableClick;

  const GameIconButtonBuilder({super.key, required this.imgPath, this.title, required this.onPressed, this.height, this.width, this.textFontSize, this.disableClick = false});

  @override
  Widget build(BuildContext context) {
    return AbsorbPointer(
      // Se a condição for falsa, o AbsorbPointer impede qualquer clique/toque no botão
      absorbing: disableClick,
      child: Opacity(
        // Se estiver indisponível, fica com 40% de opacidade (opaco). Se disponível, 100% (1.0)
        opacity: disableClick ? 0.4 : 1.0,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
          child: GestureDetector(
            onTap: onPressed,
            child: Column(
              children: [
                SizedBox(
                  height: height ?? 60.0,
                  width: width ?? 60.0,
                  child: Image.asset(imgPath,
                      fit: BoxFit.contain),
                ),
                title != null ? Text(title!, style: TextStyle(letterSpacing: 1.0, color: Colors.white, fontSize: textFontSize ?? 15.0)) : const SizedBox(height: 0),
              ],
            ),
          ),
        )
      ),
    );
  }


}
