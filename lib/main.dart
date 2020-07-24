import 'package:file_test/BackEnd/FileFunctions.dart';
import 'package:file_test/TestPage.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

import 'BackEnd/Storage.dart';


void main() async {

  print("Main");
  WidgetsFlutterBinding.ensureInitialized();
  Storage _storage = Storage();
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
      home: TestPage(),
    );
  }
}




