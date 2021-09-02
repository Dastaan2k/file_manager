import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'package:file_test/BackEnd/Storage.dart';
import 'package:file_test/DataModel/Entity.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:open_file/open_file.dart';

class FileFunction {

  Storage _storageAPI = Storage();

  Future<List> getDirectoryContent({@required String directoryPath}) {
    return Directory(directoryPath).list().toList();
  }




  /// todo : Add the whole entity instead of just adding the paths in pathStack


  Future<void> _future(){                   /// Test Function ..... not used in app

    Stopwatch a = Stopwatch();
    List<Future> futureList = [];

    a.start();

      futureList.add(Future.delayed(Duration(seconds : 5)).then((value){print("Future 1 completed on ${a.elapsedMilliseconds}");return Future.delayed(Duration(seconds: 3)).then((value){print("Then Callback of Future 1 : ${a.elapsedMilliseconds}");});}));
    futureList.add(Future.delayed(Duration(seconds : 3)).then((value){print("Future 2 completed on ${a.elapsedMilliseconds}");return Future.delayed(Duration(seconds: 3)).then((value){print("Then Callback of Future 2 : ${a.elapsedMilliseconds}");});}));
    futureList.add(Future.delayed(Duration(seconds : 10)).then((value){print("Future 3 completed on ${a.elapsedMilliseconds}");return Future.delayed(Duration(seconds: 7)).then((value){print("Then Callback of Future 3 : ${a.elapsedMilliseconds}");});}));
    futureList.add(Future.delayed(Duration(seconds : 1)).then((value){print("Future 4 completed on ${a.elapsedMilliseconds}");return Future.delayed(Duration(seconds: 15)).then((value){print("Then Callback of Future 4 : ${a.elapsedMilliseconds}");});}));
    futureList.add(Future.delayed(Duration(seconds : 7)).then((value){print("Future 5 completed on ${a.elapsedMilliseconds}");return Future.delayed(Duration(seconds: 1)).then((value){print("Then Callback of Future 5 : ${a.elapsedMilliseconds}");});}));

    Future.sync(() => null);

    Future.forEach(futureList,(Future val){

      /// This callback is called on end of each future
      ///
      /// forEach is just for easing the code nothing else ........ below function does the same work as above function.
      /// But the catch is if you will return another future ... like did above (returned another future.delayed ..... then the below callback will directory return the value of the seocnd future
      ///
      /// eg : in first future the first child ends on 5s and second on 3s ..... now if your return that future ...(like did above ..... in forEch the result will be acquired after 8s (5s + 3s) meaning it directly gives the final result 

      int x = Random().nextInt(1000);
      print("Future $x started on ${a.elapsedMilliseconds}");
      val.then((value){
        print("Future $x ended on ${a.elapsedMilliseconds}");
      });
    });
  }




  void enterEntity({@required Entity entity,bool isForceRollback = false}){

    /// todo : Needs Improvement
    ///
    /// IMPROVEMENTS :
    /// 2) Move the selectedList to Storage.
    /// 3) Instead of re-building the page every time we can cache some data ..... eg : As we are collecting the detailed data every time we open a a directory ... we can cache the data and re use it force rollback or other functions ...... It will only update is a copy or delete or any other function like that is called before .... Or maybe come up with a way where that might not even be necessary

    print("Entering Directory : ${entity.path}");

    List<Stream> entityList = [];
    List<Future> asyncFutureList = [];
    List<Entity> finalEntityList = [];

    if(entity.type == EntityType.FILE){
        OpenFile.open(entity.path);
    }
    else {
      //_storageAPI.currentEntityList = [];

      int parentPathElementLength = entity.path.split('/').length;

        Directory(entity.path).list(recursive: false).listen((entity) {
          StreamController temp = StreamController();
          if(entity.runtimeType.toString() == "_File"){
            Entity file = Entity(path: entity.path,type: EntityType.FILE,size: entity.statSync().size,);
           // _storageAPI.currentEntityList.add(file);
            temp.add(file);
            entityList.add(temp.stream.asBroadcastStream());
            temp.close();
            finalEntityList.add(file);
            print("File Added to entity List");
          }
          else{
            Entity dir = Entity(path: entity.path,type: EntityType.DIRECTORY);
            temp.add(dir);
            //_storageAPI.currentEntityList[index] = dir;
            entityList.add(temp.stream.asBroadcastStream());
            asyncFutureList.add(Directory(entity.path).list(recursive: true).listen((_childEntity) {
              if(_childEntity.path.split('/').length == (parentPathElementLength + 2)){
                if(_childEntity.runtimeType.toString() == "_Directory")
                  dir.childDirQuantity++;
                else
                  dir.childFileQuantity++;
              }
              dir.size += _childEntity.statSync().size;
              //_storageAPI.currentEntityList.add(dir);
              temp.add(dir);
            }).asFuture(1).then((value){
              finalEntityList.add(dir);
              temp.close();
            }));
          }
        }).asFuture(1).then((value){
            print("Updating stream");
            Storage.currentDirectorySink.add(entityList);
            if(isForceRollback == false)
              _storageAPI.pathStack.add(entity.path);
            Storage.isSelectedList = [];
            Future.wait(asyncFutureList).then((value){
              _storageAPI.currentEntityList = finalEntityList;
            });
        });
    }
  }





