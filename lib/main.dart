import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:secret_notes/auth/auth_provider.dart';
import 'package:secret_notes/auth/user.dart';
import 'package:secret_notes/screens/splash_page.dart';
import 'package:secret_notes/screens/phone_number.dart';
import 'package:secret_notes/screens/HomePage.dart';
import 'package:flutter/services.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MultiProvider(providers: [
    ChangeNotifierProvider.value(value: AuthProviderl.initialize()),
    ChangeNotifierProvider.value(value: UserServices()),
  ],
    child: MyApp(),));
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Secret Notes',
      home: ScreensController(),
    );
  }
}

class ScreensController extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
        statusBarColor: Color.fromRGBO(243, 244, 253, 1),
        systemNavigationBarColor: Color.fromRGBO(243, 244, 253, 1)));
    final auth = Provider.of<AuthProviderl>(context);
    print(auth.status);
    switch(auth.status){
      case Status.Uninitialized:
        return SplashScreen();
      case Status.Unauthenticated:
        return PhoneNumberPage();
      case Status.Authenticating:
        return PhoneNumberPage();
      case Status.Authenticated:
        return HomePage();
      default: return PhoneNumberPage();
    }
  }
}