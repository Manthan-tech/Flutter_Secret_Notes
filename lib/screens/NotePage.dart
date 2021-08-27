import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:secret_notes/auth/user.dart';
import 'package:secret_notes/helpers/NoteModel.dart';
import 'dart:io';
import 'dart:ui';
import 'package:image_cropper/image_cropper.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:secret_notes/helpers/cameraPage.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:share/share.dart';
import 'package:fluttertoast/fluttertoast.dart';

class NotePage extends StatefulWidget {
  final NoteModel note;
  final bool edit;
  final bool newNote;
  const NotePage({this.note, this.edit, this.newNote, Key key}) : super(key: key);

  @override
  _NotePageState createState() => _NotePageState();
}

class _NotePageState extends State<NotePage> {
  Color Darkblue = Color.fromRGBO(10, 23, 71, 1);
  FirebaseFirestore _firestore = FirebaseFirestore.instance;
  TextEditingController title;
  TextEditingController note;
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  List imagesUrl = [];
  List<File> newImages = [];
  bool star;
  bool edit = false;
  bool newNote = false;
  String newId;
  Timestamp timestamp;
  void initState(){
    super.initState();
    if(widget.edit!=null)
      edit=widget.edit;
    if(widget.newNote!=null){
      if(widget.newNote==true){
        star = false;
        edit = true;
        title = TextEditingController();
        note = TextEditingController();
        timestamp = Timestamp.now();
        newNote = true;
        newId = Timestamp.now().toDate().toString();
      }
    }else{
      star = widget.note.star;
      imagesUrl = widget.note.images;
      title = TextEditingController(text: widget.note.title);
      note = TextEditingController(text: widget.note.note);
      timestamp = widget.note.TimeDate;
    }
  }
  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserServices>(context);

    Future<void> update()async{
      if (_formKey.currentState.validate()){
            print('in');
            _firestore.collection('users').doc(user.user.id).collection('notes').doc(widget.note.id).update({
              "images": imagesUrl,
              "title": title.text,
              "note": note.text,
            }).then((value) {
              Navigator.of(context, rootNavigator: true).pop();
              setState(() {
                edit = false;
                newImages = [];
              });
            });
      }
    }

    Future<void> newUpdate()async{
      if (_formKey.currentState.validate()){
        print('in');
        _firestore.collection('users').doc(user.user.id).collection('notes').doc(newId).set({
          "images": imagesUrl,
          "title": title.text,
          "note": note.text,
          "id": newId,
          "voice": '',
          "link": '',
          "timedate": timestamp,
          "star": false,
        }).then((value) {
          Navigator.of(context, rootNavigator: true).pop();
          setState(() {
            edit = false;
            newImages = [];
          });
        });
      }
    }

    Future<void> uploadImages(int i)async{
      final FirebaseStorage storage = FirebaseStorage.instance;
        if(newImages[i]!=null){
          print(i.toString());
          String picture1 =
              "${DateTime.now().toString()}.jpg";
          UploadTask task1 =
          storage.ref().child('notes/${user.user.id}/$picture1').putFile(newImages[i]);
          task1.then((snapshot1) async {
            print('$i done');
            String imageUrl1 = await snapshot1.ref.getDownloadURL();
            imagesUrl.add(imageUrl1);
            if(i<newImages.length-1){
              uploadImages(i+1);
            }
            else{
              if(newNote)
                newUpdate();
              else
                update();
            }
          });
        }else{
          if(i<newImages.length-1){
            uploadImages(i+1);
          }
          else{
            if(newNote)
              newUpdate();
            else
              update();
      }
        }
    }

