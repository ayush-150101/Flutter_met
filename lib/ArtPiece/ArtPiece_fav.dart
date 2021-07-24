import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_met_ui_changes/ReadWrite/ReadWrite.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter_met_ui_changes/Favorites/viewFavorites.dart';

import 'package:flutter_met_ui_changes/HomePageWidget.dart';

class ArtPiece_fav extends StatefulWidget {

  int objectID;
  ArtPiece_fav({Key key, @required this.objectID})
      : super(key: key);

  @override
  _ArtPiece_favState createState() => _ArtPiece_favState();
}

class _ArtPiece_favState extends State<ArtPiece_fav> {

  var img, startDate, endDate, title, department;
  List<int> favorites = [];
  bool objectsLoaded = false;
  ReadWrite rw = new ReadWrite();

  void readFileData() async{
    var read = await rw.readCounter();
    print(read);

    setState(() {
      favorites = read;
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
                        pageBuilder: (context, animation1, animation2) => viewFavourites(),
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
          body: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                Image(
                  image: img,
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height * 0.7,
                ),
                SizedBox(
                  height: 40,
                ),
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
          ));
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
