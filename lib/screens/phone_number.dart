import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:secret_notes/auth/auth_provider.dart';
import 'package:provider/provider.dart';
import 'package:fluttertoast/fluttertoast.dart';

class PhoneNumberPage extends StatefulWidget {
  bool skip;
  PhoneNumberPage({this.skip});
  @override
  _PhoneNumberPageState createState() => _PhoneNumberPageState();
}

class _PhoneNumberPageState extends State<PhoneNumberPage> {
  TextEditingController phoneNumber = TextEditingController();

  GlobalKey prefixKey = GlobalKey();

  Widget prefix() {
    return Container(
      key: prefixKey,
      margin: EdgeInsets.only(right: 4.0, bottom: 21),
      decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: Colors.black, width: 0.5))),
      padding: const EdgeInsets.only(bottom:12.0),
     child: new Text('+91', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color.fromRGBO(10, 23, 71, 1),)),
    );
  }
  FocusNode f = FocusNode();
  void initState(){
    super.initState();
    f.requestFocus();
  }
  @override
  Widget build(BuildContext context) {

    final auth = Provider.of<AuthProviderl>(context);

    Widget title = Text(
      'Welcome to secret notes',
      style: TextStyle(
          fontSize: 28.0,
          fontWeight: FontWeight.bold,
          color: Color.fromRGBO(10, 23, 71, 1),
          shadows: [
            BoxShadow(
              color: Colors.blueGrey.shade400,
              offset: Offset(2, 2),
              blurRadius: 2.0,
            )
          ]),
    );

    Widget subTitle = Text(
      'Enter your mobile number to get the OTP',
      style: TextStyle(
        color: Color.fromRGBO(10, 23, 71, 1),
        fontSize: 16.0,
      ),
    );

    Widget sendButton = Positioned(
      left: MediaQuery.of(context).size.width *0.3/1.1,
      bottom: 80,
      child: InkWell(
        onTap: () {
          Fluttertoast.showToast(msg: 'Wait.. Sending OTP', backgroundColor: Colors.grey, textColor: Colors.black);
          auth.verifyPhoneNumber(context, phoneNumber.text);
        },
        child: Container(
          width: MediaQuery.of(context).size.width / 2.2,
          height: 60,
          child: Center(
              child: new Text("Send OTP",
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
    );

    Widget phoneForm = Container(
      height: 210,
      child: Stack(
        children: <Widget>[
          Container(
            height: 100,
            width: MediaQuery.of(context).size.width,
            padding: const EdgeInsets.only(left: 32.0, right: 32.0,bottom: 20),
            decoration: BoxDecoration(
                color: Color.fromRGBO(243, 244, 253, 1),
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(10),
                    bottomLeft: Radius.circular(10))),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
                prefix(),
                Flexible(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 10.0),
                    child: TextField(
                      onSubmitted: (value){
                        Fluttertoast.showToast(msg: 'Wait.. Sending OTP', backgroundColor: Colors.grey, textColor: Colors.black);
                        auth.verifyPhoneNumber(context, phoneNumber.text);
                      },
                      onEditingComplete: (){
                        Fluttertoast.showToast(msg: 'Wait.. Sending OTP', backgroundColor: Colors.grey, textColor: Colors.black);
                        auth.verifyPhoneNumber(context, phoneNumber.text);
                      },
                      focusNode: f,
                      controller: phoneNumber,
                      style: TextStyle(fontSize: 18.0, color: Color.fromRGBO(10, 23, 71, 1),),
                      decoration: InputDecoration(
                        hintText: 'Enter Phone Number',
                        // hintStyle: TextStyle(color: Colors.white),
                      ),
                      keyboardType: TextInputType.numberWithOptions(signed: false, decimal: false),
                      maxLength: 10,
                    ),
                  ),
                ),
              ],
            ),
          ),
          sendButton,
        ],
      ),
    );

    return WillPopScope(
        onWillPop: (() async {
          // setState(() {
          //   h = 2.5;
          // });
          return true;
        }),
    child:
           GestureDetector(
             onTap: () {
             },
             child: Scaffold(
               body: Container(
                 child: Stack(
                     children: [
                       Column(
                         mainAxisAlignment: MainAxisAlignment.start,
                         children: <Widget>[
                           Spacer(flex: 2),
                           title,
                           Spacer(),
                           subTitle,
                           auth.loading ?
                           CircularProgressIndicator() : Container(),
                           Spacer(),
                           phoneForm,
                           Spacer(flex: 2),
                         ],
                         ),
                     ],
                   ),
                 ),
               ),
             ),
    );
  }
}


