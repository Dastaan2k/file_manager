import 'dart:io';

import 'package:file_test/BackEnd/Storage.dart';
import 'package:file_test/DataModel/Entity.dart';
import 'package:flutter/cupertino.dart';

class CleanerFunction{

  static bool checkFileDuplicacy(List byteList1,List byteList2){

    List<Future> futureList = [];
    double similarityPercent = 0;
    double similarByteCount = 0;

    if(byteList1.length == byteList2.length){
      for(int i=0;i<byteList1.length;i++){
        if(byteList1[i] == byteList2[i])
          similarByteCount++;
      }
      return similarByteCount == byteList1.length ? true : false;
    }
    else{
      return false;
    }
  }


  static Future<CleanupResult> duplicacyCheckModerateFiles(int val){                  /// Android Folder not included yet.

    List<Entity> fileList = [];
    List<Future> tempTaskListPrim = [];
    int tempSize = 0;
    int fileWithDuplicates = 0;
    int duplicateFileCount = 0;

    return Directory('/storage/emulated/0').list(recursive: true).listen((entity){
      if(entity.path.contains('/storage/emulated/0/Android') == false){
        if(entity.runtimeType.toString() == "_File"){
          tempSize = entity.statSync().size;
          if(tempSize <= 62500000){
            fileList.add(Entity(type: EntityType.FILE,path: entity.path,size: tempSize));
            tempTaskListPrim.add(File(entity.path).readAsBytes().then((byteList){Storage.fileByteList.add(byteList);}));
          }
        }
      }
    }).asFuture(1).then((value){
      return CleanupResult(duplicatedFileFound: 1, data: {"a" :  "b"});
      return Future.wait(tempTaskListPrim).then((value){
        print("Storage List : ${Storage.fileByteList.length}");
        for(int i=0;i<(Storage.fileByteList).length;i++){
          duplicateFileCount = 0;
          for(int j = 0;j<(Storage.fileByteList).length;j++){
              if((CleanerFunction.checkFileDuplicacy((Storage.fileByteList)[i],(Storage.fileByteList)[j]) == true)){
                duplicateFileCount++;
              }
          }
        }
        print("Process Complete");
        return CleanupResult(duplicatedFileFound: duplicateFileCount, data: {"Name" : "Hello World"});
      });
    });
  }
}


class CleanupResult{

  int duplicatedFileFound;
  Map<String,dynamic> data;

  CleanupResult({@required this.duplicatedFileFound,@required this.data});

}