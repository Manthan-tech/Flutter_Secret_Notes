import 'dart:async';
import 'package:secret_notes/helpers/screen_navigation.dart';
import 'package:secret_notes/auth/user.dart';
import 'package:secret_notes/auth/user_model.dart';
import 'package:secret_notes/screens/phone_number.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';
import'package:shared_preferences/shared_preferences.dart';
import 'package:secret_notes/screens/confirm_otp_page.dart';
import 'package:path_provider/path_provider.dart';
import 'package:secret_notes/screens/editprofile.dart';

enum Status{Uninitialized, Authenticated, Authenticating, Unauthenticated}



class AuthProviderl with ChangeNotifier {
  static const LOGGED_IN = "loggedIn";
  FirebaseAuth _auth = FirebaseAuth.instance;
  User _user;
  Status _status = Status.Uninitialized;


  UserServices _userServicse = UserServices();
  UserModel _userModel;
  String smsOTP;
  String verificationId;
  String errorMessage = '';
  bool loggedIn;
  bool loading = false;
  bool copopen = false;

  UserModel get userModel => _userModel;
  Status get status => _status;
  // Function get getauser => _getusera;
  User get user => _user;

  AuthProviderl.initialize() {
    readPrefs();
  }
  // void _getusera() async{
  //   _userModel = await _userServicse.getUserById(_userServicse.user.id);
  // }
  Future<void> _deleteCacheDir() async {
    final cacheDir = await getTemporaryDirectory();
    if (cacheDir.existsSync()) {
      cacheDir.deleteSync(recursive: true);
    }
  }

  Future<void> _deleteAppDir() async {
    final appDir = await getApplicationSupportDirectory();
    if(appDir.existsSync()){
      appDir.deleteSync(recursive: true);
    }
  }

  Future<void> readPrefs()async{
    await Future.delayed(Duration(seconds: 0)).then((v)async {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      loggedIn = prefs.getBool(LOGGED_IN) ?? false;
      if(loggedIn){
        if(_auth.currentUser==null){
          signOut();
          return;
        }else {
          _user = _auth.currentUser;
          _userModel = await _userServicse.getUserById(_user.uid);
          _status = Status.Authenticated;
          notifyListeners();
          return;
        }
      }
      _status = Status.Unauthenticated;
      notifyListeners();

    });
  }

  Future<void> verifyPhoneNumber(BuildContext context, String number) async {
    loading = true;
    notifyListeners();
    final PhoneCodeSent smsOTPSent = (String verId, [int forceCodeResend]) {
      this.verificationId = verId;
     // build(context);
      loading = false;
      notifyListeners();
      changeScreen(context, ConfirmOtpPage(number));
      copopen = true;
    };
    try {
      await _auth.verifyPhoneNumber(
          phoneNumber:'+91'+number.trim(), // PHONE NUMBER TO SEND OTP
          codeAutoRetrievalTimeout: (String verId) {
            if(!copopen){
              this.verificationId = verId;
              loading = false;
              notifyListeners();
              changeScreen(context, ConfirmOtpPage(number));
            }
          },

          codeSent:
          smsOTPSent, // WHEN CODE SENT THEN WE OPEN DIALOG TO ENTER OTP.
          timeout: const Duration(seconds: 60),
          verificationCompleted: (AuthCredential phoneAuthCredential) {
            print(phoneAuthCredential.toString() + "lets make this work");
            // if (_auth.currentUser != null&& _userModel !=null) {
            //   debugPrint('old');
            //   onldsignIn(context);
            // } else {
              signIn(context, cred: phoneAuthCredential, auto: true);
            // }
          },
          verificationFailed: (FirebaseAuthException exceptio) {
            handleError(exceptio, context);
          });
    } catch (e) {
      loading = false;
      handleError(e, context);
      notifyListeners();
    }
  }


  handleError(error, BuildContext context) {
    print(error);
    switch (error.code) {
      case 'ERROR_INVALID_VERIFICATION_CODE':
        print("The verification code is invalid");
        Fluttertoast.showToast(msg: 'Invalid OTP', backgroundColor: Colors.grey, textColor: Colors.black);
        break;
      case 'invalid-verification-code':
        Fluttertoast.showToast(msg: 'Invalid OTP', backgroundColor: Colors.grey, textColor: Colors.black);
        break;
      case 'invalid-phone-number':
        Fluttertoast.showToast(msg: 'Invalid Phone Number', backgroundColor: Colors.grey, textColor: Colors.black);
        break;
      case 'network-request-failed':
        Fluttertoast.showToast(msg: 'No Internet Connection', backgroundColor: Colors.grey, textColor: Colors.black);
        break;
      default:
        print(error.code);
        Fluttertoast.showToast(msg: error.code, backgroundColor: Colors.grey, textColor: Colors.black);
        break;
    }
  }

  void _createUser({String id, String number}){
    _userServicse.createUser({
      "id": id,
      "number": number,
      "name": '',
      "age": 0,
      "address": '',
      "image": "",
      "email": '',
      "favourite": [],
    });
  }


