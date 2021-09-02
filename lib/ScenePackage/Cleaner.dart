import 'package:file_test/BackEnd/FileFunctions.dart';
import 'package:file_test/BackEnd/Storage.dart';
import 'package:flutter/material.dart';

class Cleaner extends StatefulWidget {
  @override
  _CleanerState createState() => _CleanerState();
}

class _CleanerState extends State<Cleaner> {

  List<String> logList = [];

  @override
  void initState() {
    // TODO: implement initState

   //; FileFunction().cleanupDuplicacyCheckAsync();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: Container(
        child: StreamBuilder(
          stream: Storage.logStreamController.stream.asBroadcastStream(),
          builder: (context,snap){

            if(snap.hasData){

              print(logList.length);

              logList.add(snap.data);

              return ListView(
                scrollDirection: Axis.vertical,
                children: logList.map((e) => Text(e)).toList(),
              );
            }
            else{
              return Container(child: Center(child: Padding(
                padding: EdgeInsets.symmetric(vertical: 5),
                child: Text("Wait for it ....."),
              ),),);
            }
          },
        ),
      ),
    );
  }
}
