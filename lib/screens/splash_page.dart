import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Widget build(BuildContext context) {
    return Container(
      color: Color.fromRGBO(10, 23, 71, 1),
      padding: EdgeInsets.only(top: MediaQuery.of(context).size.height*0.2),
      child: Align(
        alignment: Alignment.topCenter,
        child: Column(
          children: [
            Text('Welcome to', style: TextStyle(fontStyle: FontStyle.italic, color: Color.fromRGBO(243, 244, 253, 1),),),
            Text('Secret Notes', style: TextStyle(fontWeight: FontWeight.bold, color: Color.fromRGBO(243, 244, 253, 1),),),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: CircularProgressIndicator(),
            ),
          ],
        )
      ),
    );
  }
}
