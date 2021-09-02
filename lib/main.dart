import 'package:disk_space/disk_space.dart';
import 'package:file_test/BackEnd/FileFunctions.dart';
import 'package:file_test/ScenePackage/Cleaner.dart';
import 'ScenePackage/GeneralPage.dart';
import 'package:file_test/SearchTestPage.dart';
import 'package:file_test/TestPage.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

import 'BackEnd/Storage.dart';
import 'ScenePackage/Wrapper.dart';


void main() async {

  WidgetsFlutterBinding.ensureInitialized();
  Storage _storage = Storage();

  //DiskSpace.getTotalDiskSpace.then((value){Storage.totalInternalStorage = value / 1000;});

  print("Main");
  var permissionStatus = await Permission.storage.request();
  if(permissionStatus == PermissionStatus.granted)
    runApp(MyApp());
  else
    runApp(ErrorApp());
}


class ErrorApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: Scaffold(
        body: Container(
          child: Center(child: Text("Haga",style: TextStyle(color: Colors.black),),),
        ),
      ),
    );
  }
}



class MyApp extends StatelessWidget {

  FileFunction _fileFunctionAPI = FileFunction();
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {

    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: ScrollConfiguration(
          behavior: CustomScrollBehaviour(),child: Wrapper()
      ),
    );
  }
}


class CustomScrollBehaviour extends ScrollBehavior
{
  @override
  Widget buildViewportChrome(BuildContext context, Widget child, AxisDirection axisDirection) {
    // TODO: implement buildViewportChrome
    return child;
  }
}


