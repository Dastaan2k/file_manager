import 'package:file_test/BackEnd/Storage.dart';
import 'package:flutter/cupertino.dart';

class Entity
{
  String name;
  String path;
  EntityType type;
  int size;
  int childDirQuantity;
  int childFileQuantity;

  Entity({@required this.path,this.size = 0,@required this.type,this.childDirQuantity = 0,this.childFileQuantity = 0}){
    name = path.split('/').last;
  }

  void printEntity(){
    print("Entity Details : " + "\nName : $name \nPath : $path \nType : $type \nSize : $size B\nChild Directories : $childDirQuantity \nChild Files : $childFileQuantity");
  }
}

class SearchEntity
{
  String name;
  String path;
  EntityType type;

  SearchEntity({@required this.path,@required this.type}){
    name = path.split('/').last;
  }
}

enum EntityType
{
  FILE,
  DIRECTORY,
}
