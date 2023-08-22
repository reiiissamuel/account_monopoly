import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'home_screen.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}


class _SplashScreenState extends State<SplashScreen> {

  @override
  void initState() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: SystemUiOverlay.values);
    Future.delayed(const Duration(seconds: 4)).then((_){
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>HomeScreen()));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        color: Colors.black,
        child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              Expanded(
                flex: 1,
                child: SizedBox(
                  height: 70.0,
                  width: 70.0,
                  child: Image.asset("icons/apptheme.png",
                      fit: BoxFit.contain),
                ),
              ),
              Expanded(
                flex: 1,
                child: SizedBox(
                  height: 100.0,
                  width: 100.0,
                  child: Image.asset("icons/mysign.png", fit: BoxFit.contain),
                ),
              )
            ]
        )
    );
  }
}
