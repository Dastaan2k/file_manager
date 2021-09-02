import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:file_test/BackEnd/CleanerFunctions.dart';
import 'package:file_test/BackEnd/FileFunctions.dart';
import 'package:file_test/BackEnd/Storage.dart';
import 'package:file_test/Misc/CustomColors.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../DataModel/Entity.dart';


class GeneralPage extends StatefulWidget {
  @override
  _GeneralPageState createState() => _GeneralPageState();
}

class _GeneralPageState extends State<GeneralPage> with SingleTickerProviderStateMixin{


  /// Dont disable te selection feature which all the element in selected list is false instead of keeping a seperate toggle for viewing selected list   ..... Might be useless as it will traverse the whole list everytime to check if any true is present but that traversing can be avoided too if we apply the method below ...... Through that we can keep a count of how many trues are present (How many entities are selected
  /// Currently while selecting entities ..... it is traversing on each  selection for get how many entities are selected ....... instead we can keep a counter for it which will avoid the traversal

  /// Make sure you clear the selected List on changing the directory ....... and maybe make it a static entity in Storage class.

  double _height;
  double _width;

  bool _isCardBig = false;
  bool _isSearchExpanded = false;
  bool _isSelectionActive = false;
  bool _isMoreOptionEnabled = false;
  bool _isMoreOption2Enabled = false;
  bool _isSortMenuOpen = false;

  Color _searchColor = CustomColor.lightBackground;

  int itemsSelected = 0;
  //List<bool> isSelectedList = [];

  List<Entity> selectedEntityList = [];


  Storage _storageAPI  = Storage();
  FileFunction _fileFunction = FileFunction();
  TextEditingController _searchController = TextEditingController();

  ScrollController _scrollController = ScrollController(keepScrollOffset: true);

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    /*Future.delayed(Duration(seconds: 2),(){setState(() {
      _isCardBig = true;
    });}); */
   /* File("/storage/emulated/0/Movies/Hello/X/Dummy File").createSync(recursive: true);
    Directory('storage/emulated/0/Movies/World/Empty Folder 1').createSync(recursive: true);
    Directory('storage/emulated/0/Movies/World/Empty Folder 2').createSync(recursive: true);
    File('storage/emulated/0/Movies/World/Hello World').createSync(recursive: true);
    File('storage/emulated/0/Movies/World/HelloGG').createSync(recursive: true);
    File('storage/emulated/0/Movies/World/Folder/File').createSync(recursive: true);  */

