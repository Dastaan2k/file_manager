import 'dart:io';
import 'package:file_test/BackEnd/Storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:open_file/open_file.dart';

class FileFunction
{

  Storage _storageAPI = Storage();

  Future<List> getDirectoryContent({@required String directoryPath}){
     return Directory(directoryPath).list().toList();
  }

  Future<dynamic> enterDirectory({@required FileSystemEntity newDirectory}){

    newDirectory.stat().then((fileStat){
      if(fileStat.type == FileSystemEntityType.file){
        OpenFile.open(newDirectory.path);
      }
      else{
        _storageAPI.currentDirectory = newDirectory.path + "/";
        print("Entering Directory : " + newDirectory.path);
        Directory(_storageAPI.currentDirectory).list().toList().then((newList){
          print("Updating Stream");
          Storage.currentDirectorySink.add(newList);
          _storageAPI.pathStack.add(newDirectory.path + "/");
          print("Stream Updated Successfully");
        });
      }
    });
  }

  Future<dynamic> forceRollback({@required String rollbackDirectory}){
    for(int i=_storageAPI.pathStack.length -1;_storageAPI.pathStack[i] != rollbackDirectory;i--){
      print("ip");
      _storageAPI.pathStack.removeAt(i);
    }
    print("Path Stack after removal : " + _storageAPI.pathStack.toString());
    _storageAPI.currentDirectory = rollbackDirectory;
    Directory(rollbackDirectory).list().toList().then((newList){
      print("Updating Stream");
      Storage.currentDirectorySink.add(newList);
      print("Stream Updated Successfully");
    });
  }


  Future<dynamic> copyDirectory({@required FileSystemEntity file,@required String destinationPath}){

    List<String> fileQueue = [];

    return file.stat().then((fileStat){
      if(fileStat.type == FileSystemEntityType.file){
        print("Copying File : $file");
        return File(file.path).copy(destinationPath + file.path.replaceAll(_storageAPI.pathStack.last,"/")).then((value){
          print("File Successfully Copied");
          return "gg";});
      }
      else{
        Directory(file.path).list(recursive: true).listen((event) {
          if(event.runtimeType.toString() == "_File")
            fileQueue.add(event.path);
          else{
            Directory(destinationPath + event.path.replaceAll(_storageAPI.pathStack.last, "")).createSync(recursive: true);
          }
        }).asFuture().then((value){
          print("DIRECTORIES COPIED TO NEW LOCATION");
          print("COPYING FILES TO NEW LOCATION...");
          fileQueue.forEach((filePath) { File(filePath).copy(destinationPath + filePath.replaceAll(_storageAPI.pathStack.last, ""));});
        });
      }
    }).then((value){getDirectoryContent(directoryPath: _storageAPI.pathStack.last).then((list){
      Storage.currentDirectorySink.add(list);
      print("Stream updated Successfully");
      return "gg";
    });});
  }

  Future<FileStat> getDetails({@required FileSystemEntity file}){
    return file.stat().then((fileStat){
      if(fileStat.type == FileSystemEntityType.file)
        return File(file.path).stat().then((value) => value);
      else
        return Directory(file.path).stat().then((value) => value);
    });
  }

  Future<dynamic> moveDirectory({@required FileSystemEntity file,@required String destinationPath}){

    List<String> fileQueue = [];

    return file.stat().then((fileStat){
      if(fileStat.type == FileSystemEntityType.file){
        print("\nCopying File  $file");
        return File(file.path).copy(destinationPath + file.path.replaceAll(_storageAPI.pathStack.last,"")).then((value){
          print("File copied to destination successfully");
          File(file.path).delete().then((value){print("Old link deleted Successfully"); return "gg";});
        });
        }
      else{
        Directory(file.path).list(recursive: true).listen((event) {
          if(event.runtimeType.toString() == "_File")
            fileQueue.add(event.path);
          else{
            Directory(destinationPath + event.path.replaceAll(_storageAPI.pathStack.last, "")).createSync(recursive: true);
          }
        }).asFuture().then((value){
          print("DIRECTORIES COPIED TO NEW LOCATION");
          print("COPYING FILES TO NEW LOCATION...");
          fileQueue.forEach((filePath) { File(filePath).copy(destinationPath + filePath.replaceAll(_storageAPI.pathStack.last, ""));});
        }).then((value){Directory(file.path).delete(recursive: true).then((value){return "gg";});});
      }
    }).then((value){
      getDirectoryContent(directoryPath: _storageAPI.pathStack.last).then((list){
        Storage.currentDirectorySink.add(list);
        print("Stream updated Successfully");
        return "gg";
      });
    });
  }

