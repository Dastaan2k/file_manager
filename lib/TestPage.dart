import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'BackEnd/FileFunctions.dart';
import 'BackEnd/Storage.dart';

class TestPage extends StatefulWidget {

  @override
  _TestPageState createState() => _TestPageState();
}

class _TestPageState extends State<TestPage>{

  TextEditingController _moveController = TextEditingController();
  TextEditingController _copyController = TextEditingController();
  TextEditingController _renameController = TextEditingController();
  TextEditingController _createController = TextEditingController();
  FileFunction _fileFunction = FileFunction();
  Storage _storageAPI = Storage();
  List _buttonList = List<Widget>();

  @override
  void initState() {
    print("Test Page");
    // TODO: implement initState
    super.initState();

   /// RuntimeTypes :
    /// Directory : _Directory
    /// File : _File

  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {


    return WillPopScope(
      onWillPop: ()async{return false;},
      child: Scaffold(
        appBar: AppBar(
          actions: [IconButton(icon: Icon(Icons.add,color: Colors.white,),onPressed: (){
            showDialog(context: context,builder: (context){
              return AlertDialog(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                actionsPadding: EdgeInsets.symmetric(horizontal: 10),
                actions: [
                  FlatButton(child: Text("Cancel"),onPressed: (){_createController.text = "";Navigator.pop(context);},),
                  FlatButton(child: Text("Confirm"),onPressed: (){
                    print(_createController.text);
                    _fileFunction.createDirectory(newDirectoryName: _createController.text).then((value){_createController.text = "";Navigator.pop(context);});},)
                ],
                title: Column(
                  children: [
                    Text("Name of the new Folder : "),
                    Container(child: _createTextField(),),
                  ],
                ),
              );
            });
          },)],
          leading: IconButton(icon: Icon(Icons.arrow_back,color: Colors.white,),onPressed: (){_fileFunction.exitDirectory(context);},),
          title: Text("Chindi File Manager",style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold),),
        ),
        body: StreamBuilder(
          stream: Storage.currentDirectoryStream,
          builder: (BuildContext context,AsyncSnapshot snapshot){

            _buttonList = [];

            for(int i=0;i<_storageAPI.pathStack.length;i++){
              if(i == 0)
                _buttonList.add(InkWell(onTap: (){_fileFunction.forceRollback(rollbackDirectory: _storageAPI.pathStack[i]);},child: Text("Root/" + "      ",style: TextStyle(fontWeight: FontWeight.bold),),));
              if(i>=1){
               // print(i.toString() + _storageAPI.pathStack[i]);
               //  print((i-1).toString() + _storageAPI.pathStack[i-1]);
                _buttonList.add(
                    InkWell(
                      onTap:(){_fileFunction.forceRollback(rollbackDirectory: _storageAPI.pathStack[i]);},
                      child: Text(_storageAPI.pathStack[i].replaceAll(_storageAPI.pathStack[i-1], "") + "      ",style: TextStyle(fontWeight: FontWeight.bold),),
                    ),
                );
              }
            }
           // _buttonList.forEach((element) {print(element);});
           // print(_storageAPI.pathStack.toString());
           // _storageAPI.pathStack.last.split('/').forEach((element) {print(element + "\n");});

            if(snapshot.hasData){
                return Column(
                  children: [
                    Container(
                      height: 60,
                      padding: EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        border: Border(bottom: BorderSide(color: Colors.grey,width: 1)),
                      ),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: ListView.builder(scrollDirection: Axis.horizontal,itemCount: _buttonList.length,itemBuilder: (context,index){return _buttonList[index];}),/*Text(_storageAPI.pathStack.last,style: TextStyle(fontWeight: FontWeight.bold),),*/
                      ),
                    ),
                    snapshot.data.isEmpty ? Expanded(child: Container(child: Center(child: Text("Empty Folder"),),)) :
                    Expanded(
                      child: ListView.builder(
                          itemCount: snapshot.data.length,
                          itemBuilder: (context,index){
                        return _fileCard(snapshot.data[index]);
                      }),
                    ),
                  ],
                );
            }
            else{
             return Container(child: Center(
               child: Text("Fetching data"),
             ),);
            }
          },
        ),
      ),
    );
  }

  Widget _fileCard(dynamic file)      /// CAN BE A FILE OR A DIRECTORY
  {
    String fileName = file.path.replaceAll(_storageAPI.currentDirectory, "");
      return InkWell(
        onTap: (){_fileFunction.enterDirectory(newDirectory: file );},
        child: Stack(
          children: [
            Container(
              height: 125,
              decoration: BoxDecoration(border : Border(bottom: BorderSide(color: Colors.grey[800],width: 1))),
            ),
            Positioned(
              bottom: 60,
              left: MediaQuery.of(context).size.width  * 0.15,
              child: Text(fileName,style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold),),
            ),
            Positioned(
              bottom: 5,
              right: 0,
              child: Container(
              height: 40,
              width: MediaQuery.of(context).size.width * 0.55,
              padding: EdgeInsets.symmetric(horizontal: 10,vertical: 5),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  InkWell(
                    onTap: (){
                      _fileFunction.getDetails(file: file).then((stats){
                        showDialog(context: context,builder: (context){
                          return Dialog(
                            insetPadding: EdgeInsets.symmetric(horizontal: 20),
                            child: Padding(
                              padding: EdgeInsets.only(top: 20),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                    Text("Type : ${stats.type}"),
                                    Text("Mode : ${stats.mode}"),
                                    Text("Lat Modified : ${stats.modified}"),
                                    Text("Created on : ${stats.accessed}"),
                                    Text("Size : ${stats.size}"),
                                    Padding(
                                      padding: EdgeInsets.symmetric(vertical: 15),
                                      child: FlatButton(
                                        onPressed: (){Navigator.pop(context);},
                                        color: Colors.blueAccent,
                                        child: Text("OK",style: TextStyle(fontWeight: FontWeight.bold,color: Colors.white),),
                                      ),
                                    )
                                ],
                              ),
                            ),
                          );
                        });
                      });
                    },
                    child: Container(
                      height: 30,width: 30,
                      decoration: BoxDecoration(
                        color: Colors.yellow,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Center(child: Icon(Icons.info_outline,color: Colors.white,size: 20,)),
                    ),
                  ),
                  InkWell(
                    onTap: (){
                      showDialog(context: context,builder: (context){
                        return AlertDialog(
                          title: Text("Confirm Delete : "),
                          content: Text("Pakka delete karnay ?"),
                          actions: [
                            FlatButton(child: Text("No",style: TextStyle(color: Colors.red),),onPressed: (){Navigator.pop(context);},),
                            FlatButton(child: Text("Yes",),onPressed: (){_fileFunction.deleteDirectory(directory: file).then((value){Navigator.pop(context);});},),
                          ],
                        );
                      });
                    },
                    child: Container(
                      height: 30,width: 30,
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Center(child: Icon(Icons.delete,color: Colors.white,size: 20,)),
                    ),
                  ),
                  InkWell(
                    onTap: (){
                      showDialog(
                        context: context,
                          builder: (context){
                            print(file.path);
                            return AlertDialog(
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                              actionsPadding: EdgeInsets.symmetric(horizontal: 10),
                              actions: [
                                FlatButton(child: Text("Cancel"),onPressed: (){_renameController.text = "";Navigator.pop(context);},),
                                FlatButton(child: Text("Confirm"),onPressed: (){_fileFunction.renameDirectory(file, _renameController.text).then((value){_renameController.text = "";Navigator.pop(context);});},)
                              ],
                              title: Column(
                                children: [
                                  Text("Rename : "),
                                  Container(child: _renameTextField(),),
                                ],
                              ),
                            );
                          }
                      );
                    },
                    child: Container(
                      height: 30,width: 30,
                      decoration: BoxDecoration(
                        color: Colors.green,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Center(child: Icon(Icons.edit,color: Colors.white,size: 20,)),
                    ),
                  ),
                  InkWell(
                    onTap: (){
                      showDialog(context: context,builder: (context){
                        return AlertDialog(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          actionsPadding: EdgeInsets.symmetric(horizontal: 10),
                          actions: [
                            FlatButton(child: Text("Cancel"),onPressed: (){_copyController.text = "";Navigator.pop(context);},),
                            FlatButton(child: Text("Paste"),onPressed: (){
                              _fileFunction.copyDirectory(file: file, destinationPath: _copyController.text).then((value){print("Pop");_copyController.text = "";Navigator.pop(context);});
                            },key: Key("FlatButton1"),),
                          ],
                          title: Column(
                            children: [
                              Text("Enter the destination path : "),
                              Container(child: _copyTextField(),),
                            ],
                          ),
                        );
                      });
                    },
                    child: Container(
                      height: 30,width: 30,
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Center(child: Icon(Icons.content_copy,color: Colors.white,size: 20,)),
                    ),
                  ),
                  InkWell(
                    onTap: (){
                      showDialog(context: context,builder: (context){
                        return AlertDialog(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          actionsPadding: EdgeInsets.symmetric(horizontal: 10),
                          actions: [
                            FlatButton(child: Text("Cancel"),onPressed: (){_moveController.text = "";Navigator.pop(context);},),
                            FlatButton(child: Text("Move"),onPressed: (){
                              _fileFunction.moveDirectory(file: file, destinationPath: _moveController.text).then((value){_moveController.text = "";Navigator.pop(context);});
                            },)
                          ],
                          title: Column(
                            children: [
                              Text("Enter the destination path : "),
                              Container(child: _moveTextField(),),
                            ],
                          ),
                        );
                      });
                    },
                    child: Container(
                      height: 30,width: 30,
                      decoration: BoxDecoration(
                        color: Colors.lightBlue,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Center(child: Icon(Icons.forward,color: Colors.white,size: 20,)),
                    ),
                  ),
                ],
              ),
            ))
          ],
        ),
      );
  }


  Widget _createTextField(){

    return TextField(
      controller: _createController,
      maxLines: 1, enabled: true,
      decoration: InputDecoration(
        hintText: "Try not to add'/ in the name",
        contentPadding: EdgeInsets.all(0),
        hintStyle: TextStyle(color: Colors.blueAccent),
        enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey,width: 1)),
        focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey[800],width: 1)),
      ),
    );
  }

  Widget _copyTextField(){

    return TextField(
      controller: _copyController,
      maxLines: 1, enabled: true,
      decoration: InputDecoration(
        hintText: "Full Paste Destination...",
        contentPadding: EdgeInsets.all(0),
        hintStyle: TextStyle(color: Colors.grey),
        enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey,width: 1)),
        focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey[800],width: 1)),
      ),
    );
  }

  Widget _moveTextField(){

    return TextField(
      controller: _moveController,
      maxLines: 1, enabled: true,
      decoration: InputDecoration(
        hintText: "Full Move Destination...",
        contentPadding: EdgeInsets.all(0),
        hintStyle: TextStyle(color: Colors.grey),
        enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey,width: 1)),
        focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey[800],width: 1)),
      ),
    );
  }

  Widget _renameTextField(){

    return TextField(
      controller: _renameController,
      maxLines: 1, enabled: true,
      decoration: InputDecoration(
          hintText: "Try not to add'/' in your name",
          contentPadding: EdgeInsets.all(0),
          hintStyle: TextStyle(color: Colors.lightBlue),
          enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey,width: 1)),
          focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey[800],width: 1)),
      ),
    );
  }
}


// ROOT : /storage/emulated/0/