  String entitySizeConversion(int sizeInBytes){
    if(sizeInBytes < 1000000)
      return "${roundToTwoPlaces(sizeInBytes/1000)} KB";
    else if(sizeInBytes < 1000000000)
      return "${roundToTwoPlaces(sizeInBytes/1000000)} MB";
    else
      return "${roundToTwoPlaces(sizeInBytes/1000000000)} GB";
  }


  double roundToTwoPlaces(double num){
    int x = (num * 100).round();
    return x/100;
  }

  List searchForPattern(String pattern){

    List temp = [];

    if(pattern != ""){
      _storageAPI.searchList.forEach((searchEntity) {
        if(searchEntity.name.contains(pattern)){
          temp.add(searchEntity);
        }
      });
    }
    return temp;
  }

  Future<List<SearchEntity>> buildSearchList(){
    if(_storageAPI.searchList.isEmpty){
      print("New List");
      return Directory(_storageAPI.rootDirectory).list(recursive: true).toList().then((entityList){
        entityList.map((entity){
          if(!entity.path.contains('/storage/emulated/0/Android'))
            _storageAPI.searchList.add(SearchEntity(path: entity.path,type: entity.runtimeType.toString() == "_Directory" ? EntityType.DIRECTORY : EntityType.FILE));
        }).toList();
        return _storageAPI.searchList;
      });
    }
    else{
      print("Reused");
      return Future.value(_storageAPI.searchList);
    }
  }



  List getSearchResultFor(String pattern){
    if(pattern == ""){
      return [];
    }
    else{
      List<SearchEntity> temp = [];

      _storageAPI.searchList.forEach((searchEntity) {
        if(searchEntity.name.contains(pattern))
          temp.add(searchEntity);
      });
      return temp;
    }
  }



  void forceRollback({@required String rollbackDirectory}) {
    for (int i = _storageAPI.pathStack.length - 1; _storageAPI.pathStack[i] != rollbackDirectory; i--) {
      _storageAPI.pathStack.removeAt(i);
    }
    print("Path Stack after removal : " + _storageAPI.pathStack.toString());
    _storageAPI.currentDirectory = rollbackDirectory;
    enterEntity(entity: Entity(path: rollbackDirectory,type: EntityType.DIRECTORY),isForceRollback: true);
  }



  void sortDirectory({@required String query,@required String order}){

    List<Stream> entityList = [];
    List<Entity> tempEntityList = _storageAPI.currentEntityList;

    if(query == "SIZE")
      tempEntityList.sort((a,b) => order == "ASC" ? a.size.compareTo(b.size) : -a.size.compareTo(b.size));
    if(query == "NAME")
      tempEntityList.sort((a,b) => order == "ASC" ? a.name.compareTo(b.name) : -a.name.compareTo(b.name));

    tempEntityList.forEach((entity) {
      StreamController temp = StreamController();

      temp.add(entity);
      entityList.add(temp.stream.asBroadcastStream());
      temp.close();
    });

    Storage.currentDirectorySink.add(entityList);
  }



