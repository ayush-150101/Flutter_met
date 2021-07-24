import 'dart:convert';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_met_ui_changes/ArtPiece/ArtPiece.dart';
import 'package:http/http.dart';
import 'package:google_fonts/google_fonts.dart';

class artPiece_tile extends StatefulWidget {
  int objectID;
  artPiece_tile({@required this.objectID}) ;

  @override
  _artPiece_tileState createState() => _artPiece_tileState();
}

class _artPiece_tileState extends State<artPiece_tile> {

  int index;
  int _currentIndex = 1;
  bool fileLoaded = false;
  bool dataLoaded = false;
  var img, startDate, endDate, title = "", department;
  bool objectsLoaded = false;
  bool showInfo = false;
  var d;

  Future<dynamic> readData() async {
    Response response = await get(
        "https://collectionapi.metmuseum.org/public/collection/v1/objects/${widget.objectID}");
    d = jsonDecode(response.body);

    endDate = d["objectEndDate"].toString();
    title = d["title"];
    department = d["department"];
    img = NetworkImage(d["primaryImageSmall"]);
    //img = CachedNetworkImageProvider(d["primaryImage"]);

    setState(() {
      dataLoaded = true;
    });

    /*img.resolve(ImageConfiguration()).addListener(
      ImageStreamListener(
            (info, call) {
          setState(() {
            dataLoaded = true;
          });
        },
      ),
    );*/
  }

  void initState(){
    super.initState();
    readData();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ArtPiece(
                objectID: widget.objectID,
            ),),
          );
        },
        child: Material(
          elevation: 20,
          borderRadius: BorderRadius.circular(10.0),
          child: Container(
            height: MediaQuery.of(context).size.height * 0.12,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(40.0),
            ),
            child: dataLoaded?Center(
              child: ListTile(
                leading:
                FadeInImage.assetNetwork(
                  placeholder: 'assets/Spinner.gif',
                  image: d["primaryImageSmall"],
                  width: 56,
                  height: double.infinity,
                  fit: BoxFit.fill,
                ),
                /*Image(
                  image: img,
                  width: 56,
                  height: double.infinity,
                  fit: BoxFit.fill,
                  /*height: MediaQuery.of(context).size.height ,
                  width: MediaQuery.of(context).size.width * 0.15,
                  fit: BoxFit.fitHeight,*/
                ),*/
                title:  Text(
                  title.length>28?"${title.substring(0,28)}...":title,
                  style: GoogleFonts.playfairDisplay(
                    color: Colors.black,
                    fontSize: 14.0,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2
                  ),
                  textAlign: TextAlign.start,
                ),
                trailing: Icon(Icons.arrow_forward_ios_rounded),
              ),
            ):Center(child: CircularProgressIndicator(),),
          ),
        ),
      ),
    );
  }
}
