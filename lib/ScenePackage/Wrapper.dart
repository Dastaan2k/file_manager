import 'dart:convert';
import 'dart:io';

import 'package:disk_space/disk_space.dart';
import 'package:file_test/BackEnd/FileFunctions.dart';
import 'package:file_test/BackEnd/Storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:liquid_swipe/liquid_swipe.dart';
import 'package:system_info/system_info.dart';
import 'package:file_test/ScenePackage/DashboardNew.dart';

//import 'Dashboard.dart';
import 'GeneralPage.dart';

class Wrapper extends StatefulWidget {
  @override
  _WrapperState createState() => _WrapperState();
}

class _WrapperState extends State<Wrapper> {

  FileFunction _fileFunction = FileFunction();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    //_fileFunction.future();
  }

  @override
  Widget build(BuildContext context) {

    //print("Build 1");

    return Scaffold(
      body: LiquidSwipe(
        onPageChangeCallback: (x){if(x == 0){Storage.liquidSwipeToggleLock = true;}else{Storage.liquidSwipeToggleLock = false;}},
        pages: [
          DashBoard(),
          //DashboardNew(),
          //DashBoard(),
          GeneralPage(),//GeneralPage(),
        ],
        enableLoop: false,
        initialPage: 0,
        //liquidController: LiquidController(),
        enableSlideIcon: true,
      ),
    );
  }
}
