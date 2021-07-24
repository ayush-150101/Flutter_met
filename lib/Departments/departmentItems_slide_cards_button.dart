import 'dart:convert';
import 'dart:ui';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_met_ui_changes/Widgets/ArtPiece_card_big.dart';
import 'package:flutter_tindercard/flutter_tindercard.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart';
import 'package:flutter_met_ui_changes/ReadWrite/ReadWrite.dart';

class departmentItems_slide_cards_button extends StatefulWidget {
  int departmentId;
  String departmentName;

  departmentItems_slide_cards_button({Key key,@required this.departmentId,@required this.departmentName}) : super(key: key);

  @override
  _departmentItems_slide_cards_buttonState createState() => _departmentItems_slide_cards_buttonState();
}

class _departmentItems_slide_cards_buttonState extends State<departmentItems_slide_cards_button> {

  List<dynamic> data = [];
  bool objectCalled = false;
  var departmentID, departmentName;
  List<int> favorites = [];
  List<dynamic> imgs = [];
  List<dynamic> startDate = [];
  List<dynamic> endDate = [];
  bool processTerminated = false;
  ReadWrite rw = new ReadWrite();
  List<artPiece_Card_big> cards = [];
  bool flag = true;
  int currentCardIndex;
  List<int> removeIndex = [];
  List<int> Ids = [];

  bool showInfo = false;