  signIn(BuildContext context, {PhoneAuthCredential cred, bool auto}) async {
    try {
      UserCredential user;
      if(auto!=true){
        final AuthCredential credential = PhoneAuthProvider.credential(
          verificationId: verificationId,
          smsCode: smsOTP,
        );
        user = await _auth.signInWithCredential(credential);}
      else{
        user = await _auth.signInWithCredential(cred);
      }
      final User currentUser = _auth.currentUser;
      assert(user.user.uid == currentUser.uid);
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setBool(LOGGED_IN, true);
      loggedIn =  true;
      if (user != null) {
        _userModel = await _userServicse.getUserById(user.user.uid);
        if(_userModel == null) {
          _createUser(id: user.user.uid, number: user.user.phoneNumber);
        }
      }
      await _userServicse.getUser();
      loading = false;
      Fluttertoast.showToast(msg: 'Please wait verifying...', backgroundColor: Colors.grey, textColor: Colors.black);
      _status = Status.Authenticated;
      _userServicse.getUser1();
      Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context)=>EditProfile(_userServicse.user)), (_) => false);
      notifyListeners();
    } catch (e) {
      handleError(e, context);
      // Fluttertoast.showToast(msg: 'Error, Please check Yor Internet', backgroundColor: Colors.grey, textColor: Colors.black);
      loading = false;
      print("${e.toString()}");
    }
  }
  // onldsignIn(BuildContext context/*, User olduser*/, {PhoneAuthCredential cred, bool auto}) async {
  //   try {
  //     // final AuthCredential credential = PhoneAuthProvider.credential(
  //     //   verificationId: verificationId,
  //     //   smsCode: smsOTP,
  //     // );
  //     _userModel = await _guestService.getGuestById(_auth.currentUser.uid);
  //     notifyListeners();
  //     UserCredential user;
  //     await _auth.currentUser.delete();
  //     // final UserCredential user = await _auth.signInWithCredential(credential);
  //     if(auto!=true){
  //       final AuthCredential credential = PhoneAuthProvider.credential(
  //         verificationId: verificationId,
  //         smsCode: smsOTP,
  //       );
  //       user = await _auth.signInWithCredential(credential);}
  //     else{
  //       user = await _auth.signInWithCredential(cred);
  //     }
  //     final User currentUser = _auth.currentUser;
  //     assert(user.user.uid == currentUser.uid);
  //     print(user.user.uid);
  //     SharedPreferences prefs = await SharedPreferences.getInstance();
  //     prefs.setBool(LOGGED_IN, true);
  //     prefs.setBool('Anonymous', false);
  //     loggedIn =  true;
  //     if (user != null) {
  //       UserModel newuser;
  //       newuser = await _userServicse.getUserById(user.user.uid);
  //       if(newuser==null){
  //         print('new');
  //         analytics.logSignUp(signUpMethod: 'AnonymoustoPhone');
  //         _createnewUser(id: user.user.uid, number: user.user.phoneNumber, fav: _userModel.favourite,cart: _userModel.cart, favshop: _userModel.favshop);
  //       }else{
  //         List fav = newuser.favourite?? [];
  //         List favshop = newuser.favshop ?? [];
  //         _userModel.favourite.forEach((element) {
  //           if(!fav.contains(element)){
  //           fav.add(element);
  //         }});
  //         _userModel.favshop.forEach((element) {
  //           if(!favshop.contains(element)){
  //           favshop.add(element);
  //         }
  //         });
  //         (_userModel.cart)==[]?
  //         _userServicse.updateUser2({
  //           "favourite": fav,
  //           "favshop" : favshop,
  //         }, _auth.currentUser.uid):_userServicse.updateUser2({
  //           "cart":_userModel.cart,
  //           "favourite": fav,
  //           "favshop" : favshop,
  //         }, _auth.currentUser.uid);
  //       }
  //       _user = _auth.currentUser;
  //       notifyListeners();
  //       analytics.logLogin(loginMethod: 'AnonymoustoPhone');
  //       _guestService.deleteguest(_userModel.id);
  //       _userModel = await _userServicse.getUserById(user.user.uid);
  //       await _userServicse.getUser();
  //       _userServicse.getUser1();
  //       _userServicse.checkupdateuser(user.user.uid);
  //       loading = false;
  //       Fluttertoast.showToast(msg: 'Please wait verifying...', backgroundColor: Colors.grey, textColor: Colors.black);
  //       _status = Status.Authenticated;
  //       Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context)=>EditProfile(_userServicse.user)), (_) => false);
  //       notifyListeners();
  //     }
  //   } catch (e) {
  //     loading = false;
  //     handleError(e, context);
  //     // Fluttertoast.showToast(msg: 'Error, Please check Yor Internet', backgroundColor: Colors.grey, textColor: Colors.black);
  //     print("${e.toString()}");
  //   }
  // }

  Future<void> getotp(BuildContext context, String otp) async{
    smsOTP = otp;
    loading = true;
    notifyListeners();
    signIn(context);
                    // if (_auth.currentUser != null&& _userModel !=null) {
                    //   debugPrint('old');
                    //   // User olduser = _auth.currentUser;
                    //   onldsignIn(context/*, olduser*/);
                    // } else {
                    //   signIn(context);
                    // }
                 }

  Future signOut({BuildContext context})async{
    _auth.signOut();
    _status = Status.Unauthenticated;
    notifyListeners();
  _deleteAppDir();
  _deleteCacheDir();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.clear();
    if(context!=null)
    Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context)=>PhoneNumberPage()), (_) => false);
    notifyListeners();
    return Future.delayed(Duration.zero);
  }
}