import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_met_ui_changes/Departments/departmentItems_gridView.dart';
import 'package:flutter_met_ui_changes/Favorites/viewFavorites_gridview.dart';
import 'package:flutter_met_ui_changes/Search_Result/SearchResult_gridView.dart';
import 'package:flutter_met_ui_changes/SplashScreen.dart';
import 'Search_Result/SearchResult_slide_cards.dart';
import 'ReadWrite/ReadWrite.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart';
import 'dart:convert';

class HomePageWidget extends StatefulWidget {
  bool showSplashScreen;
  HomePageWidget({Key key,@required this.showSplashScreen}) : super(key: key);

  @override
  _HomePageWidgetState createState() => _HomePageWidgetState();
}

class _HomePageWidgetState extends State<HomePageWidget> {
  TextEditingController textController = TextEditingController();
  final scaffoldKey = GlobalKey<ScaffoldState>();
  bool departmentCalled = false;
  int _currentIndex = 0;
  ReadWrite rw = new ReadWrite();
  bool readState = false;
  var height, width;
  double imageHeight, imageWidth;

  var data;

  Future<dynamic> getDepartment() async {
    Response response = await get(
        "https://collectionapi.metmuseum.org/public/collection/v1/departments");
    data = jsonDecode(response.body);
    /*print(data);
    print(data["departments"][0]['displayName']);
    print(data["departments"].length);*/
    setState(() {
      departmentCalled = true;
    });
  }

  void _onTap(int index) {
    setState(() {
      switch (index) {
        case 1:
          Navigator.pushReplacement(
              context,
              PageRouteBuilder(
                pageBuilder: (context, animation1, animation2) =>
                    viewFavourites_gridview(),
                transitionDuration: Duration(seconds: 0),
              ));
          break;
        case 0:
          Navigator.pushReplacement(
              context,
              PageRouteBuilder(
                pageBuilder: (context, animation1, animation2) =>
                    HomePageWidget(showSplashScreen: false,),
                transitionDuration: Duration(seconds: 0),
              ));
          break;
      }
    });
  }

  void initState() {
    // TODO: implement initState
    super.initState();
    getDepartment();
  }