  void toggleInfo(){

    setState(() {
      if(showInfo)
        showInfo = false;

      else
        showInfo = true;
    });

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

  Future<dynamic> retrieveData() async {
    //print("searching for $search");
    data.clear();
    departmentID = widget.departmentId;
    print("Department : $favorites");
    Response response = await get(
        "https://collectionapi.metmuseum.org/public/collection/v1/objects?departmentIds=$departmentID&isOnVIew=true");
    var objectsID = jsonDecode(response.body);
    int objectCount = 0;
    int currentObjectIndex = 0;
    int i = 0;

    while (objectCount <= 60) {
      if (processTerminated) break;

      List<Future> ftr = [];
      int x = i;
      for(i = x;i<(x+20);i++)
        ftr.add(get("https://collectionapi.metmuseum.org/public/collection/v1/objects/${objectsID["objectIDs"][i]}"));


      final results = await Future.wait(ftr);

      // i = i+20+1;
      print("Called $i objects");


      for(int k = 0;k<20;k++){
        var d = jsonDecode(results[k].body);

        if (d['isPublicDomain'] == true) {
          var img = NetworkImage("${d["primaryImageSmall"]}");
          print("OBJECT ID : ${d["objectID"]}");
          //cards.add(artPiece_Card_big(objectID: d["objectID"]));
          Ids.add(d["objectID"]);
          objectCount++;
          print("Loaded $objectCount objects!");
          setState(() {
            // print("Object Id : ${d["objectID"]}");
            imgs.add(img);
            data.add(d);

          });


        }
      }
    }
    setState(() {
      objectCalled = true;
    });


  }

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

  void initState() {
    // TODO: implement initState
    super.initState();
    readData();
    retrieveData();
  }

  @override
  Widget build(BuildContext context) {
    departmentName = widget.departmentName;
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

        body:objectCalled?Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Center(
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
                  cardBuilder: (context, index)
                  {
                    currentCardIndex = index;
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
                        data[index]["title"].length>16?"${data[index]["title"].substring(0,16)}...":data[index]["title"],
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    );

                    final _details = ClipRRect(
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

                    return GestureDetector(
                      onTap:() {toggleInfo();},
                      child: showInfo?Padding(
                        padding: const EdgeInsets.fromLTRB(0,0,0,20),
                        child: Stack(
                          children: <Widget>[
                            Container(
                              margin: EdgeInsets.only(bottom: 10.0),
                              height: screenHeight * 0.9,
                              width: screenWidth * 0.9,
                              decoration: BoxDecoration(
                                image: DecorationImage(
                                  image: imgs[index],
                                  fit: BoxFit.cover,
                                ),
                                borderRadius: BorderRadius.circular(20.0),
                              ),
                            ),
                            Container(
                              margin: EdgeInsets.only(bottom: 10.0),
                              height: screenHeight * 0.9,
                              width: screenWidth * 0.9,
                              child:DraggableScrollableSheet(
                                initialChildSize: 0.1,
                                minChildSize: 0.1,
                                maxChildSize: 0.8,
                                builder: (BuildContext context, myscrollController) {
                                  return Container(
                                    child: ListView.builder(
                                      controller: myscrollController,
                                      itemCount: 25,
                                      itemBuilder: (BuildContext context, int index) {
                                        return ListTile(
                                            title: Text(
                                              'Dish $index',
                                              style: TextStyle(color: Colors.black54),
                                            ));
                                      },
                                    ),
                                    decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.only(
                                          topLeft:Radius.circular(20),
                                          topRight: Radius.circular(20),
                                          bottomLeft: Radius.circular(20),
                                          bottomRight:  Radius.circular(20),
                                        )
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ):Padding(
                        padding: const EdgeInsets.fromLTRB(0,0,0,20),
                        child: Stack(
                          children: <Widget>[
                            Container(
                              margin: EdgeInsets.only(bottom: 10.0),
                              height: screenHeight * 0.9,
                              width: screenWidth * 0.9,
                              decoration: BoxDecoration(
                                image: DecorationImage(
                                  image: imgs[index],
                                  fit: BoxFit.cover,
                                ),
                                borderRadius: BorderRadius.circular(20.0),
                              ),
                            ),
                            Align(alignment:Alignment.bottomCenter,child: _details)
                          ],
                        ),
                      )
                    );
                  },
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
                    if(orientation == CardSwipeOrientation.RIGHT || true)

                      removeIndex.add(index);

                    /*setState(() {
                      imgs.removeAt(index);
                      data.removeAt(index);
                    });*/



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
            ),

            SizedBox(height: 50,),

            Align(
              alignment: Alignment.bottomCenter,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [

                MaterialButton(
                color: Colors.white,
                elevation: 4.0,
                onPressed: () {
                  print("CURRENT INDEX: $currentCardIndex");
                  print("REmove $removeIndex");

                  setState(() {
                    data.removeAt(currentCardIndex);
                    imgs.removeAt(currentCardIndex);

                    var x;

                    for(int i = 0;i<removeIndex.length;i++){
                      print(data[i]);
                      data.removeAt(removeIndex[i]);
                      imgs.removeAt(removeIndex[i]);
                      x = removeIndex[i];
                    }
                    if(x!=null){
                      data.removeAt(x + 1);
                      imgs.removeAt(x + 1);
                    }
                            });
                  removeIndex = [];
                },
                height: 50,
                shape: CircleBorder(),
                child: Container(
                  height: 50.0,
                  child: Icon(Icons.cancel_outlined,color: Colors.red,size: 40,),
                ),
              ),



                  SizedBox(width: 50,),



                  MaterialButton(
                    color: Colors.white,
                    elevation: 4.0,
                    onPressed: () {
                      print("CURRENT INDEX: $currentCardIndex");
                      print("REmove $removeIndex");

                      if(!favorites.contains(data[currentCardIndex]['objectID']))
                        favorites.add(data[currentCardIndex]['objectID']);
                      rw.writeCounter(favorites);
                      showToast("Added to Favorites");
                      print("${data[currentCardIndex]["title"]} added to favorites");

                      setState(() {
                        data.removeAt(currentCardIndex);
                        imgs.removeAt(currentCardIndex);

                        var x;

                        for(int i = 0;i<removeIndex.length;i++){
                          print(data[i]);
                          data.removeAt(removeIndex[i]);
                          imgs.removeAt(removeIndex[i]);
                          x = removeIndex[i];
                        }

                        if(x!=null){
                          data.removeAt(x + 1);
                          imgs.removeAt(x + 1);
                        }


                      });
                      removeIndex = [];
                      },
                    height: 50,
                    shape: CircleBorder(),
                    child: Container(
                      height: 50.0,
                      child: Icon(Icons.favorite_border,color: Colors.red,size: 40,),
                    ),
                  ),

                ],
              ),
            )
          ],
        ):Center(
          child: CircularProgressIndicator(),
        )
    );
  }
}
