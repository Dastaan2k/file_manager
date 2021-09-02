import 'dart:io';
import 'dart:math';

import 'package:device_info/device_info.dart';
import 'package:disk_space/disk_space.dart';
import 'package:file_test/BackEnd/FileFunctions.dart';
import 'package:file_test/BackEnd/Storage.dart';
import 'package:file_test/Misc/CustomColors.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider_ex/path_provider_ex.dart';
import 'package:system_info/system_info.dart';

class DashBoard extends StatefulWidget {
  @override
  _DashBoardState createState() => _DashBoardState();
}

class _DashBoardState extends State<DashBoard> with TickerProviderStateMixin{

  double _width;
  double _height;

  bool _isAppBarExpanded = true;

  ScrollController _scrollController = ScrollController(keepScrollOffset: true);

  FileFunction _fileFunction = FileFunction();

  AnimationController _animationController;
  Animation _animation;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    //PathProviderEx.getStorageInfo().then((value){print("Space : " + value[1].availableBytes.toString());});
    _animationController = AnimationController(lowerBound: 0.0,upperBound: 1.0,duration: Duration(milliseconds: 200),reverseDuration: Duration(milliseconds: 200),vsync :this);
    _animation = CurvedAnimation(
      curve: Curves.ease,
      parent: _animationController,
      reverseCurve: Curves.ease,
    );
    _scrollController.addListener(_scrollListener);
  }

  @override
  Widget build(BuildContext context) {

    _width = MediaQuery.of(context).size.width;
    _height = MediaQuery.of(context).size.height;

    return Material(
      child: SafeArea(
        child: FutureBuilder(
          future: Storage.isDashboardDataInitialised ? Future.value(1).then((value){print("Reused");}) : initializeDashboardData(),
          initialData: (){
            return Container(child: Center(child: Text("Fetching Data"),),);
          },
          builder: (context, snapshot) {

            print("Data : " + snapshot.data.toString());

            return Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              color: Colors.white,
              child: Column(
                mainAxisSize: MainAxisSize.max,
                children: [
                  AnimatedBuilder(
                    animation: _animation,
                    builder: (context,child){
                      return ClipPath(
                        clipper: DashBoardAppBarClipper(_animation.value),
                        child: AnimatedContainer(
                          duration: Duration(milliseconds: 200),
                          padding: EdgeInsets.all(20),
                          width: _width,height: _isAppBarExpanded ? _height * 0.3 : _height * 0.1,
                          decoration: BoxDecoration(color: _isAppBarExpanded ? Colors.greenAccent : Colors.grey[200]),
                          child: Align(
                            alignment: Alignment.topLeft,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.start,
                              mainAxisSize: MainAxisSize.max,
                              children: [
                                Row(
                                  mainAxisSize: MainAxisSize.max,
                                  children: [
                                    Padding(
                                      padding: EdgeInsets.only(right: 20),
                                      child: Icon(Icons.sort,size: 27.5,color: _isAppBarExpanded ? Colors.grey[200] : Colors.grey[700],),
                                    ),
                                    Expanded(child: Container(child: Align(alignment: Alignment.centerLeft,child: Text("File Manager",style: TextStyle(color: _isAppBarExpanded ? Colors.white : Colors.greenAccent,
                                        fontWeight: _isAppBarExpanded ? FontWeight.w400 : FontWeight.bold,fontSize: 25),),),),),
                                  ],
                                ),
                                _isAppBarExpanded ? Container(
                                  height: (_height*0.3) - ((_height * 0.2) - 30),
                                  child: Align(alignment: Alignment.centerLeft,child: Padding(
                                    padding: EdgeInsets.only(top: 7),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                      Padding(
                                        padding: EdgeInsets.only(bottom: 3),
                                        child: Text("Realme 2 Pro",style: TextStyle(color: Colors.grey[600],fontWeight: FontWeight.w700,fontSize: 16),),
                                      ),
                                      Padding(
                                        padding: EdgeInsets.only(bottom: 3),
                                        child: Text("64 GB Internal Storage",style: TextStyle(color: Colors.grey[600],fontWeight: FontWeight.w700,fontSize: 16),),
                                      ),
                                      Padding(
                                        padding: EdgeInsets.only(bottom: 3),
                                        child: Text("6 GB RAM",style: TextStyle(color: Colors.grey[600],fontWeight: FontWeight.w700,fontSize: 16),),
                                      ),
                                    ],),
                                  )),
                                ) : Container(),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  Expanded(
                    child: ListView(
                      controller: _scrollController,
                      children: [
                        Padding(
                          padding: EdgeInsets.only(bottom: 10),
                          child: Center(
                            child: Container(
                              padding: EdgeInsets.symmetric(vertical: 20),
                              width: _width - 40,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: Colors.grey[200],width: 1),
                                boxShadow: [BoxShadow(color: Colors.grey[350],spreadRadius: 0.25,blurRadius: 3,offset: Offset(0,4))],
                                color: Colors.grey[100],
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Container(
                                    height: _width * 0.55 - 40,width: _width * 0.55 - 40,
                                    child: Center(
                                      child: Container(
                                        height: (_width * 0.45) - 40,width: (_width * 0.45) - 40,
                                        child: TweenAnimationBuilder(
                                          duration: Duration(seconds: 1),
                                          tween: Tween<double>(begin: 0,end: 0.7),
                                          builder: (context,angle,child){
                                            return CustomPaint(
                                              foregroundPainter: StrokePieDashBoardNew(angle,7),
                                            //  child: Container(decoration: BoxDecoration(borderRadius: BorderRadius.circular(((_width * 0.55) - 40))/2),child: Center(child: Column(mainAxisSize: MainAxisSize.min,crossAxisAlignment: CrossAxisAlignment.center,children: [Text("44.5 GB /",style: TextStyle(fontWeight: FontWeight.bold,fontSize: ((_width * 0.45) - 40) * 0.125)),Text("60 GB",style: TextStyle(fontWeight: FontWeight.bold,fontSize: ((_width * 0.45) - 40) * 0.125),)],),)),
                                            );
                                          },
                                        ),
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.only(left: _width * 0.05),
                                    child: Container(
                                      width: _width * 0.35,
                                      child: Column(
                                        mainAxisSize: MainAxisSize.max,
                                        children: [
                                          Container(
                                            child: Row(mainAxisSize: MainAxisSize.max,children: [
                                              Container(width: _width * 0.2,height: (_width * 0.55 - 40)/4,child: Align(alignment: Alignment.centerLeft,child: Text("Videos",style: TextStyle(fontWeight: FontWeight.bold,color: Colors.greenAccent[700],fontSize: 16),)),),
                                              Expanded(child: Container(height: (_width * 0.55 - 40)/4,child: Align(alignment: Alignment.centerLeft,child: Text("${_fileFunction.roundToTwoPlaces(Storage.videoPercent)} %",style: TextStyle(fontWeight: FontWeight.bold,color: Colors.grey[600],fontSize: 14),)))),
                                            ],),),
                                          Container(
                                            child: Row(mainAxisSize: MainAxisSize.max,children: [
                                              Container(width: _width * 0.2,height: (_width * 0.55 - 40)/4,child: Align(alignment: Alignment.centerLeft,child: Text("Docs.",style: TextStyle(fontWeight: FontWeight.bold,color: Colors.yellow[600],fontSize: 16),)),),
                                              Expanded(child: Container(height: (_width * 0.55 - 40)/4,child: Align(alignment: Alignment.centerLeft,child: Text("${_fileFunction.roundToTwoPlaces(Storage.documentPercent)} %",style: TextStyle(fontWeight: FontWeight.bold,color: Colors.grey[600],fontSize: 14),)))),
                                            ],),),
                                          Container(
                                            child: Row(mainAxisSize: MainAxisSize.max,children: [
                                              Container(width: _width * 0.2,height: (_width * 0.55 - 40)/4,child: Align(alignment: Alignment.centerLeft,child: Text("Photos",style: TextStyle(fontWeight: FontWeight.bold,color: Colors.redAccent[200],fontSize: 16),)),),
                                              Expanded(child: Container(height: (_width * 0.55 - 40)/4,child: Align(alignment: Alignment.centerLeft,child: Text("${_fileFunction.roundToTwoPlaces(Storage.imagePercent)} %",style: TextStyle(fontWeight: FontWeight.bold,color: Colors.grey[600],fontSize: 14),)))),
                                            ],),),
                                          Container(
                                            child: Row(mainAxisSize: MainAxisSize.max,children: [
                                              Container(width: _width * 0.2,height: (_width * 0.55 - 40)/4,child: Align(alignment: Alignment.centerLeft,child: Text("Audio",style: TextStyle(fontWeight: FontWeight.bold,color: Colors.indigoAccent[200],fontSize: 16),)),),
                                              Expanded(child: Container(height: (_width * 0.55 - 40)/4,child: Align(alignment: Alignment.centerLeft,child: Text("${_fileFunction.roundToTwoPlaces(Storage.audioPercent)} %",style: TextStyle(fontWeight: FontWeight.bold,color: Colors.grey[600],fontSize: 14),)))),
                                            ],),),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(vertical: 30),
                          child: Center(
                            child: Container(
                              //color: Colors.redAccent,
                              width: _width -40,
                              height: 200,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    mainAxisSize: MainAxisSize.max,
                                    children: [
                                      _dashBoardIcon(Icons.favorite, "Favorites", "19.3 GB", Colors.pink[100], Colors.pinkAccent),
                                      _dashBoardIcon(Icons.file_download, "Downloads",_fileFunction.entitySizeConversion(Storage.downloadStorageSpaceBytes), Colors.yellow[200], Colors.yellow[800]),
                                      _dashBoardIcon(Icons.videocam, "Videos", _fileFunction.entitySizeConversion(Storage.videoStorageSpaceBytes), Colors.indigo[100], Colors.indigo),
                                    ],
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    mainAxisSize: MainAxisSize.max,
                                    children: [
                                      _dashBoardIcon(Icons.audiotrack, "Audio", _fileFunction.entitySizeConversion(Storage.audioStorageSpaceBytes), Colors.greenAccent[100], Colors.green[700]),
                                      _dashBoardIcon(Icons.description, "Documents", _fileFunction.entitySizeConversion(Storage.documentStorageSpaceBytes), Colors.orange[100], Colors.orange[700]),
                                      _dashBoardIcon(Icons.image, "Images", _fileFunction.entitySizeConversion(Storage.imageStorageSpaceBytes), Colors.red[100], Colors.red),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(top: 15,bottom: 7.5),
                          child: Container(
                              padding: EdgeInsets.symmetric(horizontal: 20),
                              child: Text("Recently Opened",style: TextStyle(color: Colors.grey[700],fontSize: 25,fontWeight: FontWeight.w600),)
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 20),
                          child: Column(
                            children: [
                              _dashBordEntityCard("Android","22 December 2000"),
                              _dashBordEntityCard("DCIM","10 March 2020"),
                              _dashBordEntityCard("Hello World","10 mins ago"),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }
        ),
      ),
    );
  }


  void _scrollListener(){
    if(_scrollController.offset >= _scrollController.position.maxScrollExtent && !_scrollController.position.outOfRange)
      print("End of list");
    else if(_scrollController.offset > _scrollController.position.minScrollExtent){
      if(_isAppBarExpanded)
        setState(() {
          print("Somewhere in middle");
          _isAppBarExpanded = false;
          _animationController.forward(from: 0.0);
        });
    }
    else if(_scrollController.offset <= _scrollController.position.minScrollExtent){
      print("Start of list");
      if(!_isAppBarExpanded)
        setState(() {
          _isAppBarExpanded = true;
          _animationController.reverse(from: 1.0);
        });
    }
  }


  Future<String> initializeDashboardData(){

    print("Func Called");

    List<Future> futureList = [];
    String extension;

    int videoStorageSpaceBytes = 0;
    int imageStorageSpaceBytes = 0;
    int documentStorageSpaceBytes = 0;
    int audioStorageSpaceBytes = 0;
    int zipStorageSpaceBytes = 0;
    int miscStorageSpaceBytes = 0;
    int exeStorageSpaceBytes = 0;
    int downloadStorageSpaceBytes = 0;

    futureList.add(DiskSpace.getTotalDiskSpace.then((totalDiskSpace){
      Storage.totalInternalStorage = totalDiskSpace * 1024 * 1024;
    }));
    futureList.add(DiskSpace.getFreeDiskSpace.then((freeDiskSpace){
      Storage.freeInternalStorage = freeDiskSpace * 1024 * 1024;
    }));
    futureList.add(Directory('storage/emulated/0/').list(recursive: true).listen((entity) {
      if(entity.runtimeType.toString() == "_File"){
        if(entity.path != "storage/emulated/0/Android"){
          extension = entity.path.split('.').last;
          if(extension == "pdf" || extension == "doc" || extension == "xls" || extension == "xlsx" || extension == "docx" || extension == "dwg" || extension == "txt"){
            documentStorageSpaceBytes += File(entity.path).statSync().size;
          }
          else if(extension == "avi" || extension == 'mov' || extension == "mkv" || extension == 'mp4' || extension == 'flv' || extension == 'mov' || extension == 'mpeg' || extension == 'wmv'){
            videoStorageSpaceBytes += File(entity.path).statSync().size;
          }
          else if(extension == 'mp3' || extension == 'rec' || extension == 'avr' || extension == 'wav' || extension == 'aac' || extension == 'vox' || extension == 'au' || extension == 'kar' || extension == 'spx' || extension == 'mp4a' || extension == 'cmf' || extension == 'audio' || extension =='mpega' || extension == 'cda' || extension == 'wpl' || extension == 'mpa'){
            audioStorageSpaceBytes += File(entity.path).statSync().size;
          }
          else if(extension == '7z' || extension == '.arj' || extension == 'gzip' || extension == 'rar' || extension == 'zip' || extension == 'pkg' || extension == 'arj' || extension == 'rpm'){
            zipStorageSpaceBytes += File(entity.path).statSync().size;
          }
          else if(extension == 'ai' || extension == 'jpg' || extension == 'jpeg' || extension == 'svg' || extension == 'png' || extension == 'ico' || extension == 'bmp' || extension == 'gif' || extension == 'ps' || extension == 'tif'){
            imageStorageSpaceBytes += File(entity.path).statSync().size;
          }
          else if(extension == 'exe' || extension == 'apk' || extension == 'bat' || extension == 'cgi' || extension == 'jar' || extension == 'wsf' || extension == 'bin' || extension == 'msi'){
            exeStorageSpaceBytes += File(entity.path).statSync().size;
          }
        }
      }
    }).asFuture(1));

    futureList.add(Directory('storage/emulated/0/Download').list(recursive: false).listen((entity) {

      if(entity.runtimeType.toString() == '_File'){
          downloadStorageSpaceBytes += entity.statSync().size;
      }
      else{
        futureList.add(Directory(entity.path).list(recursive: true).listen((childEntity){
          downloadStorageSpaceBytes += childEntity.statSync().size;
        }).asFuture(1));
      }
    }).asFuture(1).then((value){print("Download Scan Complete");}));


    //Storage.isDashboardDataInitialised = true;

    return Future.wait(futureList).then((value){
      //Storage().resetDashboardData();

      int totalSum = imageStorageSpaceBytes + videoStorageSpaceBytes + documentStorageSpaceBytes + audioStorageSpaceBytes;

      Storage.imagePercent = (imageStorageSpaceBytes/totalSum) * 100;
      Storage.videoPercent = (videoStorageSpaceBytes/totalSum) * 100;
      Storage.documentPercent = (documentStorageSpaceBytes/totalSum) * 100;
      Storage.audioPercent = (audioStorageSpaceBytes/totalSum) * 100;

      Storage.videoStorageSpaceBytes = videoStorageSpaceBytes;
      Storage.imageStorageSpaceBytes = imageStorageSpaceBytes;
      Storage.documentStorageSpaceBytes = documentStorageSpaceBytes;
      Storage.audioStorageSpaceBytes = audioStorageSpaceBytes;
      Storage.zipStorageSpaceBytes = zipStorageSpaceBytes;
      Storage.miscStorageSpaceBytes = miscStorageSpaceBytes;
      Storage.exeStorageSpaceBytes = exeStorageSpaceBytes;
      Storage.downloadStorageSpaceBytes = downloadStorageSpaceBytes;
      print("Complete");
      return "i";
    });

  }

  Widget _dashBordEntityCard(String name,String date){
    return Container(
      height: _width * 0.175,
      width: _width - 40,
    // decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Colors.grey[300],width: 1))),
     // color: Colors.redAccent,
      padding: EdgeInsets.all(5),
      child: Row(
        children: [
          Container(height: _width * 0.15,width: _width * 0.15,child: Icon(Icons.folder,color: Colors.yellow[700],size: _width * 0.125,),),
          Expanded(child: Padding(
            padding: EdgeInsets.only(left: 15),
            child: Container(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name,style: TextStyle(color: Colors.grey[700],fontWeight: FontWeight.w600,fontSize: 15),),
                  Text(date,style: TextStyle(color: Colors.black,fontSize: 10),),
                ],
              ),
            ),
          ),),
        ],
      ),
    );
  }

  Widget _dashBoardIcon(IconData iconData,String name,String size,Color backgroundColor,Color foregroundColor){
    return Container(
      padding: EdgeInsets.all(10),
      height: 90,width: _width * 0.25,
      decoration: BoxDecoration(color: backgroundColor,borderRadius: BorderRadius.circular(20),boxShadow: [BoxShadow(color: Colors.grey[400],spreadRadius: 0.5,blurRadius: 2,offset: Offset(0,3))]),
      child: Column(
        mainAxisSize : MainAxisSize.max,
        children: [
          Expanded(flex: 6,child: Align(alignment: Alignment.centerLeft,child: Icon(iconData,color: foregroundColor,size: _width * 0.08,)),),
          Expanded(flex: 4,child: Container(
            child: Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Align(alignment: Alignment.centerLeft,child: Text(name,style: TextStyle(color: foregroundColor,fontWeight: FontWeight.bold,fontSize: _width * 0.03),)),
                Align(alignment: Alignment.centerLeft,child: Text(size,style: TextStyle(color: foregroundColor,fontSize: _width * 0.025),))
              ],
            ),
          ),),
        ],
      ),
    );
  }


}

class StrokePieDashBoard extends CustomPainter
{

  /// 4 strokes : 8 total sections ..... radius of alternate multiples of 8

  double _value;
  double _strokeWidth;

  StrokePieDashBoard(this._value,this._strokeWidth);

  @override
  void paint(Canvas canvas, Size size) {
    // TODO: implement paint

    double pieRadius = min(size.width/2,size.height/2);

    Paint outerArc = Paint()
      ..color = Colors.grey[400]
      .. style = PaintingStyle.stroke
      .. strokeWidth = pieRadius * 0.03;

    Paint innerArc1 = Paint()
      ..strokeWidth = pieRadius * 0.125
      ..style = PaintingStyle.stroke
      ..color = Colors.greenAccent[200]
      ..strokeCap = /*StrokeCap.round*/StrokeCap.square;

    Paint innerArc2 = Paint()
      ..strokeWidth = pieRadius * 0.125
      ..style = PaintingStyle.stroke
      ..color = Colors.yellow[400]
      ..strokeCap = /*StrokeCap.round*/StrokeCap.square;

    Paint innerArc3 = Paint()
      ..strokeWidth = pieRadius * 0.125
      ..style = PaintingStyle.stroke
      ..color = Colors.redAccent[100]
      ..strokeCap = /*StrokeCap.round*/StrokeCap.square;

    Paint innerArc4 = Paint()
      ..strokeWidth = pieRadius * 0.125
      ..style = PaintingStyle.stroke
      ..color = Colors.indigoAccent[200]
      ..strokeCap = /*StrokeCap.round*/StrokeCap.square;

    Offset center = Offset(size.width/2,size.height/2);
    double val1 = 2 * pi * (Storage.videoPercent/100);
    double val2 = 2 * pi * (Storage.audioPercent/100);
    double val3 = 2 * pi * (Storage.documentPercent/100);
    double val4 = 2 * pi * (Storage.imagePercent/100);

    canvas.drawCircle(center,pieRadius, outerArc);

    //canvas.drawCircle(center,pieRadius/* * 0.4*/, outerArc);
    canvas.drawArc(Rect.fromCircle(center: center,radius: pieRadius/* * 0.4*/), /*-pi/2*/-(pi/2) + val1 + val3 + val4, val2, false, innerArc4);

    //canvas.drawCircle(center,pieRadius/* * 0.6*/, outerArc);
    canvas.drawArc(Rect.fromCircle(center: center,radius: pieRadius/* * 0.6*/), /*-pi/2*/-(pi/2) +  val1 + val3, val4, false, innerArc3);

    //canvas.drawCircle(center,pieRadius/* * 0.8*/, outerArc);
    canvas.drawArc(Rect.fromCircle(center: center,radius: pieRadius/* * 0.8*/), /*-pi/2*/-(pi/2) + val1, val3, false, innerArc2);

    canvas.drawArc(Rect.fromCircle(center: center,radius: pieRadius), -pi/2, val1 , false, innerArc1);

  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    // TODO: implement shouldRepaint
    return true;
  }
}





class StrokePieDashBoardNew extends CustomPainter
{

  /// 4 strokes : 8 total sections ..... radius of alternate multiples of 8

  double _value;
  double _strokeWidth;

  StrokePieDashBoardNew(this._value,this._strokeWidth);

  @override
  void paint(Canvas canvas, Size size) {
    // TODO: implement paint

    double pieRadius = min(size.width/2,size.height/2);

    Paint outerArc = Paint()
      ..color = Colors.grey[350]
      .. style = PaintingStyle.stroke
      .. strokeWidth = pieRadius * 0.03;

    Paint innerArc1 = Paint()
      ..strokeWidth = pieRadius * 0.12
      ..style = PaintingStyle.stroke
      ..color = Colors.greenAccent[200]
      ..strokeCap = StrokeCap.round;

    Paint innerArc2 = Paint()
      ..strokeWidth = pieRadius * 0.12
      ..style = PaintingStyle.stroke
      ..color = Colors.yellow[400]
      ..strokeCap = StrokeCap.round;

    Paint innerArc3 = Paint()
      ..strokeWidth = pieRadius * 0.12
      ..style = PaintingStyle.stroke
      ..color = Colors.redAccent[100]
      ..strokeCap = StrokeCap.round;

    Paint innerArc4 = Paint()
      ..strokeWidth = pieRadius * 0.12
      ..style = PaintingStyle.stroke
      ..color = Colors.indigoAccent[200]
      ..strokeCap = StrokeCap.round;

    Offset center = Offset(size.width/2,size.height/2);
    double val1 = 2 * pi * (Storage.videoPercent/100);
    double val2 = 2 * pi * (Storage.audioPercent/100);
    double val3 = 2 * pi * (Storage.documentPercent/100);
    double val4 = 2 * pi * (Storage.imagePercent/100);

    canvas.drawCircle(center,pieRadius, outerArc);
    canvas.drawArc(Rect.fromCircle(center: center,radius: pieRadius), -pi/2, val1 , false, innerArc1);

    canvas.drawCircle(center,pieRadius * 0.8, outerArc);
    canvas.drawArc(Rect.fromCircle(center: center,radius: pieRadius * 0.8), -pi/2, val3, false, innerArc2);

    canvas.drawCircle(center,pieRadius * 0.6, outerArc);
    canvas.drawArc(Rect.fromCircle(center: center,radius: pieRadius * 0.6), -pi/2, val4, false, innerArc3);

    canvas.drawCircle(center,pieRadius * 0.4, outerArc);
    canvas.drawArc(Rect.fromCircle(center: center,radius: pieRadius * 0.4), -pi/2, val2, false, innerArc4);

  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    // TODO: implement shouldRepaint
    return true;
  }
}


class DashBoardAppBarClipper extends CustomClipper<Path>{

  double rateOfProgress;

  DashBoardAppBarClipper(this.rateOfProgress);

  @override
  getClip(Size size) {
    // TODO: implement getClip
    Path path = Path();

    path.lineTo(0,size.height);
    path.quadraticBezierTo(0, size.height * (0.8  + (0.2 * rateOfProgress)), size.width * 0.125, size.height * (0.78 + (0.22 * rateOfProgress)));
    path.quadraticBezierTo(size.width * 0.65, size.height * (0.865 + (0.135 * rateOfProgress)), size.width * 0.8, size.height * (0.45 + (0.55 * rateOfProgress)));
    path.quadraticBezierTo(size.width * 0.875, size.height * (0.275 + (0.725 * rateOfProgress)), size.width, size.height * (0.3 + (0.7 * rateOfProgress)));
    path.lineTo(size.width, 0);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(CustomClipper oldClipper) {
    // TODO: implement shouldReclip
    return true;
  }
}


/// 45 - 0   :   47.5 - 0   :  20 - 0   :   0.45 - 1   :   0.275 - 1   :   0.3 - 1
