import 'dart:async';
import 'dart:io';

import 'package:file_test/BackEnd/FileFunctions.dart';
import 'package:file_test/DataModel/Entity.dart';
import 'package:flutter/foundation.dart';

class Storage
{
  @protected static String rootDir = "";
  @protected static String currentDir = "";
  static Storage _storageInstance;

  static bool lock = false;
  static bool generalPageInitToggle = true;
  static bool showLogger;
  static bool isDashboardDataInitialised = false;
  static bool liquidSwipeToggleLock = true;

  static double totalInternalStorage = 0;
  static double freeInternalStorage = 0;

  static double videoPercent = 20;
  static double audioPercent = 20;
  static double documentPercent = 25;
  static double imagePercent = 15;
  
  static int videoStorageSpaceBytes = 0;
  static int imageStorageSpaceBytes = 0;
  static int documentStorageSpaceBytes = 0;
  static int audioStorageSpaceBytes = 0;
  static int zipStorageSpaceBytes = 0;
  static int miscStorageSpaceBytes = 0;
  static int exeStorageSpaceBytes = 0;
  static int downloadStorageSpaceBytes = 0;

  static List<List> fileByteList = [];
  static List<String> _pathStack = [];
  static List<SearchEntity> _searchList = [];
  static List<Entity> _currentEntityList = [];
  static List<bool> isSelectedList = [];
  static List<String> log = [];


  static StreamController _streamControllerOfCurrentDirectory = StreamController<List>();
  static Sink currentDirectorySink = _streamControllerOfCurrentDirectory.sink;
  static Stream currentDirectoryStream = _streamControllerOfCurrentDirectory.stream.asBroadcastStream();
  static StreamController logStreamController = StreamController<String>();

  List<Entity> get currentEntityList => _currentEntityList;

  List<String> get pathStack => _pathStack;

  List<SearchEntity> get searchList => _searchList;

  String get rootDirectory => rootDir;

  String get currentDirectory => currentDir;

  set currentEntityList(List<Entity> entityList){
    _currentEntityList = entityList;
  }


  void resetDashboardData(){

    videoStorageSpaceBytes = 0;
    imageStorageSpaceBytes = 0;
    documentStorageSpaceBytes = 0;
    audioStorageSpaceBytes = 0;
    zipStorageSpaceBytes = 0;
    miscStorageSpaceBytes = 0;
    exeStorageSpaceBytes = 0;
    downloadStorageSpaceBytes = 0;
  }

  set searchList(List<SearchEntity> newSearchList){
    searchList = newSearchList;
  }

  set currentDirectory(String path){
    currentDir = path;
  }

  set rootDirectory(String path){
    rootDir = path;
  }

  factory Storage({bool showLog = true}){

    if(_storageInstance == null){
      print("Instantiated");
      _storageInstance = Storage._internal();
      showLogger = showLog;
      _storageInstance.rootDirectory = "/storage/emulated/0";
      FileFunction().enterEntity(entity: Entity(path: _storageInstance.rootDirectory,type: EntityType.DIRECTORY));
      _storageInstance.currentDirectory = _storageInstance.rootDirectory;
    }
    return _storageInstance;
  }

  Storage._internal();
}