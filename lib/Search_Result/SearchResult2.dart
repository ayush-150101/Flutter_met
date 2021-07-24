import 'dart:convert';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tindercard/flutter_tindercard.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart';

import 'package:flutter_met_ui_changes/ReadWrite/ReadWrite.dart';

class SearchResult2 extends StatefulWidget {
  String searchItem;
  SearchResult2({Key key,@required this.searchItem}) : super(key: key);

  @override
  _SearchResult2State createState() => _SearchResult2State();
}

class _SearchResult2State extends State<SearchResult2> {

  TextEditingController textController = TextEditingController();
  List<dynamic> data = [];
  bool _dataLoaded = false;
  var searchItem;
  List<dynamic> imgs = [];
  List<int> favorites = [];
  bool terminateProcess = false;
  ReadWrite rw = new ReadWrite();

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
      for(i = x;i<(x+30);i++)
        ftr.add(get("https://collectionapi.metmuseum.org/public/collection/v1/objects/${objectsID["objectIDs"][i]}"));

      final results = await Future.wait(ftr);

      //i = i+20+1;
      print("Called $i objects");


      for(int k = 0;k<30;k++){
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
      _dataLoaded = true;
    });

  }

  Future<dynamic> object(String search) async {
    //print("searching for $search");
    data.clear();
    searchItem = search;
    //print("Department : $favorites");
    Response response = await get(
        "https://collectionapi.metmuseum.org/public/collection/v1/search?q=$searchItem&isOnView=true");
    var objectsID = jsonDecode(response.body);
    int objectCount = 0;
    int currentObjectIndex = 0;

    while (objectCount <= 20) {
      if (terminateProcess) break;
      var i = objectsID["objectIDs"][currentObjectIndex];
      Response response = await get(
          "https://collectionapi.metmuseum.org/public/collection/v1/objects/$i");
      //print("Fetched Object $i");

      currentObjectIndex++;
      var d = jsonDecode(response.body);

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

    setState(() {
      _dataLoaded = true;
    });

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
                    terminateProcess = true;
                    Navigator.pop(context,);
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

        body:_dataLoaded?Center(
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