  Future<dynamic> copySelectedEntityList(List<Entity> entityList,String newPath,{bool isUsedasChildMethod = false}){

    List<Future> parentProcessList = [];

    entityList.forEach((entity) {
      if(entity.type == EntityType.FILE){
        print("Copying File ${entity.name} to $newPath");
        parentProcessList.add(File(entity.path).copy(newPath + entity.path.replaceAll(_storageAPI.pathStack.last, '')).then((value){print("File ${entity.name} Copied Successfully.");}));
      }
      else{
        List<Future> primaryProcessList = [];
        List<Future> secondaryProcessList = [];

        Directory(newPath + '/' + entity.name).createSync();
        print(newPath + '/' + entity.name + "created");

        parentProcessList.add(Directory(entity.path).list(recursive: true).listen((childEntity) {
          if(childEntity.runtimeType.toString() == "_Directory"){
            primaryProcessList.add(Directory(newPath + childEntity.path.replaceAll(_storageAPI.pathStack.last, '')).create(recursive: false).then((value){print("Directory ${newPath + childEntity.path.replaceAll(_storageAPI.pathStack.last, '')} created");return 1;}));
          }
          else{
            print("Copying File ${entity.path.split('/').last} ...");
            secondaryProcessList.add(File(childEntity.path).copy(newPath + childEntity.path.replaceAll(_storageAPI.pathStack.last, '')).then((value){print("File ${childEntity.path.split('/').last} copied to new Path  ${newPath + childEntity.path.replaceAll(_storageAPI.pathStack.last, '')}");return 1;}));
          }
        }).asFuture(1).then((value){
          return Future.wait(primaryProcessList).then((value){
            print("All Directories created");
            return Future.wait(secondaryProcessList).then((value){
              print("All Root files copied");
            });
          });
        }));
      }
    });
    return Future.wait(parentProcessList).then((value){
      print("COPY PROCESS COMPLETE");
      if(!isUsedasChildMethod)
          enterEntity(entity: Entity(path: _storageAPI.pathStack.last,type: EntityType.DIRECTORY),isForceRollback: true);
      return 'Success';
    });
  }


  Future<dynamic> moveSelectedEntityList(List<Entity> entityList,String newPath){
    return copySelectedEntityList(entityList, newPath,isUsedasChildMethod: true).then((value){
      return deleteSelectedEntityList(entityList,isUsedasChildMethod: true).then((value){
        enterEntity(entity: Entity(path: _storageAPI.pathStack.last,type: EntityType.DIRECTORY),isForceRollback: true);
      });
    });
  }


  Future<dynamic> deleteSelectedEntityList(List<Entity> entityList,{bool isUsedasChildMethod = false}){

    List<Future> parentProcessList = [];

    print("${entityList.length} Entities to be Deleted ....");

    entityList.forEach((entity) {

      if(entity.type == EntityType.FILE){
        print("\t\t Deleting File ${entity.name} .....");
        parentProcessList.add(File(entity.path).delete().then((value){print("\t\t File ${entity.name} deleted SuccessFully");}));
      }
      else{

        List<Future> primaryChildProcessList = [];
        List<Future> secondaryChildProcessList = [];

        print("\t\t Deleting Directory ${entity.name} ....");
          parentProcessList.add(Directory(entity.path).list(recursive: false).listen((childEntity) {
            if(childEntity.runtimeType.toString() == "_File"){
              print("\t\t\t\t Deleting Child File ${childEntity.path.split('/').last} .....");
              primaryChildProcessList.add(childEntity.delete(recursive: false).then((value){print("\t\t\t\t Child File ${childEntity.path.split('/').last} deleted Successfully");}));
            }
            else{
              print("\t\t\t\t Deleting Child Directory ${childEntity.path.split('/').last} .....");
              secondaryChildProcessList.add(childEntity.delete(recursive: true).then((value){print("\t\t\t\t Child Directory ${childEntity.path.split('/').last} deleted Successfully");}));
            }
          }).asFuture(1).then((value){
            return Future.wait(primaryChildProcessList).then((value){
              print("Primary Process Complete");
              return Future.wait(secondaryChildProcessList).then((value){
                print("Secondary Process Complete");
                Directory(entity.path).delete();
                print("\t\t Directory ${entity.name} Deleted Successfully");
              });
            });
          }));
      }
    });

    return Future.wait(parentProcessList).then((value){
      print("SAB KUCH HO GAYA DELETE ");
      if(!isUsedasChildMethod)
        enterEntity(entity: Entity(path: _storageAPI.pathStack.last,type: EntityType.DIRECTORY),isForceRollback: true);
      return "Success";
    });

  }