  @override
  Widget build(BuildContext context) {
    print(
        "Width: ${MediaQuery.of(context).size.width} Height: ${MediaQuery.of(context).size.height}");
    height = MediaQuery.of(context).size.height;
    width = MediaQuery.of(context).size.width;
    imageWidth = 120 > (width / 2.8) ? 120 : (width / 2.8);
    imageHeight = imageWidth / 1.2;

    print("Width: $imageWidth   Height: $imageHeight");

    return Scaffold(
      backgroundColor: Colors.white70,
      key: scaffoldKey,
      body: (widget.showSplashScreen && !departmentCalled)?splashScreen():(departmentCalled)
          ? Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                Stack(
                  children: [
                    Align(
                      alignment: Alignment(0, 0),
                      child: Image.asset(
                        'assets/home_image.png',
                        width: double.infinity,
                        height: 255,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Align(
                      alignment: Alignment(0, 0),
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(20, 60, 20, 0),
                        child:
                            Column(mainAxisSize: MainAxisSize.max, children: [
                          Image.asset(
                            'assets/logo_flutterMet_white.png',
                            width: 120,
                            fit: BoxFit.cover,
                          ),
                          Text(
                            'Search for art here',
                            style: GoogleFonts.oswald(
                                fontSize: 22,
                                color: Colors.white,
                                letterSpacing: 3),
                          ),
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
                                        textInputAction: TextInputAction.done,
                                        onFieldSubmitted: (term) {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(builder: (context) => SearchResult_gridView(
                                              searchItem: textController.text,
                                            ),),
                                          );
                                        },
                                        controller: textController,
                                        obscureText: false,
                                        decoration: InputDecoration(
                                          hintText:
                                              'Search for artists,makers and departments',
                                          hintStyle: GoogleFonts.playfairDisplay(),
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
                                  )),
                                  InkWell(
                                    child: Icon(
                                      Icons.search,
                                      color: Colors.black,
                                      size: 28,
                                    ),
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(builder: (context) => SearchResult_gridView(
                                          searchItem: textController.text,
                                        ),),
                                      );
                                      print("Search ${textController.text}");
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Align(
                            alignment: Alignment(-1, 0),
                            child: Padding(
                              padding: EdgeInsets.fromLTRB(10, 15, 0, 20),
                              child: Text(
                                'Museum Departments',
                                style: GoogleFonts.playfairDisplay(
                                    letterSpacing: 2,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16),
                              ),
                            ),
                          ),
                        ]),
                      ),
                    )
                  ],
                ),
                Expanded(
                  child: GridView.builder(
                    itemCount: data["departments"].length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: MediaQuery.of(context).orientation ==
                              Orientation.landscape
                          ? 3
                          : 2,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                      childAspectRatio: (2 / 1),
                    ),
                    itemBuilder: (
                      context,
                      index,
                    ) {
                      return GestureDetector(
                        onTap: () {},
                        child: Container(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              InkWell(
                                child: Card(
                                  elevation: 5,
                                  child: SizedBox(
                                    width:
                                        MediaQuery.of(context).size.width * 0.4,
                                    height: MediaQuery.of(context).size.height *
                                        0.1,
                                    child: Center(
                                      child: Text(
                                          data["departments"][index]
                                              ["displayName"],
                                          style: GoogleFonts.davidLibre(
                                              fontSize: 18,
                                              color: Colors.black,
                                              fontWeight: FontWeight.bold),
                                          textAlign: TextAlign.center),
                                    ),
                                  ),
                                  color: Colors.white,
                                ),
                                onTap: () {
                                  print(
                                      "HOME D-iD ${data["departments"][index]["departmentId"]}");
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (context) => departmentItems_gridView(
                                        departmentId: data["departments"]
                                        [index]["departmentId"],
                                        departmentName: data["departments"]
                                        [index]["displayName"],
                                      ),),
                                  );
                                },
                              )
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            )
          : Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                Stack(
                  children: [
                    Align(
                      alignment: Alignment(0, 0),
                      child: Image.asset(
                        'assets/home_image.png',
                        width: double.infinity,
                        height: 255,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Align(
                      alignment: Alignment(0, 0),
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(20, 60, 20, 0),
                        child:
                            Column(mainAxisSize: MainAxisSize.max, children: [
                          Image.asset(
                            'assets/logo_flutterMet_white.png',
                            width: 120,
                            fit: BoxFit.cover,
                          ),
                          Text(
                            'Search for art here',
                            style: GoogleFonts.oswald(
                                fontSize: 22,
                                color: Colors.white,
                                letterSpacing: 3),
                          ),
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
                                          hintStyle: GoogleFonts.playfairDisplay(),
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
                                  )),
                                  InkWell(
                                    child: Icon(
                                      Icons.search,
                                      color: Colors.black,
                                      size: 28,
                                    ),
                                    onTap: () {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(builder: (context) => SearchResult_gridView(
                                            searchItem: textController.text,
                                          ),),
                                      );
                                      print("Search ${textController.text}");
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Align(
                            alignment: Alignment(-1, 0),
                            child: Padding(
                              padding: EdgeInsets.fromLTRB(10, 15, 0, 20),
                              child: Text(
                                'Museum Departments',
                                style: GoogleFonts.playfairDisplay(
                                    letterSpacing: 2,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16),
                              ),
                            ),
                          ),
                        ]),
                      ),
                    )
                  ],
                ),
                Center(
                  child: CircularProgressIndicator(),
                ),
              ],
            ),
      bottomNavigationBar:(widget.showSplashScreen && !departmentCalled)?Container(
        height: 0,
        width: MediaQuery.of(context).size.width,
        child: (widget.showSplashScreen && !departmentCalled)?Container(color: Colors.transparent,width: MediaQuery.of(context).size.width,):
        BottomNavigationBar(
          showSelectedLabels: false,
          showUnselectedLabels: false,
          currentIndex:
              _currentIndex, // this will be set when a new tab is tapped
          onTap: _onTap,
          items:[
            BottomNavigationBarItem(
              icon: new Icon(
                Icons.home_outlined,
                color: Colors.red,
                size: 24,
              ),
              label: "",
              activeIcon: Icon(
                Icons.home,
                color: Colors.red,
                size: 24,
              ),
            ),
            BottomNavigationBarItem(
              icon: new Icon(
                Icons.favorite_border,
                color: Colors.red,
                size: 24,
              ),
              label: "",
              activeIcon: Icon(
                Icons.favorite,
                color: Colors.red,
                size: 24,
              ),
            ),
          ],
        ),
      ):Container(
        width: MediaQuery.of(context).size.width,
        child: (widget.showSplashScreen && !departmentCalled)?Container(color: Colors.transparent,width: MediaQuery.of(context).size.width,):
        BottomNavigationBar(
          showSelectedLabels: false,
          showUnselectedLabels: false,
          currentIndex:
          _currentIndex, // this will be set when a new tab is tapped
          onTap: _onTap,
          items:[
            BottomNavigationBarItem(
              icon: new Icon(
                Icons.home_outlined,
                color: Colors.red,
                size: 24,
              ),
              label: "",
              activeIcon: Icon(
                Icons.home,
                color: Colors.red,
                size: 24,
              ),
            ),
            BottomNavigationBarItem(
              icon: new Icon(
                Icons.favorite_border,
                color: Colors.red,
                size: 24,
              ),
              label: "",
              activeIcon: Icon(
                Icons.favorite,
                color: Colors.red,
                size: 24,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