  Future<dynamic> createDirectory({@required String newDirectoryName}){
    String temp = newDirectoryName.isEmpty ? "_" : newDirectoryName;
    return Directory(_storageAPI.pathStack.last + temp).create().then((value){
          print("File Created Successfully");
          print("Updating Stream");
          getDirectoryContent(directoryPath: _storageAPI.pathStack.last).then((list){
            Storage.currentDirectorySink.add(list);
            print("Stream updated Successfully");
            return "gg";
          });
        }
    );
  }

  Future<dynamic> renameDirectory(FileSystemEntity oldDirectory,String newName){

    String temp = newName.isEmpty ? "_" : newName;
    print("Extension in new name : ${oldDirectory.path.split('.').last}");
    String extension = oldDirectory.path.split('.').last.length == 0 ? "" : "." + oldDirectory.path.split('.').last;

    return oldDirectory.stat().then((fileStat){
      if(fileStat.type == FileSystemEntityType.file){
        return File(oldDirectory.path).rename(_storageAPI.pathStack.last + temp +  extension).then((value){
          print("Rename Successful");
          print("Updating Stream");
          getDirectoryContent(directoryPath: _storageAPI.pathStack.last).then((list){
            Storage.currentDirectorySink.add(list);
            print("Stream Updated Successfully");
            return "gg";
          });
        });
      }
      else{
        return Directory(oldDirectory.path).rename(_storageAPI.pathStack.last + temp).then((value){
          print("Rename Successful");
          print("Updating Stream");
          getDirectoryContent(directoryPath: _storageAPI.pathStack.last).then((list){
            Storage.currentDirectorySink.add(list);
            print("Stream Updated Successfully");
            return ;
          });
        });
      }
    }).then((value) => "gg");
  }

  Future<dynamic> exitDirectory(BuildContext context){

    if(_storageAPI.pathStack.length == 1)
      SystemNavigator.pop();
    else {
      print("Exiting Directory");
      _storageAPI.pathStack.removeLast();
      _storageAPI.currentDirectory = _storageAPI.pathStack.last;
      print("Updating String");
      Directory(_storageAPI.pathStack.last).list().toList().then((previousList){
        Storage.currentDirectorySink.add(previousList);
      });
    }
  }

  Future<dynamic> deleteDirectory({@required FileSystemEntity directory}) {
    return directory.stat().then((fileStat) {
      if(fileStat.type == FileSystemEntityType.file){
        return File(directory.path).delete(recursive: true).then((value){  /// value container the deleted directory(recursive form) ....... storing it in cache can be useful for 'undo delete' operation but can be memory ineffecient ...... (We can do something like save if file size is below specific value or can cache the compressed form of file)
          print("Delete Process Completed");
          getDirectoryContent(directoryPath: _storageAPI.currentDirectory).then((newList){
            print("Updating Stream ....");
            Storage.currentDirectorySink.add(newList);
            print("Stream Updated Successfully");
            return "gg";
          });
        });
      }
      else{
        return Directory(directory.path).delete(recursive: true).then((value){  /// value container the deleted directory(recursive form) ....... storing it in cache can be useful for 'undo delete' operation but can be memory ineffecient ...... (We can do something like save if file size is below specific value or can cache the compressed form of file)
          print("Delete Process Completed");
          getDirectoryContent(directoryPath: _storageAPI.currentDirectory).then((newList){
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