import 'dart:convert';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_met_ui_changes/ArtPiece/ArtPiece_blurred.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_met_ui_changes/ArtPiece/ArtPiece.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart';

import 'package:flutter_met_ui_changes/HomePageWidget.dart';
import 'package:flutter_met_ui_changes/ReadWrite/ReadWrite.dart';

class departmentItems extends StatefulWidget {
  int departmentId;
  String departmentName;

  departmentItems(
      {Key key, @required this.departmentId, @required this.departmentName})
      : super(key: key);

  @override
  _departmentItemsState createState() => _departmentItemsState();
}

class _departmentItemsState extends State<departmentItems> {
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
    //print("Department : $favorites");
    Response response = await get(
        "https://collectionapi.metmuseum.org/public/collection/v1/objects?departmentIds=$departmentID&isOnVIew=true");
    var objectsID = jsonDecode(response.body);
    int objectCount = 0;
    int currentObjectIndex = 0;
    int i = 0;

    while (objectCount <= 100) {
      if (processTerminated) break;
      /*Response response = await get(
          "https://collectionapi.metmuseum.org/public/collection/v1/objects/$i");*/
      //print("Fetched Object $i");


      final results =await Future.wait([
        get("https://collectionapi.metmuseum.org/public/collection/v1/objects/${objectsID["objectIDs"][i]}"),
        get("https://collectionapi.metmuseum.org/public/collection/v1/objects/${objectsID["objectIDs"][i+1]}"),
        get("https://collectionapi.metmuseum.org/public/collection/v1/objects/${objectsID["objectIDs"][i+2]}"),
        get("https://collectionapi.metmuseum.org/public/collection/v1/objects/${objectsID["objectIDs"][i+3]}"),
        get("https://collectionapi.metmuseum.org/public/collection/v1/objects/${objectsID["objectIDs"][i+4]}"),
        get("https://collectionapi.metmuseum.org/public/collection/v1/objects/${objectsID["objectIDs"][i+5]}"),
        get("https://collectionapi.metmuseum.org/public/collection/v1/objects/${objectsID["objectIDs"][i+6]}"),
        get("https://collectionapi.metmuseum.org/public/collection/v1/objects/${objectsID["objectIDs"][i+7]}"),
        get("https://collectionapi.metmuseum.org/public/collection/v1/objects/${objectsID["objectIDs"][i+8]}"),
        get("https://collectionapi.metmuseum.org/public/collection/v1/objects/${objectsID["objectIDs"][i+9]}"),
        get("https://collectionapi.metmuseum.org/public/collection/v1/objects/${objectsID["objectIDs"][i+10]}"),
        get("https://collectionapi.metmuseum.org/public/collection/v1/objects/${objectsID["objectIDs"][i+11]}"),
        get("https://collectionapi.metmuseum.org/public/collection/v1/objects/${objectsID["objectIDs"][i+12]}"),
        get("https://collectionapi.metmuseum.org/public/collection/v1/objects/${objectsID["objectIDs"][i+13]}"),
        get("https://collectionapi.metmuseum.org/public/collection/v1/objects/${objectsID["objectIDs"][i+14]}"),
        get("https://collectionapi.metmuseum.org/public/collection/v1/objects/${objectsID["objectIDs"][i+15]}"),
        get("https://collectionapi.metmuseum.org/public/collection/v1/objects/${objectsID["objectIDs"][i+16]}"),
        get("https://collectionapi.metmuseum.org/public/collection/v1/objects/${objectsID["objectIDs"][i+17]}"),
        get("https://collectionapi.metmuseum.org/public/collection/v1/objects/${objectsID["objectIDs"][i+18]}"),
        get("https://collectionapi.metmuseum.org/public/collection/v1/objects/${objectsID["objectIDs"][i+19]}"),
        get("https://collectionapi.metmuseum.org/public/collection/v1/objects/${objectsID["objectIDs"][i+20]}"),
        get("https://collectionapi.metmuseum.org/public/collection/v1/objects/${objectsID["objectIDs"][i+21]}"),
        get("https://collectionapi.metmuseum.org/public/collection/v1/objects/${objectsID["objectIDs"][i+22]}"),
        get("https://collectionapi.metmuseum.org/public/collection/v1/objects/${objectsID["objectIDs"][i+23]}"),
        get("https://collectionapi.metmuseum.org/public/collection/v1/objects/${objectsID["objectIDs"][i+24]}"),
        get("https://collectionapi.metmuseum.org/public/collection/v1/objects/${objectsID["objectIDs"][i+25]}"),
        get("https://collectionapi.metmuseum.org/public/collection/v1/objects/${objectsID["objectIDs"][i+26]}"),
        get("https://collectionapi.metmuseum.org/public/collection/v1/objects/${objectsID["objectIDs"][i+27]}"),
        get("https://collectionapi.metmuseum.org/public/collection/v1/objects/${objectsID["objectIDs"][i+28]}"),
        get("https://collectionapi.metmuseum.org/public/collection/v1/objects/${objectsID["objectIDs"][i+29]}"),
        get("https://collectionapi.metmuseum.org/public/collection/v1/objects/${objectsID["objectIDs"][i+30]}"),

      ]);

      i = i+30+1;
      print("Called $i objects");


      for(int k = 0;k<=30;k++){
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
                  objectCalled = true;
                });
              },
            ),
          );
        }
      }
    }

  }


  Future<dynamic> object() async {
    departmentID = widget.departmentId;
    print("department $departmentID");
    Response response = await get(
        "https://collectionapi.metmuseum.org/public/collection/v1/objects?departmentIds=$departmentID&isOnVIew=true");
    var objectsID = jsonDecode(response.body);
    int objectCount = 0;
    int currentObjectIndex = 0;

    while (objectCount <= 40) {
      if (processTerminated) break;
      var i = objectsID["objectIDs"][currentObjectIndex];
      Response response = await get(
          "https://collectionapi.metmuseum.org/public/collection/v1/objects/$i");
      print("Fetched Object $i");
      currentObjectIndex++;
      var d = jsonDecode(response.body);
      print("${d["objectBeginDate"]}");
      if (d['isPublicDomain'] == true) {
        setState(() {
          data.add(d);
          var img = NetworkImage("${d["primaryImageSmall"]}");
          imgs.add(img);
          startDate.add(d["objectBeginDate"].toString());
          endDate.add(d["objectEndDate"].toString());
          objectCount++;
          objectCalled = true;
        });
      }
    }
    //img = NetworkImage(d["primaryImage"]);
    //objectCalled = true;
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
    departmentID = widget.departmentId;
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
      body: (!objectCalled)
          ? Center(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Center(
            child: CircularProgressIndicator(),
          ),
        ),
      )
          : Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
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
                                            ArtPiece(
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

                            await Navigator.push(
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
            ),
          ],
        ),
      ),
    );
  }
}
