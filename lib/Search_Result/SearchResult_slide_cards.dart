import 'dart:convert';
import 'dart:ui';

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

class searchItems_slide_cards extends StatefulWidget {
  String searchItem;
  searchItems_slide_cards({Key key, @required this.searchItem})
      : super(key: key);

  @override
  _searchItems_slide_cardsState createState() =>
      _searchItems_slide_cardsState();
}

class _searchItems_slide_cardsState extends State<searchItems_slide_cards> {
  List<dynamic> data = [];
  bool objectCalled = false;
  var departmentID, departmentName;
  List<int> favorites = [];
  List<dynamic> imgs = [];
  List<dynamic> startDate = [];
  List<dynamic> endDate = [];
  bool terminateProcess = false;
  String searchItem;
  ReadWrite rw = new ReadWrite();
  bool _dataLoaded = false;

  void readData() async {
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

  Future<dynamic> retrieveData(String search) async {
    //print("searching for $search");
    data.clear();
    searchItem = search;
    //print("Department : $favorites");
    Response response = await get(
        "https://collectionapi.metmuseum.org/public/collection/v1/search?q=$searchItem&isOnView=true");
    var objectsID = jsonDecode(response.body);
    int objectCount = 0;
    int currentObjectIndex = 0;
    int i = 0;

    while (objectCount <= 40) {
      if (terminateProcess) break;
      /*Response response = await get(
          "https://collectionapi.metmuseum.org/public/collection/v1/objects/$i");*/
      //print("Fetched Object $i");

      List<Future> ftr = [];
      int x = i;
      for (i = x; i < (x + 30); i++)
        ftr.add(get(
            "https://collectionapi.metmuseum.org/public/collection/v1/objects/${objectsID["objectIDs"][i]}"));

      final results = await Future.wait(ftr);

      //i = i+20+1;
      print("Called $i objects");

      for (int k = 0; k < 30; k++) {
        var d = jsonDecode(results[k].body);

        if (d['isPublicDomain'] == true) {
          var img = NetworkImage("${d["primaryImageSmall"]}");
          img.resolve(ImageConfiguration()).addListener(
            ImageStreamListener(
              (info, call) {
                setState(() {
                  imgs.add(img);
                  data.add(d);
                  objectCount++;
                  print("Loaded $objectCount objects!");
                });
              },
            ),
          );
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
    //printData(widget.searchItem);
    retrieveData(widget.searchItem);
  }

  @override
  Widget build(BuildContext context) {
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
                      terminateProcess = true;
                    });
                    Navigator.pop(context);
                  },
                ),
                SizedBox(
                  width: 15,
                ),
                AutoSizeText(
                  "Search Result",
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
        body: objectCalled
            ? Center(
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
                    cardBuilder: (context,
                            index) /*_indexList.length!=(index+1)?Card(
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  ):*/
                        {
                      final screenHeight = MediaQuery.of(context).size.height;
                      final screenWidth = MediaQuery.of(context).size.width;

                      final _filledCircle = Container(
                        height: 4.0,
                        width: 4.0,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white60,
                        ),
                      );

                      final _name = Center(
                        child: Text(
                          data[index]["title"].length > 16
                              ? "${data[index]["title"].substring(0, 16)}..."
                              : data[index]["title"],
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 18.0,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      );

                      final _details = ClipRRect(
                        borderRadius: BorderRadius.circular(15.0),
                        child: BackdropFilter(
                          filter:
                              ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
                          child: Container(
                            padding:
                                EdgeInsets.fromLTRB(15.0, 15.0, 15.0, 15.0),
                            height: screenHeight * .1,
                            child: Column(
                              mainAxisAlignment:
                                  MainAxisAlignment.spaceEvenly,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[_name],
                            ),
                          ),
                        ),
                      );

                      return GestureDetector(
                          onTap: () {},
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(0, 0, 0, 20),
                            child: Stack(
                              children: <Widget>[
                                Container(
                                  margin: EdgeInsets.only(bottom: 10.0),
                                  height: screenHeight * 0.9,
                                  width: screenWidth * 0.9,
                                  decoration: BoxDecoration(
                                    image: DecorationImage(
                                      image: imgs[index],
                                      fit: BoxFit.cover,
                                    ),
                                    borderRadius: BorderRadius.circular(20.0),
                                  ),
                                ),
                                Align(
                                    alignment: Alignment.bottomCenter,
                                    child: _details)
                              ],
                            ),
                          ));
                    },
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
                      if (orientation == CardSwipeOrientation.RIGHT) {
                        if (!favorites.contains(data[index]['objectID']))
                          favorites.add(data[index]['objectID']);
                        rw.writeCounter(favorites);
                        showToast("Added to Favorites");
                        print("${data[index]["title"]} added to favorites");
                      }

                      if (index == data.length - 1) Navigator.pop(context);

                      /// Get orientation & index of swiped card!
                    },
                  ),
                ),
              )
            : Center(
                child: CircularProgressIndicator(),
              ));
  }
}
