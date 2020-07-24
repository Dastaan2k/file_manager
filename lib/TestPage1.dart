import 'dart:io';

import 'package:file_test/BackEnd/FileFunctions.dart';
import 'package:file_test/BackEnd/Storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class TestPage1 extends StatefulWidget {
  @override
  _TestPage1State createState() => _TestPage1State();
}

class _TestPage1State extends State<TestPage1> {

  FileFunction _fileFunction;
  Storage _storageAPI = Storage();

  List<String> x = [];
  List<Widget> childDirectoryList = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Text(_storageAPI.currentDirectory),
      ),
      body: Center(
          child: x.length == 0 ? Container(child: Center(child: Text("Fetching Data ..."),),) :
          ListView(
            scrollDirection: Axis.vertical,
            children: childDirectoryList,
          )
      ),
    );
  }
}
