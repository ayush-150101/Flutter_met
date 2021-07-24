import 'dart:convert';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_met_ui_changes/Favorites/viewFavorites_gridview.dart';
import 'package:flutter_met_ui_changes/ReadWrite/ReadWrite.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter_met_ui_changes/Favorites/viewFavorites.dart';

import 'package:flutter_met_ui_changes/HomePageWidget.dart';

class ArtPiece_fav_blurred extends StatefulWidget {

  int objectID;
  ArtPiece_fav_blurred({Key key, @required this.objectID})
      : super(key: key);

  @override
  _ArtPiece_fav_blurredState createState() => _ArtPiece_fav_blurredState();
}

class _ArtPiece_fav_blurredState extends State<ArtPiece_fav_blurred> {

  var img, startDate, endDate, title, department;
  List<int> favorites = [];
  bool objectsLoaded = false;
  ReadWrite rw = new ReadWrite();
  bool showInfo = false;

  void readFileData() async{
    var read = await rw.readCounter();
    print(read);

    setState(() {
      favorites = read;
    });
  }

  void infoTapped() {
    if (showInfo == true)
      setState(() {
        showInfo = false;
      });

    else
      setState(() {
        showInfo = true;
      });
  }

  Future<dynamic> readData() async {
    Response response = await get(
        "https://collectionapi.metmuseum.org/public/collection/v1/objects/${widget.objectID}");
    var d = jsonDecode(response.body);
    setState(() {

      startDate = d["objectStartDate"].toString();
      endDate = d["objectEndDate"].toString();
      title = d["title"];
      department = d["department"];
      img = NetworkImage(d["primaryImage"]);
      img.resolve(ImageConfiguration()).addListener(
        ImageStreamListener(
              (info, call) {
            setState(() {
              objectsLoaded = true;
            });
          },
        ),
      );

    });
  }

  void initState() {
    // TODO: implement initState
    super.initState();
    readFileData();
    readData();
  }

  @override
  Widget build(BuildContext context) {
    if (objectsLoaded) {
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
                      size: 28,
                    ),
                    onTap: () {
                      Navigator.pushReplacement(context,PageRouteBuilder(
                        pageBuilder: (context, animation1, animation2) => viewFavourites_gridview(),
                        transitionDuration: Duration(seconds: 0),
                      ));
                    },
                  ),
                  SizedBox(
                    width: 15,
                  ),
                  AutoSizeText(
                    title.length>16?"${title.substring(0,16)}...":title,
                    style: GoogleFonts.lato(
                      letterSpacing: 2,
                      color: Colors.black,
                    ),
                    maxLines: 1,
                  ),
                ],
              ),
            ),
            actions: [
              FlatButton.icon(
                onPressed: () {
                  setState(() {
                    favorites.contains(widget.objectID)
                        ? favorites.remove(widget.objectID)
                        : favorites.add(widget.objectID);
                    rw.writeCounter(favorites);
                    print(favorites);
                  });
                },
                icon: favorites.contains(widget.objectID)
                    ? Icon(
                  Icons.favorite,
                  color: Colors.red,
                )
                    : Icon(
                  Icons.favorite_border,
                  color: Colors.red,
                ),
                label: Text(""),
              )
            ],
          ),
          body: showInfo? Stack(
              children: [

                Align(
                  alignment: Alignment(0,0),
                  child: Image(
                    image: img,
                    fit: BoxFit.cover,
                    //height: double.infinity,
                    // width: double.infinity,
                    /*width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height,*/
                  ),
                ),

                Align(
                  alignment: Alignment(2,0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(height: 100,),
                      Center(
                        child: Container(
                          width: MediaQuery.of(context).size.width,
                          height: MediaQuery.of(context).size.height * 0.5 ,

                          child:BackdropFilter(
                            filter: ImageFilter.blur(
                              sigmaX: 10.0,
                              sigmaY: 10.0,
                            ),

                            child: SingleChildScrollView(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [

                                  Text(
                                    title,
                                    style: GoogleFonts.davidLibre(
                                        fontSize: 24,
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 3),
                                  ),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  Text("$endDate",
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
                                    department,
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

                        ),
                      ),
                    ],
                  ),
                ),

                Positioned(
                    right: 0.0,
                    top: 0.0,
                    child:Padding(
                      padding: EdgeInsets.all(10),
                      child: IconButton(
                        icon: Icon(Icons.cancel, color: Colors.black,size: 24,),
                        onPressed: () => infoTapped(),
                      ),
                    )
                ),

              ]
          ): Stack(
              children: [

                Align(
                  alignment: Alignment(0,0),
                  child: Image(
                    image: img,
                    fit: BoxFit.cover,
                    //height: double.infinity,
                    //width: double.infinity,
                    /*width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height,*/
                  ),
                ),

                Positioned(
                    right: 0.0,
                    top: 0.0,
                    child:Padding(
                      padding: EdgeInsets.all(10),
                      child: IconButton(
                        icon: Icon(Icons.info_outline_rounded, color: Colors.black,size: 24,),
                        onPressed: () => infoTapped(),
                      ),
                    )
                ),

              ]
          )
      );
    }
    else{
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
  }
}
