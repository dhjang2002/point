// ignore_for_file: file_names

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:point/common/InputForm.dart';
import 'package:point/common/dialogbox.dart';
import 'package:point/models/newPerson.dart';
import 'package:point/provider/sessionData.dart';
import 'package:point/remote/remote.dart';
import 'package:provider/provider.dart';

class JoinUser extends StatefulWidget {
  final NewPerson person;
  const JoinUser({Key? key, required this.person}) : super(key: key);

  @override
  State<JoinUser> createState() => _JoinUserState();
}

class _JoinUserState extends State<JoinUser> {
  late SessionData _session;

  @override
  void initState() {
    _session = Provider.of<SessionData>(context, listen: false);
    //print(_session.toString());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("회원가입"),
      ),
      body: Container(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            InputForm(
              //title: "이름",
              valueText: widget.person.name!,
              hintText: '사용자 이름',
              onChange: (String value) {
                widget.person.name = value.trim();
              }, onlyDigit: false,
            ),
            const SizedBox(height: 10,),
            InputForm(
              keyboardType:TextInputType.number,
              valueText: widget.person.mobile!,
              hintText: '휴대폰 번호',
              onChange: (String value) {
                widget.person.mobile = value.trim();
              }, onlyDigit: false,
            ),
            const SizedBox(height: 10,),
            InputForm(
              //title: "이메일",
              valueText: widget.person.email!,
              hintText: '이메일 주소',
              onChange: (String value) {
                widget.person.email = value.trim();
              }, onlyDigit: false,
            ),
            const SizedBox(height: 50,),

            GestureDetector(
              child: Container(
                width: double.infinity,
                margin: const EdgeInsets.fromLTRB(15,0,15,0),
                padding: const EdgeInsets.fromLTRB(0,20,0,20),
                decoration:  BoxDecoration(
                    color: Colors.amber,
                    borderRadius: BorderRadius.circular(50.0)
                ),
                child: const Center(
                    child:Text('회원가입',
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 15.0,
                            fontWeight: FontWeight.bold)
                    )
                ),
              ),
              onTap: (){
                _reqJoin();
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _reqJoin() async {
    if(widget.person.name!.isEmpty) {
      showToastMessage("이름을 입력하세요");
      return;
    }

    if(widget.person.mobile!.isEmpty) {
      showToastMessage("휴대폰 번호를 입력하세요");
      return;
    }

    if(widget.person.email!.isEmpty) {
      showToastMessage("이메일 주소를 입력하세요");
      return;
    }

    await Remote.apiPost(
        context: context,
        session: _session,
        method: "point/join",
        params: {
          "sKakaoId":widget.person.id,
          "sName" :widget.person.name,
          "sEmailAddr" :widget.person.email,
          "sMobile" :widget.person.mobile,
        },
        onResult: (dynamic response) async {
          if (kDebugMode) {
            var logger = Logger();
            logger.d(response);
          }

          if (response['status'] == "success") {
            String token = response['data']['token'].toString().trim();
            Navigator.pop(context, token);
          }
          else {
            showOkDialogBox(context: context,
                title: "오류",
                message: response['message']);
          }
        },
        onError: (String error) {}
    );
  }
}
