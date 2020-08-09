import 'dart:async';
import 'dart:io';

import 'package:file_test/DataModel/Entity.dart';
import 'package:flutter/foundation.dart';

class Storage
{
  @protected static String rootDir = "";
  @protected static String currentDir = "";
  static Storage _storageInstance;

  static List<String> _pathStack = [];
  static List<SearchEntity> _searchList = [];

  static StreamController  _streamControllerOfCurrentDirectory = StreamController<List>();
  static Sink currentDirectorySink = _streamControllerOfCurrentDirectory.sink;
  static Stream currentDirectoryStream = _streamControllerOfCurrentDirectory.stream.asBroadcastStream();

  List<String> get pathStack => _pathStack;

  List<SearchEntity> get searchList => _searchList;

  String get rootDirectory => rootDir;

  String get currentDirectory => currentDir;


  set searchList(List<SearchEntity> newSearchList){
    searchList = newSearchList;
  }

  set currentDirectory(String path){
    currentDir = path;
  }

  set rootDirectory(String path){
    rootDir = path;
  }

  factory Storage(){
    if(_storageInstance == null){
      print("Instantiated");
      _storageInstance = Storage._internal();
      _storageInstance.rootDirectory = "/storage/emulated/0";
      Directory(_storageInstance.rootDirectory).list().toList().then((list){currentDirectorySink.add(list);});
      _storageInstance.currentDirectory = _storageInstance.rootDirectory;
      _storageInstance.pathStack.add(_storageInstance.rootDirectory);
    }
    return _storageInstance;
  }

  Storage._internal();
}