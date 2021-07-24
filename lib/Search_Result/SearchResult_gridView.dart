import 'dart:convert';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_met_ui_changes/Widgets/artPiece_Card_big.dart';
import 'package:flutter_met_ui_changes/Widgets/artPiece_tile.dart';
import 'package:flutter_tindercard/flutter_tindercard.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart';

import 'package:flutter_met_ui_changes/ReadWrite/ReadWrite.dart';

class SearchResult_gridView extends StatefulWidget {
  String searchItem;
  SearchResult_gridView({Key key,@required this.searchItem}) : super(key: key);

  @override
  _SearchResult_gridViewState createState() => _SearchResult_gridViewState();
}

class _SearchResult_gridViewState extends State<SearchResult_gridView> {

  TextEditingController textController = TextEditingController();
  List<dynamic> data = [];
  bool objectCalled = false;
  var searchItem;
  List<dynamic> imgs = [];
  List<int> favorites = [];
  bool terminateProcess = false;
  ReadWrite rw = new ReadWrite();
  List<artPiece_tile> tile = [];
  List<int> indexList = [];

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
    tile.clear();
    indexList.clear();
    searchItem = search;
    //print("Department : $favorites");
    Response response = await get(
        "https://collectionapi.metmuseum.org/public/collection/v1/search?q=$searchItem&isOnView=true");
    var objectsID = jsonDecode(response.body);
    int objectCount = 0;
    int currentObjectIndex = 0;
    int i = 0;

    while (objectCount <= 100) {
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
         tile.add(artPiece_tile(objectID: d['objectID']));
         indexList.add(d['objectID']);
         objectCount++;
        }
      }

      print("Loaded $objectCount objects");

      setState(() {
       objectCalled = true;
      });
    }


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
      objectCalled = true;
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

        body:objectCalled?Column(
          children: [

            Padding(
              padding: EdgeInsets.fromLTRB(0, 27, 0, 30),
              child: Container(
                width: double.infinity,
                height: 52,
                decoration: BoxDecoration(
                  color: Color(0xFFEEEEEE),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Expanded(
                        child: Padding(
                          padding: EdgeInsets.fromLTRB(5, 0, 2, 0),
                          child: TextFormField(
                              textInputAction: TextInputAction.done,
                              onFieldSubmitted: (term) {
                                setState(() {
                                  objectCalled = false;
                                  retrieveData(textController.text);
                                });
                              },
                              controller: textController,
                              obscureText: false,
                              decoration: InputDecoration(
                                hintText:
                                'Search for artists,makers and departments',
                                hintStyle: GoogleFonts.lato(),
                                enabledBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Colors.transparent,
                                    width: 1,
                                  ),
                                  borderRadius:
                                  const BorderRadius.only(
                                    topLeft: Radius.circular(4.0),
                                    topRight: Radius.circular(4.0),
                                  ),
                                ),
                                focusedBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Colors.transparent,
                                    width: 1,
                                  ),
                                  borderRadius:
                                  const BorderRadius.only(
                                    topLeft: Radius.circular(4.0),
                                    topRight: Radius.circular(4.0),
                                  ),
                                ),
                              )),
                        )
                    ),
                    InkWell(
                      child: Icon(
                        Icons.search,
                        color: Colors.black,
                        size: 28,
                      ),
                      onTap: (){
                        setState(() {
                          objectCalled = false;
                          retrieveData(textController.text);
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),

            Expanded(
              child:ListView.builder(
                scrollDirection: Axis.vertical,
                shrinkWrap: true,
                itemCount: tile.length,
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
              ),

              /*Column(
              children:tile,
            ),*/
            ),
          ],
        ):Center(
          child: CircularProgressIndicator(),
        )
    );
  }
}
