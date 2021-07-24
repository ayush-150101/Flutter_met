
import 'dart:convert';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_met_ui_changes/Widgets/ArtPiece_card_big.dart';
import 'package:flutter_met_ui_changes/Widgets/artPiece_tile.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart';
import 'package:flutter_met_ui_changes/ReadWrite/ReadWrite.dart';

class departmentItems_gridView extends StatefulWidget {
  int departmentId;
  String departmentName;

  departmentItems_gridView({Key key,@required this.departmentId,@required this.departmentName}) : super(key: key);

  @override
  _departmentItems_gridViewState createState() => _departmentItems_gridViewState();
}

class _departmentItems_gridViewState extends State<departmentItems_gridView> {

  List<dynamic> data = [];
  bool objectCalled = false;
  var departmentID, departmentName;
  List<int> favorites = [];
  List<dynamic> imgs = [];
  List<dynamic> startDate = [];
  List<dynamic> endDate = [];
  bool processTerminated = false;
  ReadWrite rw = new ReadWrite();
  List<artPiece_Card_big> cards = [];
  bool flag = true;
  int currentCardIndex;
  List<int> removeIndex = [];
  List<int> Ids = [];
  List<artPiece_tile> tile = [];
  List<int> indexList = [];
  int ind = 0;

  bool showInfo = false;

  void toggleInfo(){

    setState(() {
      if(showInfo)
        showInfo = false;

      else
        showInfo = true;
    });

  }


  void readData() async{
    var read = await rw.readCounter();
    print(read);

    setState(() {
      favorites = read;
    });
  }

  bool isSaved(var n) {
    if (favorites.isNotEmpty)
      return favorites.contains(n);
    else {
      return false;
    }
  }

  Future<dynamic> retrieveData() async {
    //print("searching for $search");
    data.clear();
    departmentID = widget.departmentId;
    print("Department : $favorites");
    Response response = await get(
        "https://collectionapi.metmuseum.org/public/collection/v1/search?departmentId=$departmentID&isHighlight=true&q=*");
    var objectsID = jsonDecode(response.body);
    int i = 0;
    print("Objects:${objectsID["objectIDs"]}");

    int itemRange = 100<(objectsID["objectIDs"].length)?100:(objectsID["objectIDs"].length);

    print("ObjectsID :${objectsID["objectIDs"].length} $objectsID");

    while(i<itemRange){
      tile.add(artPiece_tile(objectID: objectsID["objectIDs"][i],));
      print("Adding ${objectsID["objectIDs"][i]}");
      indexList.add(objectsID["objectIDs"][i]);


      i++;

      setState(() {
        objectCalled = true;
      });
    }

    print("ERROR: $indexList");

   /* for(int x = 0;x<objectsID["objectIDs"].length;x++){
      {
        tile.add(artPiece_Card_big(objectID: objectsID["objectIDs"][x]));
        print("Adding ${objectsID["objectIDs"][x]}");
        indexList.add(objectsID["objectIDs"][x]);
      }
    }

    print('indexList: ${indexList.length} $indexList');

    setState(() {
      objectCalled = true;
    });*/

  }

  void showToast(String s) {
    Fluttertoast.showToast(
      msg: s,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIos: 1,
      backgroundColor: Colors.grey[900],
      textColor: Colors.grey[300],
    );
  }

  void initState() {
    // TODO: implement initState
    super.initState();
    readData();
    retrieveData();
  }

  @override
  Widget build(BuildContext context) {
    departmentName = widget.departmentName;
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    return Scaffold(
        appBar: AppBar(
          centerTitle: false,
          backgroundColor: Colors.white,
          automaticallyImplyLeading: false,
          title: FittedBox(
            fit: BoxFit.fitWidth,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                InkWell(
                  child: Icon(
                    Icons.arrow_back_outlined,
                    color: Colors.black,
                    size: 24,
                  ),
                  onTap: () {
                    setState(() {
                      processTerminated = true;
                    });
                    Navigator.pop(context);
                  },
                ),
                SizedBox(
                  width: 15,
                ),
                AutoSizeText(
                  "$departmentName",
                  style: GoogleFonts.playfairDisplay(
                    letterSpacing: 2,
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                ),
              ],
            ),
          ),
        ),

        body:objectCalled?ListView.builder(
          itemCount: indexList.length,
          itemBuilder:(BuildContext context, int index) => GestureDetector(
              onDoubleTap:() {
                print("Double Tap triggered");
                setState(() {
                  if(favorites.contains(indexList[index])) {
                    favorites.remove(indexList[index]);
                    showToast("Removed From Favorites!");
                  }
                  else {
                    favorites.add(indexList[index]);
                    showToast("Added To Favorites!");
                  }
                  rw.writeCounter(favorites);
                });
              },
              child: Center(
                  child: Stack(
                    //mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Center(child: tile[index]),
                      /*Center(
                        child: Align(
                          alignment: Alignment.bottomLeft,
                          child: InkWell(
                            onTap: (){
                              setState(() {
                                if(favorites.contains(indexList[index])) {
                                  favorites.remove(indexList[index]);
                                  showToast("Removed From Favorites!");
                                }
                                else {
                                  favorites.add(indexList[index]);
                                  showToast("Added To Favorites!");
                                }
                                rw.writeCounter(favorites);
                              });
                            },
                            child:favorites.contains(indexList[index])?
                            Padding(
                              padding: EdgeInsets.fromLTRB(width*0.1,height*0.83,0,0),
                              child: Icon(Icons.favorite,color: Colors.red,size: 28),
                            ):
                            Padding(
                              padding: EdgeInsets.fromLTRB(width*0.1,height*0.83,0,0),
                              child: Icon(Icons.favorite_border,color: Colors.red,size: 28,),
                            ) ,
                          ),
                        ),
                      )*/
                    ],
                  )
              )
          ),
        ):Center(
          child: CircularProgressIndicator(),
        )
    );
  }
}

