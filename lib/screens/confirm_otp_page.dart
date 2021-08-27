import 'package:otp_count_down/otp_count_down.dart';
import 'package:flutter/material.dart';
import 'package:secret_notes/auth/auth_provider.dart';
import 'package:provider/provider.dart';
import 'package:flutter/painting.dart';

class ConfirmOtpPage extends StatefulWidget {
  final String number;
  ConfirmOtpPage(this.number);
  @override
  _ConfirmOtpPageState createState() => _ConfirmOtpPageState();
}

class _ConfirmOtpPageState extends State<ConfirmOtpPage>{
  OTPCountDown _otpCountDown; // create instance
  final int _otpTimeInMS = 1000 * 60;
  String countdown='';
  bool showresend = false;
  FocusNode f = FocusNode();

  void initState(){
    super.initState();
    _otpCountDown = OTPCountDown.startOTPTimer(
      timeInMS: _otpTimeInMS, // time in milliseconds
      currentCountDown: (String countDown) {
        setState(() {
          countdown = countDown;
        });// shows current count down time
      },
      onFinish: () {
        setState(() {
          showresend = true;
        });
        print("Count down finished!"); // called when the count down finishes.
      },);
    f.requestFocus();
  }
void dispose(){
    super.dispose();
    _otpCountDown?.cancelTimer();
}
  @override
  TextEditingController smsOtp = new TextEditingController();
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProviderl>(context);
    Widget title = Text(
      'Enter your OTP',
      style: TextStyle(
          color: Color.fromRGBO(10, 23, 71, 1),
          fontSize: 34.0,
          fontWeight: FontWeight.bold,
          shadows: [
            BoxShadow(
              color: Colors.blueGrey.shade400,
              offset: Offset(2, 2),
              blurRadius: 2.0,
            )
          ]),
    );

    Widget subTitle = Padding(
        padding: const EdgeInsets.all(4),
        child: Text(
          'OTP sent to ${widget.number}',
          style: TextStyle(
            color: Color.fromRGBO(10, 23, 71, 1),
            fontSize: 16.0,
          ),
        ));

    Widget verifyButton =  Positioned(
      left: MediaQuery.of(context).size.width *0.3/1.1,
      bottom: 80,
      child: InkWell(
        onTap: ()async {
          auth.getotp(context, smsOtp.text);
        },
        child: Container(
          width: MediaQuery.of(context).size.width / 2.2,
          height: 60,
          child: Center(
              child: new Text("Verify",
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
            padding: const EdgeInsets.only(left: 32.0, right: 32.0,bottom: 30),
            decoration: BoxDecoration(
                color: Color.fromRGBO(243, 244, 253, 1),
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(10),
                    bottomLeft: Radius.circular(10))),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
                Flexible(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 10.0),
                    child: TextField(
                      focusNode: f,
                      controller: smsOtp,
                      style: TextStyle(fontSize: 18.0, color: Color.fromRGBO(10, 23, 71, 1),),
                      decoration: InputDecoration(
                        hintText: 'Enter OTP',
                          // hintStyle: TextStyle(color: Colors.white),
                      ),
                      onSubmitted: (value){
                        auth.getotp(context, smsOtp.text);
                      },
                      onEditingComplete: (){
                        auth.getotp(context, smsOtp.text);
                      },
                      keyboardType: TextInputType.numberWithOptions(signed: false, decimal: false),
                      maxLength: 6,
                    ),
                  ),
                ),
              ],
            ),
          ),
          verifyButton,
        ],
      ),
    );
    Widget resendText = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(15.0),
          child: InkWell(
            onTap: () {
              Navigator.pop(context);
            },
            child: Text(
              showresend? 'Resesnd OTP': 'Resend in: $countdown',
              style: TextStyle(
                // backgroundColor: Colors.yellow.withOpacity(0.4),
                color: Color.fromRGBO(10, 23, 71, 1),
                fontWeight: FontWeight.bold,
                fontSize: 18.0,
              ),
            ),
          ),
        ),
      ],
    );

    return  WillPopScope(
      onWillPop: (() async {
        FocusScope.of(context).requestFocus(new FocusNode());
        return false;
      }),
      child: GestureDetector(
        onTap: () {
          FocusScope.of(context).requestFocus(new FocusNode());
        },
        child: Scaffold(
                body: Container(
                    child: Stack(
                  children: <Widget>[
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      // crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Spacer(flex: 3),
                        title,
                        Spacer(),
                        auth.loading?
                        CircularProgressIndicator():Container(),
                        Spacer(),
                        subTitle,
                        phoneForm,
                        Spacer(flex: 2),
                        resendText
                      ],
                    )
                  ],
                ),
              ),
            // ),
          // ),
        ),
      ),
    );
  }
}
