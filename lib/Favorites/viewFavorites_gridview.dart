import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_met_ui_changes/Widgets/ArtPiece_card.dart';
import 'package:flutter_met_ui_changes/Widgets/ArtPiece_card.dart';
import 'package:flutter_met_ui_changes/Widgets/ArtPiece_card_big.dart';


import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_met_ui_changes/ReadWrite/ReadWrite.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart';
import 'package:flutter_met_ui_changes/ArtPiece/ArtPiece_fav.dart';
import 'package:flutter_met_ui_changes/ArtPiece/ArtPiece.dart';
import 'package:flutter_met_ui_changes/HomePageWidget.dart';

class viewFavourites_gridview extends StatefulWidget {
  viewFavourites_gridview({Key key}) : super(key: key);

  @override
  _viewFavourites_gridviewState createState() => _viewFavourites_gridviewState();
}

class _viewFavourites_gridviewState extends State<viewFavourites_gridview> {
  List<int> items = [];
  int _currentIndex = 1;
  List<dynamic> data = [];
  bool listNotEmpty = false,itemsAdded = false;
  List<dynamic> imgs = [];
  ReadWrite rw = new ReadWrite();
  //List<artPiece_Card_big> tile = [];
  List<artPiece_card> tile = [];
  bool fileLoaded = false;


  void readData() async{
    var read = await rw.readCounter();
    print(read);

    setState(() {
      items = read;
    });
  }

  bool isOddNumber(int number) {
    return number % 2 == 0 ? false : true;
  }

  void addToList() async{
    var read = await rw.readCounter();
    print(read);


    items = read;
    var length = items.length;

    print("Items: $items $length");


    if(items.isNotEmpty) {
      for (int i = 0; i < length; i++) {
        tile.add(artPiece_card(objectID: items[i]));
      }

      setState(() {
        listNotEmpty = true;
        fileLoaded = true;
      });
    }
  }

  void _onTap(int index) {
    setState(() {
      switch (index) {
        case 1:
          Navigator.pushReplacement(context, PageRouteBuilder(
            pageBuilder: (context, animation1, animation2) =>
                viewFavourites_gridview(),
            transitionDuration: Duration(seconds: 0),
          ));
          break;
        case 0:
          Navigator.pushReplacement(context, PageRouteBuilder(
            pageBuilder: (context, animation1, animation2) =>
                HomePageWidget(showSplashScreen: false,),
            transitionDuration: Duration(seconds: 0),
          ));
          break;
      }
    });
  }

  Future<dynamic> getFavorites() async {
    addToList();
  }

  void initState() {
    // TODO: implement initState
    super.initState();
    //readData();
    print("View Favorites Grid Called");
    getFavorites();
  }


  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        automaticallyImplyLeading: false,
        title: Text("MyCollection",style: GoogleFonts.sairaCondensed(letterSpacing: 3,color: Colors.black,fontWeight: FontWeight.bold),), centerTitle: true,),

      body:listNotEmpty==false?Column( //No favorites Condition
        mainAxisSize: MainAxisSize.max,
        children: [
          SizedBox(height: 30,),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Center(
              child: Image.asset("assets/emptyCollection.png")  ,
            ),
          )
        ],
      ):fileLoaded==false?Center(
        child: CircularProgressIndicator(),
      ):Center(
        child:ListView.builder(
            itemCount: tile.length,
            itemBuilder:(BuildContext context, int index) => GestureDetector(
              onDoubleTap:() {
                print("Double Tap triggered");
                setState(() {
                  items.removeAt(index);
                  rw.writeCounter(items);
                  Navigator.pushReplacement(context, PageRouteBuilder(
                    pageBuilder: (context, animation1, animation2) =>
                        viewFavourites_gridview(),
                    transitionDuration: Duration(seconds: 0),
                  ));
                });
              },
                child: Center(
                    child: tile[index]
                )
            ),
        ),

        /*Column(
          children:tile,
        ),*/
      ),

      bottomNavigationBar: BottomNavigationBar(
        showSelectedLabels: false,
        showUnselectedLabels: false,
        currentIndex: _currentIndex, // this will be set when a new tab is tapped
        onTap: _onTap,
        items: [
          BottomNavigationBarItem(
            icon: new Icon(Icons.home_outlined,color: Colors.red,),
            label: "",
            activeIcon: Icon(Icons.home,color: Colors.red,size: 24,),
          ),
          BottomNavigationBarItem(
            icon: new Icon(Icons.favorite_border,color: Colors.red,),
            label: "",
            activeIcon: Icon(Icons.favorite,color: Colors.red,size: 24,),
          ),
        ],
      ),

    );
  }
}






