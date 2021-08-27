import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel{
  static const Number ="number";
  static const ID= "id";
  static const Address= "address";
  static const Name= "name";
  static const Image= "image";
  static const Email= "email";
  static const Age = "age";
  static const FAVOURITE = "favourite";
  // static const CART = "cart";
  // static const ORDER = "order";
  // static const ACTIVE = "activeorder";
  // static const WALLET = "wallet";
  // static const PASSBOOK = "passbook";
  static const FAVSHOP = "favshop";
  // static const ADBOOK = "adbook";
  // static const CODE = "code";
//  static const ORDERS = "orders";

  String _number;
  String _id;
  String _address;
  String _name;
  String _image;
  String _email;
  int _age;
  List _favourite = [];
  List _cart;
  List _order;
  List _active;
  int _wallet;
  List _favshop;
  List _adbook;
  // List _passbook;
  String _code;
  int _purchase;
  // List _notification;

//  List _orders;


  String get number => _number;
  String get id => _id;
  String get address => _address;
  String get name => _name;
  String get email => _email;
  String get image => _image;
  int get age => _age;
  List get favourite => _favourite;
  List get cart => _cart;
  List get order => _order;
  List get activeorder => _active;
  // List get passbook => _passbook;
  int get wallet => _wallet;
  List get adbook => _adbook;
  List get favshop => _favshop;
  int get purchase => _purchase;
  String get code => _code;
  // List get notification => _notification;
//  List get orders => _orders;

  UserModel.fromSnapshot(DocumentSnapshot snapshot){
    Map data=snapshot.data();
    _number =data[Number];
    _address= data[Address]?? '';
    _id = data[ID];
    _image = data[Image] ?? '' ;
    _email = data[Email] ?? '';
    _age = data[Age] ?? 99;
    _favourite = data[FAVOURITE] ?? [];
    // _cart = data[CART] ?? [];
    _name = data[Name] ?? '';
    // _order = data[ORDER] ?? [];
    // _active = data[ACTIVE] ?? [];
    // _wallet = data[WALLET] ?? 0;
    _favshop = data[FAVSHOP]??[];
    // _adbook = data[ADBOOK]??[];
    // _code = data[CODE]??'';
    // _passbook =data[PASSBOOK] ?? [];
    _purchase = data['purchase'] ?? 0;
    // _notification = data['notification'] ?? [];
//    _orders = data[ORDERS] ?? [];
  }
}