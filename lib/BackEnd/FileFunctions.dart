import 'dart:io';
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


  Future<dynamic> enterDirectory({@required FileSystemEntity newDirectory}) {
    newDirectory.stat().then((fileStat) {
      if (fileStat.type == FileSystemEntityType.file) {
        OpenFile.open(newDirectory.path);
      }
      else {
        _storageAPI.currentDirectory = newDirectory.path;
        print("Entering Directory : " + newDirectory.path);
        Directory(_storageAPI.currentDirectory).list().toList().then((newList) {
          print("Updating Stream");
          Storage.currentDirectorySink.add(newList);
          _storageAPI.pathStack.add(newDirectory.path);
          print("Stream Updated Successfully");
        });
      }
    });
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

  Future<dynamic> forceRollback({@required String rollbackDirectory}) {
    for (int i = _storageAPI.pathStack.length - 1; _storageAPI.pathStack[i] != rollbackDirectory; i--) {
      _storageAPI.pathStack.removeAt(i);
    }
    print("Path Stack after removal : " + _storageAPI.pathStack.toString());
    _storageAPI.currentDirectory = rollbackDirectory;
    Directory(rollbackDirectory).list().toList().then((newList) {
      print("Updating Stream");
      Storage.currentDirectorySink.add(newList);
      print("Stream Updated Successfully");
    });
  }

  Future<int> _getSize(FileSystemEntity entity){

    int size = 0;
    List<Future> statAsyncList = [];

    if(entity.runtimeType.toString() == "_Directory"){
      return Directory(entity.path).list(recursive: true).toList().then((entityList){
        entityList.forEach((entity) {
          statAsyncList.add(entity.stat().then((entityStat){size += entityStat.size;}));
        });
        size += 4096;
        return Future.wait(statAsyncList).then((value){return size;});
      });
    }
    else{
      return File(entity.path).stat().then((fileStat){return fileStat.size;});
    }
  }

  Future<Entity> getEntityDetails(FileSystemEntity entity){

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


  void sortDirectory(Directory dir,String query,String order){

    List<Future> getSizeofEachChild = [];
    List<Entity> tempEntityList = [];

      dir.list(recursive: false).toList().then((entityList){
        entityList.forEach((entity) {
          if(entity.runtimeType.toString() == "_Directory"){
            getSizeofEachChild.add(_getSize(Directory(entity.path)).then((size){tempEntityList.add(Entity(path: entity.path,size: size,type: EntityType.DIRECTORY));}));
          }
          else{
            print("File : ");
            getSizeofEachChild.add(File(entity.path).stat().then((fileStat){tempEntityList.add(Entity(path: entity.path,size: fileStat.size,type: EntityType.FILE));}));
          }
        });
        Future.wait(getSizeofEachChild).then((value){

          List temp = [];

          if(query == "SIZE")
            tempEntityList.sort((a,b) => order == "ASC" ? a.size.compareTo(b.size) : -a.size.compareTo(b.size));
          if(query == "NAME")
            tempEntityList.sort((a,b) => order == "ASC" ? a.name.compareTo(b.name) : -a.name.compareTo(b.name));

          print("THIS : ");
          tempEntityList.forEach((element) {
            print(element.name + " : " + element.size.toString());
            if(element.type == EntityType.FILE)
              temp.add(File(element.path) );
            else
              temp.add(Directory(element.path));
          });
          Storage.currentDirectorySink.add(temp);
        });
      });
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

  Future<String> copyEntity({@required FileSystemEntity entity, @required String destinationPath}){

    print("\n\n");
    List<Future> fileCopyTask = [];
    List<Future> directoryCopyTask = [];

    print("To be copied : " + entity.path);

    if(entity.runtimeType.toString() == "_Directory"){

      print("Its a Directory");

      directoryCopyTask.add(Directory(destinationPath + entity.path.replaceAll(_storageAPI.pathStack.last, "")).create().then((value){print("Directory ${destinationPath + entity.path.replaceAll(_storageAPI.pathStack.last, "")} created.");}));
      return Directory(entity.path).list(recursive: true).listen((_entity) {
        if(_entity.runtimeType.toString() == "_Directory"){
          print("Collecting Directory : ${_entity.path}");
          directoryCopyTask.add(Directory(destinationPath + _entity.path.replaceAll(_storageAPI.pathStack.last, "")).create(recursive: true).then((value){print("Directory ${destinationPath + _entity.path.replaceAll(_storageAPI.pathStack.last, "")} created.");}));
        }
        else{
          print("Collecting File : ${_entity.path}");
          fileCopyTask.add(File(_entity.path).copy(destinationPath + _entity.path.replaceAll(_storageAPI.pathStack.last, "")).then((value){print("File ${_entity.path.split('/').last} copied successfully at ${destinationPath + _entity.path.replaceAll(_storageAPI.pathStack.last, "")}");}));
        }
      }).asFuture(1).then((value){
        print("EntityCollection Complete !!!!!");
        return Future.wait(directoryCopyTask).then((value){
          return Future.wait(fileCopyTask).then((value){print("Copy Complete");return "Complete";});
        });
       // return 1;
      });
    }
    else{
      print("Copying file ${entity.path} to  $destinationPath ....");
      return File(entity.path).copy(destinationPath + entity.path.replaceAll(_storageAPI.pathStack.last, '')).then((value){
        print("File Copied File Successfully");
        return "Complete";
      });
    }
  }

  Future<String> moveEntity({@required FileSystemEntity entity,@required String destinationPath}){
    return copyEntity(entity: entity, destinationPath: destinationPath).then((value){
      return deleteDirectory(directory: entity).then((value){return "Complete";});
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


    Future<dynamic> createDirectory({@required String newDirectoryName}) {
      String temp = newDirectoryName.isEmpty ? "_" : newDirectoryName;
      return Directory(_storageAPI.pathStack.last + temp).create().then((value) {
        print("New Dir : " + _storageAPI.pathStack.last + temp);
        print("File Created Successfully");
        print("Updating Stream");
        getDirectoryContent(directoryPath: _storageAPI.pathStack.last).then((
            list) {
          Storage.currentDirectorySink.add(list);
          print("Stream updated Successfully");
          return "gg";
        });
      }
      );
    }

    Future<dynamic> renameDirectory(FileSystemEntity oldDirectory,
        String newName) {
      String temp = newName.isEmpty ? "_" : newName;
      String extension = oldDirectory.path.contains(".") ? oldDirectory.path
          .split('.')
          .last
          .length == 0 ? "" : "." + oldDirectory.path
          .split('.')
          .last : " ";
      print("Extension : " + extension);
      print("Temp : " + temp);

      return oldDirectory.stat().then((fileStat) {
        if (fileStat.type == FileSystemEntityType.file) {
          return File(oldDirectory.path).rename(
              _storageAPI.pathStack.last + "/" + temp + extension).then((
              value) {
            print("Rename Successful");
            print("Updating Stream");
            getDirectoryContent(directoryPath: _storageAPI.pathStack.last)
                .then((list) {
              Storage.currentDirectorySink.add(list);
              print("Stream Updated Successfully");
              return "gg";
            });
          });
        }
        else {
          return Directory(oldDirectory.path).rename(
              _storageAPI.pathStack.last + "/" + temp).then((value) {
            print("Rename Successful");
            print("Updating Stream");
            getDirectoryContent(directoryPath: _storageAPI.pathStack.last)
                .then((list) {
              Storage.currentDirectorySink.add(list);
              print("Stream Updated Successfully");
              return;
            });
          });
        }
      }).then((value) => "gg");
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

    Future<dynamic> deleteDirectory({@required FileSystemEntity directory}) {
      return directory.stat().then((fileStat) {
        if (fileStat.type == FileSystemEntityType.file) {
          return File(directory.path).delete(recursive: true).then((value) {
            /// value container the deleted directory(recursive form) ....... storing it in cache can be useful for 'undo delete' operation but can be memory ineffecient ...... (We can do something like save if file size is below specific value or can cache the compressed form of file)
            print("Delete Process Completed");
            getDirectoryContent(directoryPath: _storageAPI.currentDirectory)
                .then((newList) {
              print("Updating Stream ....");
              Storage.currentDirectorySink.add(newList);
              print("Stream Updated Successfully");
              return "gg";
            });
          });
        }
        else {
          return Directory(directory.path).delete(recursive: true).then((
              value) {
            /// value container the deleted directory(recursive form) ....... storing it in cache can be useful for 'undo delete' operation but can be memory ineffecient ...... (We can do something like save if file size is below specific value or can cache the compressed form of file)
            print("Delete Process Completed");
            getDirectoryContent(directoryPath: _storageAPI.currentDirectory)
                .then((newList) {
              print("Updating Stream ....");
              Storage.currentDirectorySink.add(newList);
              print("Stream Updated Successfully");
              return "gg";
            });
          });
        }
      });
    }
  }