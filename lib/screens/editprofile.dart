import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:secret_notes/auth/user_model.dart';
import 'package:secret_notes/helpers/cameraPage.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:secret_notes/auth/user.dart';
import 'dart:typed_data';
import 'package:image_cropper/image_cropper.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:secret_notes/screens/HomePage.dart';
import 'package:permission_handler/permission_handler.dart';

class EditProfile extends StatefulWidget {
  UserModel user;
  EditProfile(this.user);
  @override
  _EditProfileState createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  String id;
  String number;
  TextEditingController _emailTextController = TextEditingController();
  UserServices _userService = UserServices();
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController NameController = TextEditingController();

  File _image1;
  void initState(){
    super.initState();
    _emailTextController = TextEditingController(text: widget.user.email);
    NameController = TextEditingController(text: widget.user.name);
  }
  Future<void> _showMyDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Updating your profile'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                CircularProgressIndicator(),
                Text('Please wait a few seconds.'),
              ],
            ),
          ),
        );
      },
    );
  }


  Color white = Colors.white;
  Color black = Colors.black;
  Color grey = Colors.grey;
  Color red = Colors.red;
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {


    return Scaffold(
      appBar: AppBar(
        elevation: 0.1,
        backgroundColor: Color.fromRGBO(243, 244, 253, 1),
        title: Text(
          "Profile",
          style: TextStyle(color: Color.fromRGBO(10, 23, 71, 1),),
        ),
        actions: [
          IconButton(
            onPressed: (){
              validateAndUpload();
            },
            icon: Icon(Icons.done, color: Color.fromRGBO(10, 23, 71, 1),),
          )
        ],
      ),
      body: ListView(
        shrinkWrap: true,
        children: [
          Form(
            key: _formKey,
            child:Column(
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: InkWell(
                          onTap:(){
                            _selectImage(getImage1(), 1);
                          },
                          child: Center(
                            child: Stack(
                              children: [
                                _displayChild1(),
                                Positioned(
                                  bottom: 15,
                                    right: 12,
                                    child: Icon(Icons.camera_enhance_rounded, size: 35, color: Colors.blue))
                              ],
                            ),
                          ),
                        )
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: TextFormField(
                    controller: NameController,
                    decoration: InputDecoration(
                      labelText: 'Full Name*',
                        ),
                    validator: (value) {
                      if (value.isEmpty) {
                        return 'Your name must not be EMPTY';
                      }
                      else if(value == ''){
                        return 'Please give your name';
                      }
                      else{
                        return null;
                      }
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: TextFormField(
                    controller: _emailTextController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      labelText: 'E-Mail',
                      hintText: 'abcd@gmail.com',
                    ),
                   validator: (value) {
                     /*r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$'*/
                     Pattern pattern = r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+";
                     RegExp regex = new RegExp(pattern);
                     if (value.isEmpty) {
                       return "Please Give your Email Address";
                     }
                       else if(!regex.hasMatch(value)){
                         return 'Please make sure your email address is valid';
                     }
                       else{
                         return null;
                     }
                   },
                  ),
                ),
                InkWell(
                  onTap: () {
                    validateAndUpload();
                  },
                  child: Container(
                    width: MediaQuery.of(context).size.width / 2.2,
                    height: 60,
                    child: Center(
                        child: new Text("Continue",
                            style: const TextStyle(
                                color: const Color(0xfffefefe),
                                fontWeight: FontWeight.w600,
                                fontStyle: FontStyle.normal,
                                fontSize: 20.0))),
                    decoration: BoxDecoration(
                        color: Color.fromRGBO(10, 23, 71, 1),
                        boxShadow: [
                          BoxShadow(
                            color: Color.fromRGBO(255, 255, 255, 0.4),
                            offset: Offset(2, 2),
                            blurRadius: 10.0,
                          )
                        ],
                        borderRadius: BorderRadius.circular(9.0)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _displayChild1() {
    if (_image1 == null) {
    return  CircleAvatar(
      maxRadius: 100,
      backgroundImage: NetworkImage(widget.user.image),
    );
    } else {
      return CircleAvatar(
        maxRadius: 100,
        backgroundImage: FileImage(_image1),
      );
    }
  }


  void validateAndUpload() async {
    if (_formKey.currentState.validate()) {
      _showMyDialog();
      setState(() => isLoading = true, );
      String imageUrl1;
      if (_image1 != null) {
        final FirebaseStorage storage = FirebaseStorage.instance;
        final String picture1 =
            "${NameController.text
            .toString() + _emailTextController.text}.jpg";
        UploadTask task1 =
        storage.ref().child('userdp/$picture1').putData(await testCompressAsset(_image1));
        // await task1.then((snapshot) => snapshot);
        task1.then((snapshot1) async {
          imageUrl1 = await snapshot1.ref.getDownloadURL();
          _userService.updateUser({
            "name": NameController.text,
            "image": imageUrl1!= null ? imageUrl1 : "",
            "email": _emailTextController.text,
          });
        });
      }
      else{
        _userService.updateUser({
          "name": NameController.text,
          "image": widget.user.image,
          "email": _emailTextController.text,
        });
      }
      _formKey.currentState.reset();
      setState(() => isLoading = false);
        Fluttertoast.showToast(msg: 'Let\'s NOTE' ,
            backgroundColor: Colors.grey,
            textColor: Colors.black);
        Navigator.pushAndRemoveUntil(
            context, MaterialPageRoute(builder: (context) => HomePage()), (
            _) => false);
    }
  }

  Future<Null> _cropImage(int n,File image) async {
    File croppedFile = await ImageCropper.cropImage(
        sourcePath:image.path,
        cropStyle: CropStyle.circle,
        androidUiSettings: AndroidUiSettings(
          toolbarTitle: 'Cropper',
          toolbarColor: Colors.deepOrange,
          toolbarWidgetColor: Colors.white,
          showCropGrid: false,
          lockAspectRatio: false,
        ),
        iosUiSettings: IOSUiSettings(
          title: 'Cropper',
        ));
    if (croppedFile != null) {
      switch (n) {
        case 1:
          setState(() => _image1 = croppedFile);
          break;
      }
    }
  }
  void _selectImage(Future<File> pickImage, int imageNumber) async {
    File tempImg = await pickImage;
    _cropImage(1, tempImg);
    }
  Future<File> getImage1() async {
    File imagetemp;
    await [
      Permission.camera,
      Permission.storage,
    ].request().then((value) async{
      if(value[Permission.camera].isGranted && value[Permission.storage].isGranted){
        await Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    CameraPage((path){imagetemp= File(path);})));
      }
    });
    return imagetemp;
  }
  Future<Uint8List> testCompressAsset(File file) async {
    var list = await FlutterImageCompress.compressWithFile(
      file.absolute.path,
      quality: 75,
      format: CompressFormat.webp,
    );
    return list;
  }
}


