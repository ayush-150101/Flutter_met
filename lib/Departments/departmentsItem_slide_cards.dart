
import 'dart:convert';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_tindercard/flutter_tindercard.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter_met_ui_changes/ArtPiece/ArtPiece.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart';

import 'package:flutter_met_ui_changes/HomePageWidget.dart';
import 'package:flutter_met_ui_changes/ReadWrite/ReadWrite.dart';

class departmentItems_slide_cards extends StatefulWidget {
  int departmentId;
  String departmentName;

  departmentItems_slide_cards({Key key,@required this.departmentId,@required this.departmentName}) : super(key: key);

  @override
  _departmentItems_slide_cardsState createState() => _departmentItems_slide_cardsState();
}

class _departmentItems_slide_cardsState extends State<departmentItems_slide_cards> {

  List<dynamic> data = [];
  bool objectCalled = false;
  var departmentID, departmentName;
  List<int> favorites = [];
  List<dynamic> imgs = [];
  List<dynamic> startDate = [];
  List<dynamic> endDate = [];
  bool processTerminated = false;
  ReadWrite rw = new ReadWrite();


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
        "https://collectionapi.metmuseum.org/public/collection/v1/objects?departmentIds=$departmentID&isOnVIew=true");
    var objectsID = jsonDecode(response.body);
    int objectCount = 0;
    int currentObjectIndex = 0;
    int i = 0;

    while (objectCount <= 60) {
      if (processTerminated) break;

      List<Future> ftr = [];
      int x = i;
      for(i = x;i<(x+20);i++)
        ftr.add(get("https://collectionapi.metmuseum.org/public/collection/v1/objects/${objectsID["objectIDs"][i]}"));


      final results = await Future.wait(ftr);

      // i = i+20+1;
      print("Called $i objects");


      for(int k = 0;k<20;k++){
        var d = jsonDecode(results[k].body);

        if (d['isPublicDomain'] == true) {
          var img = NetworkImage("${d["primaryImageSmall"]}");

          setState(() {
           // print("Object Id : ${d["objectID"]}");
            imgs.add(img);
            data.add(d);
            objectCount++;
            print("Loaded $objectCount objects!");
          });


        }
      }
    }
    setState(() {
      objectCalled = true;
    });

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
    CardController controller;
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
                  style: GoogleFonts.lato(
                    letterSpacing: 2,
                    color: Colors.black,
                  ),
                  maxLines: 1,
                ),
              ],
            ),
          ),
        ),

        body:objectCalled?Center(
          child: Container(
            height: MediaQuery.of(context).size.height * 0.6,
            child: new TinderSwapCard(
              swipeUp: true,
              swipeDown: true,
              orientation: AmassOrientation.BOTTOM,
              totalNum: data.length,
              stackNum: 2,
              swipeEdge: 4.0,
              maxWidth: MediaQuery.of(context).size.width * 1,
              maxHeight: MediaQuery.of(context).size.height * 1,
              minWidth: MediaQuery.of(context).size.width * 0.8,
              minHeight: MediaQuery.of(context).size.height * 0.8,
              cardBuilder: (context, index) => /*_indexList.length!=(index+1)?Card(
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  ):*/Card(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Image(
                        image: imgs[index],
                        width: MediaQuery.of(context).size.width,
                        height: MediaQuery.of(context).size.height * 0.5,
                      ),
                      Text(
                        data[index]["title"],
                        style: GoogleFonts.davidLibre(
                            fontSize: 24,
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 3),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Text("${data[index]["objectEndDate"]}",
                          style: GoogleFonts.lato(
                              fontSize: 12, color: Colors.red, letterSpacing: 3)),
                      SizedBox(
                        height: 40,
                      ),
                      Text(
                        'Department',
                        style: GoogleFonts.lato(
                            letterSpacing: 2,
                            fontWeight: FontWeight.bold,
                            fontSize: 16),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Text(
                        data[index]["department"],
                        style: GoogleFonts.davidLibre(
                            fontSize: 24,
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 3),
                      ),
                    ],
                  ),
                ),
              ),
              cardController: controller = CardController(),
              swipeUpdateCallback:
                  (DragUpdateDetails details, Alignment align) {
                /// Get swiping card's alignment
                if (align.x < 0) {
//Card is LEFT swiping
                } else if (align.x > 0) {
//Card is RIGHT swiping
                }
              },
              swipeCompleteCallback:
                  (CardSwipeOrientation orientation, int index) {
                if(orientation == CardSwipeOrientation.RIGHT){
                  if(!favorites.contains(data[index]['objectID']))
                    favorites.add(data[index]['objectID']);
                  rw.writeCounter(favorites);
                  showToast("Added to Favorites");
                  print("${data[index]["title"]} added to favorites");

                }

                if(index == data.length - 1)
                  Navigator.pop(context);
                /// Get orientation & index of swiped card!
              },
            ),
          ),
        ):Center(
          child: CircularProgressIndicator(),
        )
    );
  }
}
