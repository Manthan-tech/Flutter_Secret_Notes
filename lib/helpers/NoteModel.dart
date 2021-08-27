import 'package:cloud_firestore/cloud_firestore.dart';

class NoteModel{

  String _title;
  String _note;
  List _images;
  String _voice;
  Timestamp _dateTime;
  String _id;
  String _link;
  bool _star;

  String get title => _title;
  String get id => _id;
  String get note => _note;
  String get voice => _voice;
  List get images => _images;
  Timestamp get TimeDate => _dateTime;
  String get link => _link;
  bool get star => _star;

  NoteModel.fromSnapshot(DocumentSnapshot snapshot){
    Map data=snapshot.data();
    _id = data['id'];
    _dateTime = data['timedate']??Timestamp.now();
    _title = data['title'];
    _images = data['images']??[];
    _voice = data['voice']??'';
    _note = data['note'];
    _link = data['link']??'';
    _star = data['star']??false;
  }
}