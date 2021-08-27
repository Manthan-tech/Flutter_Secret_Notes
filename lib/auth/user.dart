import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:secret_notes/auth/user_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import'package:shared_preferences/shared_preferences.dart';


class UserServices with ChangeNotifier{
  String collection = "users";
  FirebaseFirestore _firestore = FirebaseFirestore.instance;
  FirebaseAuth _auth = FirebaseAuth.instance;
  UserModel userr;
  String UID;
  String phone;
  bool loading = false;
  UserModel get user => userr;
  UserServices(){
    getUser();
    getUser1();
  }
  Stream userstream;
  String lipsum = 'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.';
  void createUser(Map<String, dynamic> values){
    String id = values["id"];
    _firestore.collection(collection).doc(id).set(values).then((value) {
      Timestamp now1 = Timestamp.now();
      _firestore.collection('users').doc(id).collection('notes').doc(now1.toDate().toString()).set(
          {
            "images": [],
            "title": 'Welcome Note',
            "note": lipsum,
            "id": now1.toDate().toString(),
            "voice": '',
            "link": '',
            "timedate": now1,
            "star": false,
          }).then((value) {
        Timestamp now2 = Timestamp.now();
        _firestore.collection('users').doc(id).collection('notes').doc(now2.toDate().toString()).set(
            {
              "images": [],
              "title": 'User Manual',
              "note": lipsum,
              "id": now2.toDate().toString(),
              "voice": '',
              "link": '',
              "timedate": now2,
              "star": false,
            });
      });
    });
    notifyListeners();
  }

  void updateUser(Map<String, dynamic> values) async{
    loading = true;
    notifyListeners();
    final User currentUser =_auth.currentUser;
    UID = currentUser.uid;
    _firestore.collection(collection).doc(UID).update(values);
    loading = false;
    notifyListeners();
  }

  Future<void> getUser1() async {
    final User currentUser =_auth.currentUser;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if(prefs.getBool("loggedIn")??false){
      UID = currentUser.uid;
      userstream= _firestore.collection('users').doc(_auth.currentUser.uid).snapshots();
      userstream.listen((event) {
        userr = UserModel.fromSnapshot(event);
        notifyListeners();
      });
    }
  }
  Future<void> getUser() async {
    final User currentUser =_auth.currentUser;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if(prefs.getBool("loggedIn")??false){
      UID = currentUser.uid;
      userr = await getUserById(UID);
      notifyListeners();
    }
  }



  Future<UserModel> getUserById(String id) async => _firestore.collection(collection).doc(id).get().then((doc){
    if (!doc.exists){
      return null;
    }else{
      return UserModel.fromSnapshot(doc);
    }
  });
}