  Future<dynamic> renameEntity({@required Entity entity,@required String newName}){
    if(entity.type == EntityType.FILE){
      return File(entity.path).rename(_storageAPI.pathStack.last + "/" +  newName).then((value){enterEntity(entity: Entity(path: _storageAPI.pathStack.last,type: EntityType.DIRECTORY),isForceRollback: true);return "Success";});
    }
    else{
      return Directory(entity.path).rename(_storageAPI.pathStack.last + "/" + newName).then((value){enterEntity(entity: Entity(path: _storageAPI.pathStack.last,type: EntityType.DIRECTORY),isForceRollback: true);return "Success";});
    }
  }


  Future<dynamic> createEntity({@required String name,@required EntityType entityType}){
    if(entityType == EntityType.DIRECTORY){
      return Directory(_storageAPI.pathStack.last + '/' + name).create().then((value){
        enterEntity(entity: Entity(path: _storageAPI.pathStack.last,type: EntityType.DIRECTORY),isForceRollback: true);
      });
    }
    else{
      return File(_storageAPI.pathStack.last + '/' + name).create().then((value){
        enterEntity(entity: Entity(path: _storageAPI.pathStack.last,type: EntityType.DIRECTORY),isForceRollback: true);
      });
    }
  }



  Future<Entity> getEntityDetails(FileSystemEntity entity){    /// Check this once before using it for cleanup function

    List<Future> asyncTaskList = [];
    int dirNum = 0;
    int fileNum = 0;
    int size = 0;

    Entity res = Entity(path: entity.path,type: entity.runtimeType.toString() == "_Directory" ? EntityType.DIRECTORY : EntityType.FILE);

    if(entity.runtimeType.toString() == "_Directory"){
      return Directory(entity.path).list(recursive: true).listen((entity) {
        asyncTaskList.add(entity.stat().then((entityStat){
          if(entityStat.type == FileSystemEntityType.file)
            fileNum++;
          else
            dirNum++;
          size += entityStat.size;
        }));
      }).asFuture().then((value){print("Stream complete");return Future.wait(asyncTaskList).then((value){res.childFileQuantity = fileNum; res.childDirQuantity = dirNum;res.size = size;return res;});});
    }
    else{
      res.childFileQuantity = 1;
      res.childDirQuantity = 0;
      res.size += entity.statSync().size;

      return Future.value(res);
    }
  }




  Future<dynamic> fileDetailsA({@required FileSystemEntity file}) {
    return file.stat().then((fileStat){

      print("Process Started");
      if (fileStat.type == FileSystemEntityType.directory) {
        print("It is a directory");
        int dirNum = 0;
        int fileNum = 0;
        int totalSize = 0;
        Directory(file.path).list(recursive: true).listen((event) {
          print("Checking ${event.path}");
          if (event.runtimeType.toString() == "_Directory")
            dirNum++;
          else
            fileNum++;
          file.stat().then((individualFileStat) {
            totalSize += individualFileStat.size;
          });
        }).onDone(() {
          print("Eval Complete !!!");
          print("File Num : $fileNum");
          print("Dir Num : $dirNum");
          print("Total Size : $totalSize");
          return "Complete";
        });
      }
      else {
        print("It is a file");
        print("Eval Complete !!!!");
        print("File Num :  1");
        print("Dir Num : 0");
        print('File Size : ${fileStat.size}');
        return "Complete";
      }
    });
  }



  Future<FileStat> getDetails({@required FileSystemEntity file}) {
    return file.stat().then((fileStat) {
      if (fileStat.type == FileSystemEntityType.file)
        return File(file.path).stat().then((value) => value);
      else
        return Directory(file.path).stat().then((value) => value);
    });
  }

    Future<dynamic> exitDirectory(BuildContext context) {
      if (_storageAPI.pathStack.length == 1)
        SystemNavigator.pop();
      else {
        print("Exiting Directory");
        _storageAPI.pathStack.removeLast();
        _storageAPI.currentDirectory = _storageAPI.pathStack.last;
        print("Updating String");
        Directory(_storageAPI.pathStack.last).list().toList().then((
            previousList) {
          Storage.currentDirectorySink.add(previousList);
        });
      }
    }

  }