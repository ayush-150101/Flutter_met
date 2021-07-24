import 'dart:convert';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_met_ui_changes/ArtPiece/ArtPiece_fav_blurred.dart';
import 'package:http/http.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';


class artPiece_card extends StatefulWidget {
  int objectID;
  //String title, department, endDate, imageUrl;

  artPiece_card({Key key, @required this.objectID}) : super(key: key);

  @override
  _artPiece_cardState createState() => _artPiece_cardState();



}

class _artPiece_cardState extends State<artPiece_card> {

  int index;
  int _currentIndex = 1;
  bool fileLoaded = false;
  bool dataLoaded = false;
  var img, startDate, endDate, title = "", department;
  bool objectsLoaded = false;
  bool showInfo = false;
  var d;

  void toggleInfo(){

    setState(() {
      if(showInfo)
        showInfo = false;

      else
        showInfo = true;
    });

  }

  Future<dynamic> readData() async {
    Response response = await get(
        "https://collectionapi.metmuseum.org/public/collection/v1/objects/${widget.objectID}");
    d = jsonDecode(response.body);

    endDate = d["objectEndDate"].toString();
    title = d["title"];
    department = d["department"];
    setState(() {
      dataLoaded = true;
    });
  }

  void initState() {
    // TODO: implement initState
    super.initState();
    readData();
  }

  @override
  Widget build(BuildContext context) {
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
        title.length>22?"${title.substring(0,22)}...":title,
        style: TextStyle(
          color: Colors.black,
          fontSize: 18.0,
          fontWeight: FontWeight.bold,
        ),
        textAlign: TextAlign.center,
      ),
    );

    final _details =ClipRRect(
      borderRadius: BorderRadius.circular(15.0),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
        child: Container(
          padding: EdgeInsets.fromLTRB(15.0, 15.0, 15.0, 15.0),
          height: screenHeight * .1,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[_name],
          ),
        ),
      ),
    );

    return Container(
      margin: EdgeInsets.only(bottom: 40.0),
      child: GestureDetector(
        onTap:() => toggleInfo(),
        child: dataLoaded
            ? showInfo?Container(
          height: screenHeight * 0.85,
          width: screenWidth * 0.9,
          margin: EdgeInsets.only(bottom: 10.0),
          child: Stack(
            children: <Widget>[
              Container(
                margin: EdgeInsets.only(bottom: 10.0),
                height: screenHeight * 0.75,
                width: screenWidth * 0.9,
                child: FadeInImage(
                  image: CachedNetworkImageProvider(d["primaryImage"],),
                  placeholder: AssetImage('assets/Spinner5.gif'),
                ),
                /*decoration: BoxDecoration(
                  image: DecorationImage(
                    image:FadeInImage.assetNetwork(CachedNetworkImageProvider(
                      d["primaryImage"],
                    ),)
                    fit: BoxFit.fill,
                  ),
                  borderRadius: BorderRadius.circular(20.0),
                ),*/
              ),

              Container(
                margin: EdgeInsets.only(bottom: 30.0),
                height: screenHeight * 0.75,
                width: screenWidth * 0.9,
                child: Align(
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
                                          fontSize: 16, color: Colors.red, letterSpacing: 3,fontWeight: FontWeight.bold)),
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
              ),

            ],
          ),
        ):Container(
          margin: EdgeInsets.only(bottom: 10.0),
          height: screenHeight * 0.85,
          width: screenWidth * 0.9,
          child: Column(
            children: <Widget>[
              Container(
                margin: EdgeInsets.only(bottom: 10.0),
                height: screenHeight * 0.75,
                width: screenWidth * 0.9,
                child: FadeInImage(
                  image: CachedNetworkImageProvider(d["primaryImage"],),
                  placeholder: AssetImage('assets/Spinner5.gif'),
                ),
              ),
              Expanded(
                child: Container(
                  width: screenWidth * 0.9,
                  child: _details,
                ),
              )

            ],
          ),
        )
            : Padding(
          padding: const EdgeInsets.fromLTRB(0,0,0,20),
          child: Hero(
            tag: widget.objectID,
            child: Container(
              margin: EdgeInsets.only(bottom: 10.0),
              height: screenHeight * 0.75,
              width: screenWidth * 0.9,
              decoration: BoxDecoration(
                color: Colors.white10,
                borderRadius: BorderRadius.circular(20.0),
              ),
              child: Center(
                child: CircularProgressIndicator(),
              ),
            ),
          ),
        ),
      ),
    );

  }
}