    return SafeArea(
        child: Scaffold(
          bottomNavigationBar: edit?null:BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
              backgroundColor: Color.fromRGBO(234, 237, 250, 1),
              showSelectedLabels: false,
              showUnselectedLabels: false,
              elevation: 16,
              iconSize: 30,
              items: [
                BottomNavigationBarItem(icon: Icon(Icons.edit_outlined, color: Darkblue,), label: 'Edit'),
                BottomNavigationBarItem(icon: star?Icon(Icons.star, color: Color.fromRGBO(242, 160, 5, 1)):Icon(Icons.star_border, color: Darkblue), label: 'Star'),
                BottomNavigationBarItem(icon: Icon(Icons.share, color: Darkblue), label: 'Share'),
                BottomNavigationBarItem(icon: PopupMenuButton(
                  itemBuilder:(context) => [
                    PopupMenuItem(child: Text("Delete"),value: 1,),
                    // PopupMenuItem(child: Text("Second"),value: 2,)
                  ],
                  child: Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: Icon(Icons.more_vert_rounded, color: Darkblue)
                  ),
                  onSelected: (i){
                    _firestore.collection('users').doc(user.user.id).collection('notes').doc(widget.note.id).delete();
                    Navigator.pop(context);
                  },
                ), label: 'More'),
              ],
          onTap: (i){
                switch(i){
                  case 0:
                    setState(() {
                      edit= !edit;
                    });
                    return;
                  case 1:
                    if(star){
                      _firestore.collection('users').doc(user.user.id).collection('notes').doc(widget.note.id).update(
                          {"star": false});
                      setState(() {
                        star = false;
                      });
                    }
                    else{
                      _firestore.collection('users').doc(user.user.id).collection('notes').doc(widget.note.id).update(
                          {"star": true});
                      setState(() {
                        star = true;
                      });
                    }
                    return;
                  case 2:
                    Share.share('https://unipick.page.link/unipick');
                    return;
                  case 3:
                    return;
                }
          },),
          body: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 15),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    InkWell(
                      onTap: (){Navigator.pop(context);},
                      child: Container(
                        height: 50,
                        width: 50,
                        decoration: BoxDecoration(
                            color: Color.fromRGBO(243, 244, 253, 1),
                            borderRadius: BorderRadius.all(Radius.circular(12))
                        ),
                        child: Padding(
                          padding: const EdgeInsets.only(left: 6, top: 3, bottom: 3),
                          child: Icon(Icons.arrow_back_ios, color: Darkblue,),
                        ),
                      ),
                    ),
                    edit?
                    InkWell(
                      onTap: () {
                        if (_formKey.currentState.validate()) {
                          if(newNote){
                            if (newImages.length == 0) {
                              _showMyDialog();
                              newUpdate();
                            }
                            else {
                              _showMyDialog();
                              uploadImages(0);
                            }
                          }else{
                            if (newImages.length == 0) {
                              _showMyDialog();
                              update();
                            }
                            else {
                              _showMyDialog();
                              uploadImages(0);
                            }
                          }
                        }
                      },
                      child: Container(
                        height: 50,
                        width: 50,
                        decoration: BoxDecoration(
                            color: Color.fromRGBO(243, 244, 253, 1),
                            borderRadius: BorderRadius.all(Radius.circular(12))
                        ),
                        child: Padding(
                          padding: const EdgeInsets.only(left: 6, top: 3, bottom: 3),
                          child: Icon(Icons.cloud_done_sharp, color: Darkblue,),
                        ),
                      ),
                    ):Container(),
                  ],
                ),
              ),
              Form(
                key: _formKey,
                child: Expanded(
                  child: Container(
                    padding: EdgeInsets.only(top: 50, left: 15, right: 15, bottom: 0),
                    decoration: BoxDecoration(
                        color: Color.fromRGBO(243, 244, 253, 1),
                        borderRadius: BorderRadius.all(Radius.circular(12))
                    ),
                    child: ListView(
                      children: [
                        edit?
                        TextFormField(controller: title,
                        decoration: InputDecoration(
                          labelText: 'Title',
                          border: InputBorder.none,
                        ),
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Darkblue),
                          maxLines: null,
                          keyboardType: TextInputType.multiline,
                          validator: (value) {
                            if (value.isEmpty) {
                              return 'Title must not be EMPTY';
                            }
                            else if(value == ''){
                              return 'Please give a title';
                            }
                            else{
                              return null;
                            }
                          },
                        ):
                        Text(title.text, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Darkblue),),
                        Divider(color: Color.fromRGBO(220, 220, 230, 1),),
                        edit?
                        TextFormField(controller: note,
                          decoration: InputDecoration(
                            labelText: 'Note',
                            border: InputBorder.none,
                          ),
                          style: TextStyle(fontSize: 16, color: Darkblue),
                          maxLines: null,
                          keyboardType: TextInputType.multiline,
                          validator: (value) {
                            if (value.isEmpty) {
                              return 'Your note must not be EMPTY';
                            }
                            else if(value == ''){
                              return 'Please give your note';
                            }
                            else{
                              return null;
                            }
                          },
                        ):
                        Text(note.text, style: TextStyle(fontSize: 16, color: Darkblue),),
                        Padding(
                          padding: const EdgeInsets.only(top: 20),
                          child: GridView.builder(
                              shrinkWrap: true,
                              itemCount: imagesUrl.length+newImages.length,
                              physics: NeverScrollableScrollPhysics(),
                              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, mainAxisSpacing: 4, crossAxisSpacing: 4),
                              itemBuilder: (context, index){
                                if(index<imagesUrl.length)
                                  return Stack(
                                    children: [
                                      Image.network(imagesUrl[index], fit: BoxFit.contain,),
                                      edit?Positioned(
                                          top: -1,
                                          right: -1,
                                          child:  RawMaterialButton(
                                            onPressed: () {
                                              setState(() {
                                                imagesUrl.removeAt(index);
                                              });
                                            },
                                            constraints:
                                            const BoxConstraints(minWidth:12, minHeight: 15),
                                            child: Icon(Icons.highlight_remove,
                                                color: Colors.black),
                                            shape: CircleBorder(),
                                            fillColor: Color.fromRGBO(255, 255, 255, 0.4),
                                          )):Container(),
                                    ],
                                  );
                                else{
                                  return Stack(
                                    children: [
                                      Image.file(newImages[index-imagesUrl.length], fit: BoxFit.contain,),
                                      edit?Positioned(
                                          top: 2,
                                          right: 2,
                                          child:  RawMaterialButton(
                                            onPressed: () {
                                              setState(() {
                                                newImages.removeAt(index-imagesUrl.length);
                                              });
                                            },
                                            constraints:
                                            const BoxConstraints(minWidth:12, minHeight: 15),
                                            child: Icon(Icons.highlight_remove,
                                                color: Colors.black),
                                            shape: CircleBorder(),
                                            fillColor: Color.fromRGBO(255, 255, 255, 0.4),
                                          )):Container(),
                                    ],
                                  );
                                }
                              }),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 20, bottom: 20),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('${timestamp.toDate().month}, ${timestamp.toDate().day}, ${timestamp.toDate().year}, ${timestamp.toDate().hour}:${timestamp.toDate().minute}', style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic, color: Color.fromRGBO(130, 130, 130, 1),),),
                              Row(
                                children: [
                                  InkWell(
                                      onTap:(){
                                        if(edit){
                                          _selectImage(getImage());
                                      }else{
                                          Fluttertoast.showToast(msg: 'Click edit to add photo.' ,
                                              backgroundColor: Color.fromRGBO(243, 244, 253, 1),
                                              textColor: Darkblue);
                                        }
                                     },
                                      child: Icon(Icons.photo_outlined, color: edit?Darkblue:Color.fromRGBO(130, 130, 130, 1), size: 30,)),
                                  InkWell(
                                    onTap: (){Fluttertoast.showToast(msg: 'This feature is not available' ,
                                        backgroundColor: Color.fromRGBO(243, 244, 253, 1),
                                        textColor: Darkblue);},
                                    child: Padding(
                                      padding: const EdgeInsets.only(left: 30),
                                      child: Icon(Icons.mic_rounded, color: Color.fromRGBO(130, 130, 130, 1), size: 30,),
                                    ),
                                  )
                                ],
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ));
  }

  Future<void> _showMyDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Updating your note'),
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

  Future<File> getImage() async {
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
  void _selectImage(Future<File> pickImage) async {
    File tempImg = await pickImage;
    if(tempImg!=null) {
      setState(() {
        newImages.add(tempImg);
      });
      _cropImage();
    }
  }
  Future<Null> _cropImage() async {
    File croppedFile = await ImageCropper.cropImage(
        sourcePath: newImages.last.path,
        compressQuality: 75,
        aspectRatioPresets: [
        ],
        androidUiSettings: AndroidUiSettings(
          toolbarTitle: 'Cropper',
          toolbarColor: Darkblue,
          toolbarWidgetColor: Colors.white,
          lockAspectRatio: false,
        ));
    if(croppedFile != null) {
      setState(() => newImages.last = croppedFile);
    }
  }
}
