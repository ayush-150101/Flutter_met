import 'dart:convert';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_met_ui_changes/ArtPiece/ArtPiece_blurred.dart';
import 'package:flutter_met_ui_changes/Widgets/ArtPiece_card.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart';


import 'package:flutter_met_ui_changes/ArtPiece/ArtPiece.dart';
import 'package:flutter_met_ui_changes/ArtPiece/ArtPiece_fav.dart';
import 'package:flutter_met_ui_changes/ReadWrite/ReadWrite.dart';

class searchResult extends StatefulWidget {
  String searchItem;

  searchResult({Key key, @required this.searchItem}) : super(key: key);

  @override
  _searchResultState createState() => _searchResultState();
}

class _searchResultState extends State<searchResult> {
  TextEditingController textController = TextEditingController();
  List<dynamic> data = [];
  bool objectCalled = false;
  var searchItem;
  List<dynamic> imgs = [];
  List<int> favorites = [];
  bool terminateProcess = false;
  ReadWrite rw = new ReadWrite();
  //List<artPiece_card> h = [];


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

  Future<dynamic> object(String search) async {
    print("searching for $search");
    data.clear();
    searchItem = search;
    print("Department : $favorites");
    Response response = await get(
        "https://collectionapi.metmuseum.org/public/collection/v1/search?q=$searchItem&isOnView=true");
    var objectsID = jsonDecode(response.body);
    int objectCount = 0;
    int currentObjectIndex = 0;

    while (objectCount <= 40) {
      if (terminateProcess) break;
      var i = objectsID["objectIDs"][currentObjectIndex];
      Response response = await get(
          "https://collectionapi.metmuseum.org/public/collection/v1/objects/$i");
      print("Fetched Object $i");

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
                objectCalled = true;
              });
            },
          ),
        );
      }
    }
  }

  void initState() {
    // TODO: implement initState
    super.initState();
    textController.text = widget.searchItem;
    readData();
    object(widget.searchItem);
  }

  @override
  Widget build(BuildContext context) {
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
      body: (!objectCalled)
          ? Column(
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(0, 27, 0, 0),
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
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(4.0),
                                  topRight: Radius.circular(4.0),
                                ),
                              ),
                              focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                  color: Colors.transparent,
                                  width: 1,
                                ),
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(4.0),
                                  topRight: Radius.circular(4.0),
                                ),
                              ),
                            )),
                      )),
                  InkWell(
                    child: Icon(
                      Icons.search,
                      color: Colors.black,
                      size: 28,
                    ),
                    onTap: () {
                      setState(() {
                        objectCalled = false;
                        object(textController.text);
                      });
                    },
                  ),
                ],
              ),
            ),
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Center(
                child: CircularProgressIndicator(),
              ),
            ),
          ),
        ],
      )
          : Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(0, 27, 0, 0),
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
                                  borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(4.0),
                                    topRight: Radius.circular(4.0),
                                  ),
                                ),
                                focusedBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Colors.transparent,
                                    width: 1,
                                  ),
                                  borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(4.0),
                                    topRight: Radius.circular(4.0),
                                  ),
                                ),
                              )),
                        )),
                    InkWell(
                      child: Icon(
                        Icons.search,
                        color: Colors.black,
                        size: 28,
                      ),
                      onTap: () {
                        setState(() {
                          objectCalled = false;
                          object(textController.text);
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: ListView.separated(
                separatorBuilder: (BuildContext context, int index) =>
                    Divider(),
                itemCount: data.length,
                itemBuilder: (BuildContext context, int index) =>
                    Slidable(
                      actionPane: SlidableDrawerActionPane(),
                      actionExtentRatio: 0.15,

                      child: ListTile(
                        title: Row(children: [
                          Image(
                            image: imgs[index],
                            width: MediaQuery.of(context).size.width * 0.1,
                            height: MediaQuery.of(context).size.height * 0.1,
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          Expanded(
                            child: Text(
                              data[index]["title"],
                              style: GoogleFonts.lato(letterSpacing: 2),
                            ),
                          ),
                          Align(
                            alignment: Alignment.centerRight,
                            child: InkWell(
                              child: Icon(
                                Icons.chevron_right,
                                size: 24,
                              ),
                              onTap: () async {
                                setState(() {
                                  Navigator.push(
                                      context,
                                      PageRouteBuilder(
                                        pageBuilder:
                                            (context, animation1, animation2) =>
                                            ArtPiece_blurred(
                                              objectID: data[index]["objectID"],
                                            ),
                                        transitionDuration:
                                        Duration(seconds: 0),
                                      ));
                                });
                              },
                            ),
                          )
                        ]),
                        onTap: () async {
                          setState(() {
                            Navigator.push(
                                context,
                                PageRouteBuilder(
                                  pageBuilder:
                                      (context, animation1, animation2) =>
                                      ArtPiece_blurred(
                                        objectID: data[index]["objectID"],
                                      ),
                                  transitionDuration:
                                  Duration(seconds: 0),
                                ));
                          });
                        },
                      ),

                      actions: <Widget>[
                        IconSlideAction(
                          color: Colors.white,
                          icon: isSaved(data[index]["objectID"]) ? Icons.favorite : Icons.favorite_border,
                          foregroundColor: Colors.red,
                          onTap:  () {
                            setState(() {
                              if (isSaved(data[index]["objectID"])) {
                                favorites.remove(data[index]["objectID"]);
                              } else {
                                favorites.add(data[index]["objectID"]);
                              }
                              rw.writeCounter(favorites);
                            });},
                        ),
                      ],
                    ),



              ),
            ),],
        ),
      ),

    );

  }
}