   // _fileFunction.cleanerFileDuplicacyCheck();
    print("Hey");
    _scrollController.addListener(_scrollListener);
  }


  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    //Storage.currentDirectorySink.close();
  }

  @override
  Widget build(BuildContext context) {

    Visibility();

    if(Storage.generalPageInitToggle){
      print("Check Called");
      compute(CleanerFunction.duplicacyCheckModerateFiles,10).then((value){print("Check this : ${value.data}"); Scaffold.of(context).showSnackBar(SnackBar(content:Text("Hello World"),));});
      Storage.generalPageInitToggle = false;
    }

   /* if(_storageAPI.currentEntityList.isNotEmpty){
      print("Called");
      Storage.currentDirectorySink.add(_storageAPI.currentEntityList.map((entity){StreamController temp = StreamController();temp.add(entity);temp.close();return temp.stream.asBroadcastStream();}).toList());
    }  */


   print("Build");
    if(!Storage.liquidSwipeToggleLock){
      print("GGe");
      FileFunction().enterEntity(entity: Entity(path: _storageAPI.rootDirectory,type: EntityType.DIRECTORY),isForceRollback: true);
      Storage.liquidSwipeToggleLock = true;
    }
    /// Add a static toggle which will only call enter directory when liquid swipe takes place and not on other set States

    _height = MediaQuery.of(context).size.height;
    _width = MediaQuery.of(context).size.width;

          return Material(
            child: SafeArea(
              child: StreamBuilder(
                stream: Storage.currentDirectoryStream,
                builder: (context, snapshot) {

                  if(snapshot.hasData){

                    print("Snapshot has data ");

                    _storageAPI.currentEntityList = [];

                    if(Storage.isSelectedList.isEmpty){
                      Storage.isSelectedList = List.generate(snapshot.data.length, (index) => false);
                    }

                    return Stack(
                      children: [
                        Container(                                                                      /// Main Canvas
                          height: _height,
                          width: _width,
                          color: CustomColor.lightBackground,
                        ),
                        AnimatedPositioned(                                                          /// Upper Left
                          duration: Duration(milliseconds: 500),
                          top: _isSelectionActive ? -_height * 0.1 : 20,left: _isSearchExpanded ? -((_width - 40) - (_width - (_width * 0.3) - 20)) : 10,
                          child: Align(
                            alignment: Alignment.topLeft,
                            child: InkWell(onTap: (){},child: Container(width: _width * 0.125 + 10,height: _height * 0.1 - 20,child: Center(child: Icon(Icons.sort,color: Colors.grey[800],size: _height * 0.04,),),)),
                          ),
                        ),
                        AnimatedPositioned(                                                           /// Upper Right
                          top: _isSelectionActive ? - _height * 0.1 : 20,right: 10,
                          duration: Duration(milliseconds: 500),
                          child: Align(
                            alignment: Alignment.topRight,
                            child: AnimatedContainer(
                                onEnd: (){
                                  if(!_isSearchExpanded){
                                    setState(() {
                                      _searchColor = CustomColor.lightBackground;
                                    });
                                  }
                                },
                                padding: _isSearchExpanded ? EdgeInsets.all(10) : EdgeInsets.all(0),
                                duration: Duration(milliseconds: 200),width: _isSearchExpanded ? _width - 40 : _width * 0.125 + 10,height: _height * 0.1 - 20,
                                decoration: BoxDecoration(
                                  color: _searchColor,
                                  boxShadow: [BoxShadow(color: _isSearchExpanded ? Colors.grey[400] : Colors.transparent,offset: Offset(0,5),spreadRadius: 0.5,blurRadius: 1) ],
                                  borderRadius: BorderRadius.circular(_height * 0.05),
                                ),
                                child: Row(
                                  children: [
                                    Expanded(child: _isSearchExpanded ? TextField(enabled: true,decoration: InputDecoration(hintText: "Search for a File ..... ",hintStyle: TextStyle(color: Colors.grey[700]),enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.transparent)),focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.transparent))),) : Container()),
                                    InkWell(onTap: (){setState(() {
                                      _isCardBig = true;
                                      _isSearchExpanded = !_isSearchExpanded;
                                      if(_isSearchExpanded)
                                        _searchColor = Colors.white;
                                    });}, child: Icon(Icons.search,color: Colors.grey[800],size: _height * 0.04,),splashColor: Colors.white,),
                                  ],
                                )
                            ),
                          ),
                        ),
                        AnimatedPositioned(                                                   /// Mid Upper
                          duration: Duration(milliseconds: 200),
                          top:  _isSelectionActive ? -_height * 0.1 : 0,left: _isSearchExpanded ? -_width -40 : _width * 0.125 + 30,
                          child: SafeArea(
                            child: Padding(
                              padding: EdgeInsets.only(top: 10),
                              child: Container(
                                width: _width - (_width * 0.3) - 20,height: _height * 0.1,padding: EdgeInsets.symmetric(horizontal: 5),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    TweenAnimationBuilder(
                                      duration: Duration(milliseconds: 500),
                                      tween: Tween<double>(begin: 0,end: 0.7),
                                      builder: (context,angle,child){
                                        return CustomPaint(
                                          foregroundPainter: StrokePie(angle,5),
                                          child: Container(
                                            height: _height * 0.07,width: _height * 0.07,
                                            child: Center(child: Text("70%",style : TextStyle(color: Colors.grey[900],fontSize: _height * 0.02))),
                                          ),
                                        );
                                      },
                                    ),
                                    Padding(
                                      padding: EdgeInsets.only(left: 20 ),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        mainAxisSize: MainAxisSize.min,
                                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                                        children: [
                                          Text(_storageAPI.pathStack.last.split('/').last == '0' ? "Root Folder" : _storageAPI.pathStack.last.split('/').last,style: TextStyle(color: Colors.grey[900],fontSize: 20,fontWeight: FontWeight.bold),),
                                          Text("${_fileFunction.entitySizeConversion(Storage.totalInternalStorage.toInt() - Storage.freeInternalStorage.toInt())} / ${_fileFunction.entitySizeConversion(Storage.totalInternalStorage.toInt())}",style: TextStyle(color: Colors.grey[900],fontSize:12),),
                                        ],
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        AnimatedPositioned(                                                         /// Main Container
                            duration: Duration(milliseconds: 200),
                            top: _isCardBig ? _height * 0.175 : _height * 0.45,
                            child: AnimatedContainer(
                              duration: Duration(milliseconds: 500),
                              height: _isCardBig ? _height * 0.825 : _height * 0.55,width: _width,
                              decoration: BoxDecoration(
                                color: Colors.white,borderRadius: BorderRadius.only(topRight: Radius.circular(30),topLeft: Radius.circular(30)),
                                boxShadow: [BoxShadow(color: Colors.grey,blurRadius: 12.5,spreadRadius: 0,offset: Offset(0,0))],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisSize: MainAxisSize.max,
                                children: [
                                  Container(height: 10,width: _width,),
                                  Container(
                                    width: _width - 50,
                                    height: 60,
                                    //color: Colors.grey,
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        Expanded(child: Text("Internal Storage",style: TextStyle(fontSize: 22,fontWeight: FontWeight.bold),)),
                                        Padding(
                                          padding: EdgeInsets.symmetric(horizontal: 10),
                                          child: Icon(Icons.storage,color: Colors.grey[800],size: 20,),
                                        ),
                                        InkWell(onTap: (){setState(() {
                                          _isMoreOption2Enabled = true;
                                        });},child: Icon(Icons.more_vert,color: Colors.grey[800],size: 20,)),
                                      ],
                                    ),
                                  ),
                                  Container(
                                      width: _width - 50,
                                      height: 20,
                                      child: ListView.builder(
                                          scrollDirection: Axis.horizontal,
                                          itemCount: _storageAPI.pathStack.length,itemBuilder: (context,index){

                                        return InkWell(
                                          onTap: (){
                                            setState(() {
                                              _fileFunction.forceRollback(rollbackDirectory: _storageAPI.pathStack[index]);
                                            });
                                          },
                                          child: Text(_storageAPI.pathStack[index].split('/').last == "0" ? "Internal Storage   >   " : _storageAPI.pathStack[index].split('/').last + "   >   "),
                                        );
                                      })
                                  ),
                                  Expanded(
                                    child: snapshot.data.length == 0 ?  Center(child: Text("Empty Directory",style: TextStyle(color: Colors.grey[900]),),) :
                                    ScrollConfiguration(
                                      behavior: MyBehaviour(),
                                      child: ListView.builder(
                                          padding: EdgeInsets.all(10),
                                          controller: _scrollController,
                                          addAutomaticKeepAlives: true,
                                          itemCount: snapshot.data.length,
                                          cacheExtent: 10000,
                                          itemBuilder: (context,index){

                                            return StreamBuilder(
                                              stream: snapshot.data[index],
                                              builder: (context,snap){
                                                if(snap.hasData){

                                                  _storageAPI.currentEntityList.add(snap.data);

                                                  return InkWell(
                                                      onTap: (){
                                                        if(_isSelectionActive){
                                                          if(Storage.isSelectedList[index]){
                                                            itemsSelected--;
                                                          }
                                                          else{
                                                            itemsSelected++;
                                                          }
                                                          setState(() {
                                                            Storage.isSelectedList[index] = !Storage.isSelectedList[index];
                                                          });
                                                        }
                                                        else{
                                                          _isCardBig = false;
                                                          Storage.isSelectedList = [];
                                                          _fileFunction.enterEntity(entity: Entity(path: snap.data.path,type: snap.data.type));
                                                        }
                                                      },
                                                      onLongPress:(){
                                                        if(Storage.isSelectedList[index])
                                                          itemsSelected--;
                                                        else
                                                          itemsSelected++;
                                                        setState(() {Storage.isSelectedList[index] = true; _isSelectionActive = true; _isCardBig = true;});
                                                      },
                                                      child: _entityCard(Entity(path: snap.data.path,type: snap.data.type,size: snap.data.size,childFileQuantity: snap.data.childFileQuantity,childDirQuantity: snap.data.childDirQuantity), Storage.isSelectedList[index], index)
                                                  );
                                                }
                                                else{
                                                  return _entityCard(Entity(path: "/...",type: EntityType.DIRECTORY), false, index);
                                                }
                                              },
                                            );
                                          }
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            )
                        ),
                        AnimatedPositioned(
                          duration: Duration(milliseconds: 200),
                          top: _isSelectionActive ? 0 : - 70,
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 10),
                            height: 70,width: _width,decoration: BoxDecoration(color: Colors.white,borderRadius: BorderRadius.only(bottomRight: Radius.circular(20),bottomLeft: Radius.circular(20)),boxShadow: [BoxShadow(color: Colors.grey,blurRadius: 12.5,spreadRadius: 0.5,offset: Offset(0,0))],),
                            child: Row(
                              children: [
                                InkWell(onTap: (){setState(() {
                                  itemsSelected = 0;
                                  for(int i=0;i<Storage.isSelectedList.length;i++){
                                    Storage.isSelectedList[i] = false;
                                  }
                                  _isSelectionActive = false;
                                });},child: Container(width: 50,height: _height * 0.08,child: Center(child: Icon(Icons.clear,size: 25,color: Colors.grey[900],),),),
                                ),
                                Text("$itemsSelected  Item Selected",style: TextStyle(fontSize: 17.5,color: Colors.grey[900]),),
                              ],
                            ),
                          ),
                        ),
                        AnimatedPositioned(
                          duration: Duration(milliseconds: 200),
                          bottom: _isSelectionActive ? 0 : - 75,
                          child: Container(
                            height: 75,width: _width,
                            decoration: BoxDecoration(color: Colors.white.withOpacity(0.65),borderRadius: BorderRadius.only(topRight: Radius.circular(20),topLeft: Radius.circular(20)),boxShadow: [BoxShadow(color: Colors.grey,blurRadius: 12.5,spreadRadius: 0.5,offset: Offset(0,0))] ),
                            child: Row(
                              mainAxisSize: MainAxisSize.max,
                              children: [
                                InkWell(
                                  child: Container(
                                    color: Colors.transparent,
                                    height: 75,
                                    width: _width/5,
                                    child: Center(
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Padding(padding: EdgeInsets.only(bottom: 5),child: Icon(Icons.share,size: 25,)),
                                          Text("Share",style: TextStyle(color: Colors.grey[800],fontSize: 12),),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                InkWell(
                                  onTap: (){

                                    selectedEntityList = [];

                                    for(int i=0;i< Storage.isSelectedList.length;i++){
                                      if(Storage.isSelectedList[i])
                                        selectedEntityList.add(_storageAPI.currentEntityList[i]);
                                    }

                                    _fileFunction.copySelectedEntityList(selectedEntityList, 'storage/emulated/0/Movies').then((value){
                                      setState(() {
                                        _isSelectionActive = false;
                                      });
                                    });
                                  },
                                  child: Container(
                                    color: Colors.transparent,
                                    height: 75,
                                    width: _width/5,
                                    child: Center(
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Padding(padding: EdgeInsets.only(bottom: 5),child: Icon(Icons.content_copy,size: 25,)),
                                            Text("Copy",style: TextStyle(color: Colors.grey[800],fontSize: 12),),
                                          ],
                                        )
                                    ),
                                  ),
                                ),
                                InkWell(
                                  onTap: (){
                                    selectedEntityList = [];

                                    for(int i=0;i< Storage.isSelectedList.length;i++){
                                      if(Storage.isSelectedList[i])
                                        selectedEntityList.add(_storageAPI.currentEntityList[i]);
                                    }
                                    _fileFunction.moveSelectedEntityList(selectedEntityList, 'storage/emulated/0/Movies').then((value){
                                      setState(() {
                                        _isSelectionActive = false;
                                      });
                                    });
                                  },
                                  child: Container(
                                    color: Colors.transparent,
                                    height: 75,
                                    width: _width/5,
                                    child: Center(
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Padding(padding: EdgeInsets.only(bottom: 5),child: Icon(Icons.content_cut,size: 25,)),
                                            Text("Cut",style: TextStyle(color: Colors.grey[800],fontSize: 12),),
                                          ],
                                        )
                                    ),
                                  ),
                                ),
                                InkWell(
                                  onTap: (){
                                    selectedEntityList = [];

                                    for(int i=0;i< Storage.isSelectedList.length;i++){
                                      if(Storage.isSelectedList[i])
                                        selectedEntityList.add(_storageAPI.currentEntityList[i]);
                                    }

                                    //print(selectedEntityList[0].path);
                                    _fileFunction.deleteSelectedEntityList(selectedEntityList).then((value){
                                      setState(() {
                                        _isSelectionActive = false;
                                      });
                                    });


                                  },
                                  child: Container(
                                    color: Colors.transparent,
                                    height: 75,
                                    width: _width/5,
                                    child: Center(
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Padding(padding: EdgeInsets.only(bottom: 5),child: Icon(Icons.delete,size: 25,)),
                                            Text("Delete",style: TextStyle(color: Colors.grey[800],fontSize: 12),),
                                          ],
                                        )
                                    ),
                                  ),
                                ),
                                InkWell(
                                  onTap: (){
                                    setState(() {
                                      _isMoreOptionEnabled = true;
                                    });
                                  },
                                  child: Container(
                                    color: Colors.transparent,
                                    height: 75,
                                    width: _width/5,
                                    child: Center(
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Padding(padding: EdgeInsets.only(bottom: 5),child: Icon(Icons.more_vert,size: 25,)),
                                            Text("More",style: TextStyle(color: Colors.grey[800],fontSize: 12),),
                                          ],
                                        )
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                        _isMoreOptionEnabled || _isMoreOption2Enabled || _isSortMenuOpen ? InkWell(onTap: (){setState(() {
                          _isSortMenuOpen = false;
                          _isMoreOption2Enabled = false;
                          _isMoreOptionEnabled = false;
                        });},
                            child: Container(
                              decoration: BoxDecoration(color: _isSortMenuOpen ? Colors.grey.withOpacity(0.5) : Colors.transparent),height: _height,width: _width,
                            )) : Container(),
                        AnimatedPositioned(
                          duration: Duration(milliseconds: 200),
                          bottom: _isMoreOptionEnabled ? 85 : -335,
                          right: 10,
                          child: Container(
                            height: 335,
                            width: 170,
                            padding: EdgeInsets.symmetric(horizontal: 20,vertical: 10),
                            decoration: BoxDecoration(
                                color: Colors.white,
                                boxShadow: [BoxShadow(color: Colors.grey,blurRadius: 12.5,spreadRadius: 0.5,offset: Offset(0,0))],
                                borderRadius: BorderRadius.only(topLeft: Radius.circular(15),bottomLeft: Radius.circular(20),topRight: Radius.circular(20))
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.max,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  height: 45,
                                  width: 170,
                                  child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text("Copy to",style: TextStyle(fontSize: 15),),
                                  ),
                                ),
                                Container(
                                  height: 45,
                                  width: 170,
                                  child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text("Move to",style: TextStyle(fontSize: 15),),
                                  ),
                                ),
                                Container(
                                  height: 45,
                                  width: 170,
                                  child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text("Compress",style: TextStyle(fontSize: 15),),
                                  ),
                                ),Container(
                                  height: 45,
                                  width: 170,
                                  child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text("Hide",style: TextStyle(fontSize: 15),),
                                  ),
                                ),Container(
                                  height: 45,
                                  width: 170,
                                  child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text("Add to Favorites",style: TextStyle(fontSize: 15),),
                                  ),
                                ),InkWell(
                                  onTap: (){

                                    selectedEntityList = [];

                                    for(int i=0;i< Storage.isSelectedList.length;i++){
                                      if(Storage.isSelectedList[i])
                                        selectedEntityList.add(_storageAPI.currentEntityList[i]);
                                    }

                                    print(selectedEntityList);
                                    if(selectedEntityList.length == 1)
                                      _fileFunction.renameEntity(entity: selectedEntityList[0], newName: selectedEntityList[0].type == EntityType.DIRECTORY ? "Renamed Directory" : "Renamed File").then((value){setState(() {
                                        _isMoreOptionEnabled = false;
                                        _isSelectionActive = false;
                                      });});
                                    else
                                      print("Only one file must be selected to perform RENAME operation");
                                  },
                                  child: Container(
                                    height: 45,
                                    width: 170,
                                    child: Align(
                                      alignment: Alignment.centerLeft,
                                      child: Text("Rename",style: TextStyle(fontSize: 15),),
                                    ),
                                  ),
                                ),Container(
                                  height: 45,
                                  width: 170,
                                  child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text("Details",style: TextStyle(fontSize: 15),),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        AnimatedPositioned(
                          duration: Duration(milliseconds: 200),
                          top: _isCardBig ? _height * 0.175 + 60 : _height * 0.45 + 60,
                          right: _isMoreOption2Enabled ? 10 : -180,
                          child: Container(
                            width: 170,
                            height: 155,
                            decoration: BoxDecoration(
                                color: Colors.white,
                                boxShadow: [BoxShadow(color: Colors.grey,blurRadius: 12.5,spreadRadius: 0.5,offset: Offset(0,0))],
                                borderRadius: BorderRadius.only(topLeft: Radius.circular(15),bottomLeft: Radius.circular(20),bottomRight: Radius.circular(20))
                            ),
                            padding: EdgeInsets.symmetric(horizontal: 20,vertical: 10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.max,
                              children: [
                                InkWell(
                                  onTap: (){
                                    _fileFunction.createEntity(name: "New File", entityType: EntityType.FILE).then((value){
                                      setState(() {
                                        _isMoreOption2Enabled = false;
                                      });
                                    });
                                  },
                                  child: Container(
                                    height: 45,
                                    width: 170,
                                    child: Align(
                                      alignment: Alignment.centerLeft,
                                      child: Text("New File",style: TextStyle(fontSize: 15),),
                                    ),
                                  ),
                                ),
                                InkWell(
                                  onTap: (){
                                    _fileFunction.createEntity(name: "New Folder", entityType: EntityType.DIRECTORY).then((value){
                                      setState(() {
                                        _isMoreOption2Enabled = false;
                                      });
                                    });
                                  },
                                  child: Container(
                                    height: 45,
                                    width: 170,
                                    child: Align(
                                      alignment: Alignment.centerLeft,
                                      child: Text("New Folder",style: TextStyle(fontSize: 15),),
                                    ),
                                  ),
                                ),
                                InkWell(
                                  onTap: (){
                                    setState(() {
                                      _fileFunction.sortDirectory(query: "SIZE", order: "ASC");
                                      //_isSortMenuOpen = true;
                                      _isMoreOption2Enabled = false;
                                    });
                                  },
                                  child: Container(
                                    height: 45,
                                    width: 170,
                                    child: Align(
                                      alignment: Alignment.centerLeft,
                                      child: Text("Sort By ...",style: TextStyle(fontSize: 15),),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        _isSortMenuOpen ? Center(
                          child: Container(
                            width: _width * 0.55,
                            height: 300,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              boxShadow: [BoxShadow(color: Colors.grey,blurRadius: 12.5,spreadRadius: 0.5,offset: Offset(0,0))],
                              borderRadius: BorderRadius.all(Radius.circular(20)),
                            ),
                            child: Column(
                              children: [
                                Container(
                                  child: Center(child: Text("Sort by",style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold,fontSize: 20),),),
                                  height: 50,
                                ),
                                Row(children: [Radio(onChanged: (val){},groupValue: false,value: false,),Text("Name")],),
                                Row(children: [Radio(onChanged: (val){},groupValue: true,value: false,),Text("Size")],),
                                Row(children: [Radio(onChanged: (val){},groupValue: true,value: false,),Text("Type")],),
                                SizedBox(
                                  height: (_width * 0.3)/5,
                                  width: _width * 0.3,
                                  child: CustomPaint(
                                    foregroundPainter: CustomCapsule(),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ) : Container(),
                      ],
                    );
                  }
                  else{
                    return EmptyPage();
                  }
                }
              ),
            ),
          );

  }



  Widget _entityCard(Entity _entity,bool isSelected,int index){

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 30,vertical: 10),
      height: 80,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(color: Colors.yellow,height: 50,width: 60,),
          Expanded(
            child: Container(
                width: _width * 0.7,
                padding: EdgeInsets.only(left: 20),
                height: 50,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(_entity.name,style: TextStyle(fontWeight: FontWeight.bold,fontSize: 17,),overflow: TextOverflow.ellipsis,),
                        Text(_entity.type == EntityType.FILE ? "${_fileFunction.entitySizeConversion(_entity.size)}" : "${_entity.childFileQuantity + _entity.childDirQuantity} items |  ${_fileFunction.entitySizeConversion(_entity.size)}",style: TextStyle(fontSize: 10),),
                      ],
                    ),
                    _isSelectionActive ? InkWell(
                      onTap: (){setState(() {
                        if(Storage.isSelectedList[index]){
                          itemsSelected--;
                        //  selectedItems.remove(currentEntityList[index]);
                        }
                        else{
                          itemsSelected++;
                        //  selectedItems.add(currentEntityList[index]);
                        }
                        Storage.isSelectedList[index] = !Storage.isSelectedList[index];
                      });},
                      child: Container(
                        width: 60,
                        child: Center(
                          child: Container(height: 20,width: 20,decoration: BoxDecoration(border: Border.all(color: Colors.grey,width: 1.25),borderRadius: BorderRadius.circular(10),color: isSelected/*List[index]*/ ? Colors.redAccent : Colors.transparent),child: Center(child: Icon(Icons.check,color: Colors.white,size: 15,),),),
                        ),
                      ),
                    ) : Container(),
                  ],
                )
            ),
          ),
        ],
      ),
    );
  }



  void _scrollListener(){
    if(_scrollController.offset >= _scrollController.position.maxScrollExtent && !_scrollController.position.outOfRange)
      print("End of list");
    else if(_scrollController.offset > _scrollController.position.minScrollExtent){
      if(!_isCardBig)
        setState(() {
          print("Somewhere in middle");
          _isCardBig = true;
        });
    }
    else if(_scrollController.offset <= _scrollController.position.minScrollExtent){
      print("Start of list");
      if(_isCardBig)
        setState(() {
          _isCardBig = false;
        });
    }
  }

}


class MyBehaviour extends ScrollBehavior
{
  @override
  Widget buildViewportChrome(BuildContext context, Widget child, AxisDirection axisDirection) {
    // TODO: implement buildViewportChrome
    return child;
  }
}

class CustomCapsule extends CustomPainter   /// 7  Divisions   ..... (0 , 0.16 , 0.32 , 0.48 , 0.64 , 0.8 , 0.96 ) + 0.02 offset each for getting it to center
{
 /// It will resize itself based on the dimensions provided by the parent but its better that its height is width / 6;
  // TODO: Increase the span between 2-3 and 5-6 and compensate it with 1-2 and 6-7
  @override
  void paint(Canvas canvas, Size size) {
    // TODO: implement paint

    Path a = Path();
    Path b = Path();
    Paint x= Paint()..color = Colors.redAccent..strokeWidth = 2..style = PaintingStyle.fill..strokeCap = StrokeCap.round;
    Paint y = Paint()..color = Colors.grey..strokeWidth = 2..style = PaintingStyle.stroke..strokeCap = StrokeCap.round;

    num degToRad(num deg) => deg * (pi / 180.0);

    a.moveTo(size.width * (0.48 + 0.02), 0);//a.moveTo(45,0);
    a.lineTo(size.width * (0.16 + 0.02), 0);//a.lineTo(30,0);
    a.arcTo(Rect.fromCircle(radius: size.height/2,center: Offset(size.width * (0.16 + 0.02),size.height/2)), degToRad(-90), degToRad(-180), false);//a.arcTo(Rect.fromCircle(radius: 15,center: Offset(15,15)), degToRad(-90), degToRad(-180),false);
    a.lineTo(size.width * (0.32 + 0.02), size.height);//a.lineTo(30,30);
    a.lineTo(size.width * (0.48 + 0.02), 0);//a.lineTo(45, 0);
    //a.close();



    b.moveTo(size.width * (0.48 + 0.02), size.height);//a.moveTo(45, 30);
    b.lineTo(size.width * 0.8 + 0.02, size.height);//a.lineTo(75, 30);
    b.arcTo(Rect.fromCircle(radius: size.height/2,center: Offset(size.width * (0.8 + 0.02),size.height/2)), degToRad(90), degToRad(-180),false);//a.arcTo(Rect.fromCircle(radius: 15,center: Offset(75,15)), degToRad(90), degToRad(-180),false);
    b.lineTo(size.width * 0.64 + 0.02, 0);//a.lineTo(60, 0);
    b.lineTo(size.width * 0.48 + 0.02, size.height);//a.lineTo(45, 30);
    //a.close();


    canvas.drawPath(a,x);
    canvas.drawPath(b, y);

  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    // TODO: implement shouldRepaint
    return true;
  }
}




class StrokePie extends CustomPainter
{
  double _value;
  double _strokeWidth;

  StrokePie(this._value,this._strokeWidth);

  @override
  void paint(Canvas canvas, Size size) {
    // TODO: implement paint

    Paint outerArc = Paint()
      ..color = Colors.grey
      .. style = PaintingStyle.stroke
      .. strokeWidth = _strokeWidth * 0.9;

    Paint innerArc = Paint()
    ..strokeWidth = _strokeWidth
    ..style = PaintingStyle.stroke
    ..color = Colors.redAccent
    ..strokeCap = StrokeCap.round;

    Offset center = Offset(size.width/2,size.height/2);
    double pieRadius = min(size.width/2,size.height/2);
    double angle = 2 * pi * _value;

    canvas.drawCircle(center,pieRadius, outerArc);
    canvas.drawArc(Rect.fromCircle(center: center,radius: pieRadius), -pi/2, angle, false, innerArc);

  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    // TODO: implement shouldRepaint
    return true;
  }
}



class EmptyPage extends StatelessWidget {


  Storage _storageAPI = Storage();


  /// Instead of creating cards with '....' as name, you can actually get the data of current list from currentEntity List ..... so implement that ffs

  double _height;
  double _width;

  Color _searchColor = CustomColor.lightBackground;

  @override
  Widget build(BuildContext context) {

    _height = MediaQuery.of(context).size.height;
    _width = MediaQuery.of(context).size.width;

    return Stack(
      children: [
        Container(                                                                      /// Main Canvas
          height: _height,
          width: _width,
          color: CustomColor.lightBackground,
        ),
        Positioned(                                                          /// Upper Left
          top: 20,left: 10,
          child: Align(
            alignment: Alignment.topLeft,
            child: InkWell(onTap: (){},child: Container(width: _width * 0.125 + 10,height: _height * 0.1 - 20,child: Center(child: Icon(Icons.sort,color: Colors.grey[800],size: _height * 0.04,),),)),
          ),
        ),
        Positioned(                                                           /// Upper Right
          top: 20,right: 10,
          child: Align(
            alignment: Alignment.topRight,
            child: Container(
                padding: EdgeInsets.all(0),
                width: _width * 0.125 + 10,height: _height * 0.1 - 20,
                decoration: BoxDecoration(
                  color: _searchColor,
                  boxShadow: [BoxShadow(color: Colors.transparent,offset: Offset(0,5),spreadRadius: 0.5,blurRadius: 1) ],
                  borderRadius: BorderRadius.circular(_height * 0.05),
                ),
                child: Row(
                  children: [
                    Expanded(child: Container()),
                    InkWell(onTap: (){}, child: Icon(Icons.search,color: Colors.grey[800],size: _height * 0.04,),splashColor: Colors.white,),
                  ],
                )
            ),
          ),
        ),
        AnimatedPositioned(                                                   /// Mid Upper
          duration: Duration(milliseconds: 200),
          top:  0,left: _width * 0.125 + 30,
          child: SafeArea(
            child: Padding(
              padding: EdgeInsets.only(top: 10),
              child: Container(
                width: _width - (_width * 0.3) - 20,height: _height * 0.1,padding: EdgeInsets.symmetric(horizontal: 5),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    TweenAnimationBuilder(
                      duration: Duration(milliseconds: 500),
                      tween: Tween<double>(begin: 0,end: 0),
                      builder: (context,angle,child){
                        return CustomPaint(
                          foregroundPainter: StrokePie(angle,5),
                          child: Container(
                            height: _height * 0.07,width: _height * 0.07,
                            child: Center(child: Text("",style : TextStyle(color: Colors.grey[900],fontSize: _height * 0.02))),
                          ),
                        );
                      },
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: 20 ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Text(".............",style: TextStyle(color: Colors.grey[900],fontSize: 20,fontWeight: FontWeight.bold),),
                          Text("...... / .......",style: TextStyle(color: Colors.grey[900],fontSize:12),),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
        Positioned(                                                         /// Main Container
            top: _height * 0.45,
            child: AnimatedContainer(
              duration: Duration(milliseconds: 500),
              height: _height * 0.55,width: _width,
              decoration: BoxDecoration(
                color: Colors.white,borderRadius: BorderRadius.only(topRight: Radius.circular(30),topLeft: Radius.circular(30)),
                boxShadow: [BoxShadow(color: Colors.grey,blurRadius: 12.5,spreadRadius: 0,offset: Offset(0,0))],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.max,
                children: [
                  Container(height: 10,width: _width,),
                  Container(
                    width: _width - 50,
                    height: 60,
                    //color: Colors.grey,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(child: Text("Internal Storage",style: TextStyle(fontSize: 22,fontWeight: FontWeight.bold),)),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 10),
                          child: Icon(Icons.storage,color: Colors.grey[800],size: 20,),
                        ),
                        InkWell(onTap: (){},child: Icon(Icons.more_vert,color: Colors.grey[800],size: 20,)),
                      ],
                    ),
                  ),
                  Container(
                      width: _width - 50,
                      height: 20,
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: _storageAPI.currentEntityList.length,
                        itemBuilder: (context,index){
                            return _entityCard(_storageAPI.currentEntityList[index], false, index);
                          }
                        ),
                  ),
                ],
              ),
            )
        ),
      ],
    );
  }


  Widget _entityCard(Entity _entity,bool isSelected,int index){

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 30,vertical: 10),
      height: 80,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(color: Colors.yellow,height: 50,width: 60,),
          Expanded(
            child: Container(
                width: _width * 0.7,
                padding: EdgeInsets.only(left: 20),
                height: 50,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(_entity.name,style: TextStyle(fontWeight: FontWeight.bold,fontSize: 17,),overflow: TextOverflow.ellipsis,),
                        Text(_entity.type == EntityType.FILE ? "${entitySizeConversion(_entity.size)}" : "${_entity.childFileQuantity + _entity.childDirQuantity} items |  ${entitySizeConversion(_entity.size)}",style: TextStyle(fontSize: 10),),
                      ],
                    ),
                   Container(),
                  ],
                )
            ),
          ),
        ],
      ),
    );
  }

  String entitySizeConversion(int sizeInBytes){
    if(sizeInBytes < 1000000)
      return "${sizeInBytes/1000} KB";
    else if(sizeInBytes < 1000000000)
      return "${sizeInBytes/1000000} MB";
    else
      return "${sizeInBytes/1000000000} GB";
  }
}
