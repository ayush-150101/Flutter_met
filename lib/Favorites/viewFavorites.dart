import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_met_ui_changes/ReadWrite/ReadWrite.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart';
import 'package:flutter_met_ui_changes/ArtPiece/ArtPiece_fav.dart';
import 'package:flutter_met_ui_changes/ArtPiece/ArtPiece.dart';
import 'package:flutter_met_ui_changes/HomePageWidget.dart';

class viewFavourites extends StatefulWidget {



  viewFavourites({Key key}) : super(key: key);

  @override
  _viewFavouritesState createState() => _viewFavouritesState();
}

class _viewFavouritesState extends State<viewFavourites> {
  List<int> items;
  int _currentIndex = 1;
  List<dynamic> data = [];
  bool listNotEmpty = false,itemsAdded = false;
  List<dynamic> imgs = [];
  ReadWrite rw = new ReadWrite();

  void readData() async{
    var read = await rw.readCounter();
    print(read);

    setState(() {
      items = read;
    });
  }

  void _onTap(int index) {
    setState(() {
      switch (index) {
        case 1:
          Navigator.pushReplacement(context, PageRouteBuilder(
            pageBuilder: (context, animation1, animation2) =>
                viewFavourites(),
            transitionDuration: Duration(seconds: 0),
          ));
          break;
        case 0:
          Navigator.pushReplacement(context, PageRouteBuilder(
            pageBuilder: (context, animation1, animation2) =>
                HomePageWidget(),
            transitionDuration: Duration(seconds: 0),
          ));
          break;
      }
    });
  }

  Future<dynamic> getFavorites() async {
    var read = await rw.readCounter();
    print(read);

    setState(() {
      items = read;
    });
    print("ViewFavorites page");
    print("items $items");

    if (items.isNotEmpty) {
      setState(() {
        listNotEmpty = true;
      });
      print("ITEMS ARE $items");
      for (int i = 0; i < items.length; i++) {
        var x = items[i];
        Response response = await get(
            "https://collectionapi.metmuseum.org/public/collection/v1/objects/$x");
        var y = jsonDecode(response.body);
        var img = NetworkImage("${y["primaryImageSmall"]}");
        /*img.resolve(ImageConfiguration()).addListener(
          ImageStreamListener(
                (info, call) {*/
        setState(() {
          imgs.add(img);
          data.add(y);
          listNotEmpty = true;
          itemsAdded = true;
        });
        /*},
          ),
        );*/

      }
    }
    else
      return null;
  }

  void initState() {
    // TODO: implement initState
    super.initState();
    //readData();
    getFavorites();
  }


  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        automaticallyImplyLeading: false,
        title: Text("MyCollection",style: GoogleFonts.sairaCondensed(letterSpacing: 2,color: Colors.black,),), centerTitle: true,),

      body:(listNotEmpty && itemsAdded) ? Padding( //items loaded condition
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

                      actions: <Widget>[
                        IconSlideAction(
                          color: Colors.white,
                          icon: Icons.favorite ,
                          foregroundColor: Colors.red,
                          onTap:  () {
                            setState(() {
                              items.remove(data[index]["objectID"]);
                              rw.writeCounter(items);
                              Navigator.pushReplacement(context,PageRouteBuilder(
                                pageBuilder: (context, animation1, animation2) => viewFavourites(),
                                transitionDuration: Duration(seconds: 0),
                              ));
                            });},
                        ),
                      ],
                    ),
              ),
            ),
          ],
        ),
      ) : (listNotEmpty && !itemsAdded) ? Column(  //Items loading Condition
        mainAxisSize: MainAxisSize.max,
        children: [
          SizedBox(height: 30,),
          Center(child: CircularProgressIndicator(),),
        ],
      ):Column( //No favorites Condition
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






