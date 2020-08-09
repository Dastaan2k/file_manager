import 'package:file_test/BackEnd/FileFunctions.dart';
import 'package:file_test/BackEnd/Storage.dart';
import 'package:file_test/DataModel/Entity.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SearchTestPage extends StatefulWidget {
  @override
  _SearchTestPageState createState() => _SearchTestPageState();
}

class _SearchTestPageState extends State<SearchTestPage> {

  Storage _storageAPI = Storage();
  FileFunction _fileFunctionAPI = FileFunction();
  List temp = [];

  TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _controller.addListener(() {setState(() {
      print(_controller.text);
      temp = _fileFunctionAPI.searchForPattern(_controller.text);
    });});
  }

  @override
  Widget build(BuildContext context) {

    print("Build");

    return Scaffold(
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Container(
                width: MediaQuery.of(context).size.width - 40,
                height: 50,
                child: TextField(
                  controller: _controller,
                ),
              ),
            ),
            Expanded(
              child: Container(
                child: FutureBuilder(
                  future: _fileFunctionAPI.buildSearchList(),
                  builder: (context,snapshot){
                    if(snapshot.connectionState == ConnectionState.waiting){
                      return Center(child: Text("Fetching data"),);
                    }
                    else if(snapshot.connectionState == ConnectionState.done){
                     // List temp = snapshot.data;
                   //   print("Length : " + temp.length.toString());
                      return ListView(
                        children: temp.map((searchEntity) => _card(searchEntity)).toList(),
                      );
                    }
                    else{
                      return Center(child: Text("Other"),);
                    }
                  },
              ),
            ))
          ],
        ),
      ),
    );
  }

  Widget _card(SearchEntity entity){
    return Container(
      width: MediaQuery.of(context).size.width - 40,height: 100,
      decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Colors.grey[700],width: 2))),
      child: Center(
        child: Column(mainAxisSize: MainAxisSize.min,children: [
          Text(entity.name),
         // Text(entity.path),
        ],),
      ),
    );
  }
}
