import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:phone_auth/HomeScreen.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return MyAppState();
  }
}

class MyAppState extends State<MyApp> {
  String phoneNum, smsCode = "";
  bool isDisabled = true;

  _verificationComplete(AuthCredential authCredential, BuildContext context) {
    FirebaseAuth.instance
        .signInWithCredential(authCredential)
        .then((authResult) {
      final snackBar =
          SnackBar(content: Text("Success!!! UUID is: " + authResult.user.uid));
      Scaffold.of(context).showSnackBar(snackBar);
    });
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => HomeScreen()),
    );
  }

  _smsCodeSent(String verificationId, List<int> code) {
    // set the verification code so that we can use it to log the user in
    smsCode = verificationId;
  }

  _verificationFailed(AuthException authException, BuildContext context) {
    final snackBar = SnackBar(
        content:
            Text("Exception!! message:" + authException.message.toString()));
    Scaffold.of(context).showSnackBar(snackBar);
  }

  _codeAutoRetrievalTimeout(String verificationId) {
    // set the verification code so that we can use it to log the user in
    smsCode = verificationId;
  }

  _verifyPhoneNumber(BuildContext context) async {
    final FirebaseAuth _auth = FirebaseAuth.instance;
    await _auth.verifyPhoneNumber(
        phoneNumber: phoneNum,
        timeout: Duration(seconds: 10),
        verificationCompleted: (authCredential) =>
            _verificationComplete(authCredential, context),
        verificationFailed: (authException) =>
            _verificationFailed(authException, context),
        codeAutoRetrievalTimeout: (verificationId) =>
            _codeAutoRetrievalTimeout(verificationId),
        // called when the SMS code is sent
        codeSent: (verificationId, [code]) =>
            _smsCodeSent(verificationId, [code]));
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text("Phone Number Auth"),
        ),
        body: Column(
          children: <Widget>[
            SizedBox(
              child: Text("\n\n"),
            ),
            TextField(
              decoration: InputDecoration(
                  labelText: "Phone number",
                  hintText: "Enter country code and number",
                  border: OutlineInputBorder(),
                  icon: Icon(Icons.phone)),
              onChanged: (val) {
                this.phoneNum = val;
              },
            ),
            FlatButton(
              child: Text("Verify number"),
              color: Colors.green,
              onPressed: () {
                print("YES BITCHES" + phoneNum);
                setState(() {
                  isDisabled = false;
                });
              },
            ),
            Visibility(
                visible: !isDisabled,
                child: Builder(
                  builder: (context) {
                    return Center(
                        child: Column(
                          children: <Widget>[
                              SizedBox(
                                child: Text("\n\n"),
                              ),
                              Text("Enter the code you received"),
                              TextField(
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                  labelText: "Enter Code",
                                  hintText: smsCode,
                                  //icon: Icon(Icons.)
                                ),
                                onChanged: (val) {
                                  this.smsCode = val;
                                  //print("THIS IS smscode: "+val);
                                },
                              ),
                              FlatButton(
                                child: Text("Enter Code"),
                                color: Colors.green,
                                onPressed: () => _verifyPhoneNumber(context),
                              ),
                          ],
                        )
                    );
                  },
                )
            )
          ],
        ),
      ),
    );
  }
}
