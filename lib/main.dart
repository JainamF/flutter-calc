import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'dart:math' as math;
import 'package:petitparser/petitparser.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Main(title: 'Calculator'),
      debugShowCheckedModeBanner: false,
    );
  }
}

class SizeConfig {
  static MediaQueryData _mediaQueryData;
  static double screenWidth;
  static double screenHeight;
  static double blockSizeHorizontal;
  static double blockSizeVertical;
  static double _safeAreaHorizontal;
  static double _safeAreaVertical;
  static double safeBlockHorizontal;
  static double safeBlockVertical;

  void init(BuildContext context) {
    _mediaQueryData = MediaQuery.of(context);
    screenWidth = _mediaQueryData.size.width;
    screenHeight = _mediaQueryData.size.height;
    blockSizeHorizontal = screenWidth / 100;
    blockSizeVertical = screenHeight / 100;
    _safeAreaHorizontal =
        _mediaQueryData.padding.left + _mediaQueryData.padding.right;
    _safeAreaVertical =
        _mediaQueryData.padding.top + _mediaQueryData.padding.bottom;
    safeBlockHorizontal = (screenWidth - _safeAreaHorizontal) / 100;
    safeBlockVertical = (screenHeight - _safeAreaVertical) / 100;
  }
}

class Main extends StatefulWidget {
  final String title;
  Main({Key key, this.title}) : super(key: key);
  @override
  _MainState createState() => _MainState();
}

class _MainState extends State<Main> {
  var display = TextEditingController();
  var first = TextEditingController();

  void sum() {
    first.text = display.text;
    final builder = ExpressionBuilder();
    builder.group()
      ..primitive(digit()
          .plus()
          .seq(char('.').seq(digit().plus()).optional())
          .flatten()
          .trim()
          .map((a) => num.tryParse(a)))
      ..wrapper(char('(').trim(), char(')').trim(), (l, a, r) => a);
    builder.group()..prefix(char('-').trim(), (op, a) => -a);

// power is right-associative
    builder.group()..right(char('^').trim(), (a, op, b) => math.pow(a, b));

// multiplication and addition are left-associative
    builder.group()..left(char('%').trim(), (a, op, b) => a * (b / 100));
    builder.group()
      ..left(char('x').trim(), (a, op, b) => a * b)
      ..left(char('/').trim(), (a, op, b) => a / b);
    builder.group()
      ..left(char('+').trim(), (a, op, b) => a + b)
      ..left(char('-').trim(), (a, op, b) => a - b);
    final parser = builder.build().end();
    String result = parser.parse(display.text).toString();
    print(result);
    if (result.contains('Success')) {
      List res = result.split(" ");
      display.text = res[1].toString();
    } else if (result.contains('Failure')) {
      display.text = 'Error';
    }
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(
          widget.title,
          style: TextStyle(color: Colors.orange),
        ),
        backgroundColor: Colors.transparent,
      ),
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: ListView(
          physics: const NeverScrollableScrollPhysics(),
          children: <Widget>[
            //First Screen
            Container(
              width: MediaQuery.of(context).size.width,
              height: SizeConfig._safeAreaVertical * 1.75,
              child: TextField(
                controller: first,
                style: TextStyle(color: Colors.orange, fontSize: 25),
                readOnly: true,
                textDirection: TextDirection.rtl,
                showCursor: false,
                autofocus: false,
                decoration: new InputDecoration(
                  border: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  contentPadding: EdgeInsets.all(10),
                ),
              ),
            ),
            //Second Screen
            Container(
              width: MediaQuery.of(context).size.width,
              height: SizeConfig._safeAreaVertical * 3.2,
              child: TextField(
                controller: display,
                style: TextStyle(color: Colors.orange, fontSize: 50),
                cursorColor: Colors.orange,
                readOnly: true,
                textDirection: TextDirection.rtl,
                showCursor: true,
                autofocus: true,
                decoration: new InputDecoration(
                  border: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  contentPadding: EdgeInsets.all(10),
                ),
              ),
            ),
            //First Row
            Container(
              width: MediaQuery.of(context).size.width,
              height: SizeConfig._safeAreaVertical * 3.5,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.all(5),
                      child: RawMaterialButton(
                        onPressed: () {
                          display.clear();
                          first.clear();
                        },
                        child: Center(
                          child: Text(
                            "C",
                            style: TextStyle(color: Colors.white, fontSize: 30),
                          ),
                        ),
                        fillColor: Colors.transparent,
                        shape: CircleBorder(
                          side: BorderSide(
                            width: 1.5,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.all(5),
                      child: RawMaterialButton(
                        onPressed: () {},
                        child: Center(
                          child: Text(
                            "+/-",
                            style: TextStyle(color: Colors.white, fontSize: 30),
                          ),
                        ),
                        fillColor: Colors.transparent,
                        shape: CircleBorder(
                          side: BorderSide(
                            width: 1.5,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.all(5),
                      child: RawMaterialButton(
                        onPressed: () {
                          display.text = '${display.text}%';
                        },
                        child: Center(
                          child: Text(
                            "%",
                            style: TextStyle(color: Colors.white, fontSize: 30),
                          ),
                        ),
                        fillColor: Colors.transparent,
                        shape: CircleBorder(
                          side: BorderSide(
                            width: 1.5,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.all(5),
                      child: RawMaterialButton(
                        onPressed: () {
                          display.text = display.text
                              .substring(0, display.text.length - 1);
                        },
                        child: Center(
                          child: Text(
                            "DEL",
                            style: TextStyle(color: Colors.white, fontSize: 30),
                          ),
                        ),
                        fillColor: Colors.transparent,
                        shape: CircleBorder(
                          side: BorderSide(
                            width: 1.5,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            //Second Row
            Container(
              width: MediaQuery.of(context).size.width,
              height: SizeConfig._safeAreaVertical * 3.5,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.all(5),
                      child: RawMaterialButton(
                        onPressed: () {
                          display.text = '${display.text}7';
                        },
                        child: Center(
                          child: Text(
                            "7",
                            style: TextStyle(color: Colors.white, fontSize: 30),
                          ),
                        ),
                        fillColor: Colors.transparent,
                        shape: CircleBorder(
                          side: BorderSide(
                            width: 1.5,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.all(5),
                      child: RawMaterialButton(
                        onPressed: () {
                          display.text = '${display.text}8';
                        },
                        child: Center(
                          child: Text(
                            "8",
                            style: TextStyle(color: Colors.white, fontSize: 30),
                          ),
                        ),
                        fillColor: Colors.transparent,
                        shape: CircleBorder(
                          side: BorderSide(
                            width: 1.5,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.all(5),
                      child: RawMaterialButton(
                        onPressed: () {
                          display.text = '${display.text}9';
                        },
                        child: Center(
                          child: Text(
                            "9",
                            style: TextStyle(color: Colors.white, fontSize: 30),
                          ),
                        ),
                        fillColor: Colors.transparent,
                        shape: CircleBorder(
                          side: BorderSide(
                            width: 1.5,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.all(5),
                      child: RawMaterialButton(
                        onPressed: () {
                          display.text = '${display.text}/';
                        },
                        child: Center(
                          child: Text(
                            "÷",
                            style: TextStyle(color: Colors.white, fontSize: 30),
                          ),
                        ),
                        fillColor: Colors.white38,
                        shape: CircleBorder(
                          side: BorderSide(
                            width: 1.5,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            //Third Row
            Container(
              width: MediaQuery.of(context).size.width,
              height: SizeConfig._safeAreaVertical * 3.5,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.all(5),
                      child: RawMaterialButton(
                        onPressed: () {
                          display.text = '${display.text}4';
                        },
                        child: Center(
                          child: Text(
                            "4",
                            style: TextStyle(color: Colors.white, fontSize: 30),
                          ),
                        ),
                        fillColor: Colors.transparent,
                        shape: CircleBorder(
                          side: BorderSide(
                            width: 1.5,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.all(5),
                      child: RawMaterialButton(
                        onPressed: () {
                          display.text = '${display.text}5';
                        },
                        child: Center(
                          child: Text(
                            "5",
                            style: TextStyle(color: Colors.white, fontSize: 30),
                          ),
                        ),
                        fillColor: Colors.transparent,
                        shape: CircleBorder(
                          side: BorderSide(
                            width: 1.5,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.all(5),
                      child: RawMaterialButton(
                        onPressed: () {
                          display.text = '${display.text}6';
                        },
                        child: Center(
                          child: Text(
                            "6",
                            style: TextStyle(color: Colors.white, fontSize: 30),
                          ),
                        ),
                        fillColor: Colors.transparent,
                        shape: CircleBorder(
                          side: BorderSide(
                            width: 1.5,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.all(5),
                      child: RawMaterialButton(
                        onPressed: () {
                          display.text = '${display.text}x';
                        },
                        child: Center(
                          child: Text(
                            "×",
                            style: TextStyle(color: Colors.white, fontSize: 30),
                          ),
                        ),
                        fillColor: Colors.white38,
                        shape: CircleBorder(
                          side: BorderSide(
                            width: 1.5,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            //Fourth Row
            Container(
              width: MediaQuery.of(context).size.width,
              height: SizeConfig._safeAreaVertical * 3.5,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.all(5),
                      child: RawMaterialButton(
                        onPressed: () {
                          display.text = '${display.text}1';
                        },
                        child: Center(
                          child: Text(
                            "1",
                            style: TextStyle(color: Colors.white, fontSize: 30),
                          ),
                        ),
                        fillColor: Colors.transparent,
                        shape: CircleBorder(
                          side: BorderSide(
                            width: 1.5,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.all(5),
                      child: RawMaterialButton(
                        onPressed: () {
                          display.text = '${display.text}2';
                        },
                        child: Center(
                          child: Text(
                            "2",
                            style: TextStyle(color: Colors.white, fontSize: 30),
                          ),
                        ),
                        fillColor: Colors.transparent,
                        shape: CircleBorder(
                          side: BorderSide(
                            width: 1.5,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.all(5),
                      child: RawMaterialButton(
                        onPressed: () {
                          display.text = '${display.text}3';
                        },
                        child: Center(
                          child: Text(
                            "3",
                            style: TextStyle(color: Colors.white, fontSize: 30),
                          ),
                        ),
                        fillColor: Colors.transparent,
                        shape: CircleBorder(
                          side: BorderSide(
                            width: 1.5,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.all(5),
                      child: RawMaterialButton(
                        onPressed: () {
                          display.text = '${display.text}-';
                        },
                        child: Center(
                          child: Text(
                            "-",
                            style: TextStyle(color: Colors.white, fontSize: 30),
                          ),
                        ),
                        fillColor: Colors.white38,
                        shape: CircleBorder(
                          side: BorderSide(
                            width: 1.5,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            //Fifth Row
            Container(
              width: MediaQuery.of(context).size.width,
              height: SizeConfig._safeAreaVertical * 3.5,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.all(5),
                      child: RawMaterialButton(
                        onPressed: () {
                          display.text = '${display.text}0';
                        },
                        child: Center(
                          child: Text(
                            "0",
                            style: TextStyle(color: Colors.white, fontSize: 30),
                          ),
                        ),
                        fillColor: Colors.transparent,
                        shape: CircleBorder(
                          side: BorderSide(
                            width: 1.5,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.all(5),
                      child: RawMaterialButton(
                        onPressed: () {
                          display.text = '${display.text}.';
                        },
                        child: Center(
                          child: Text(
                            ".",
                            style: TextStyle(color: Colors.white, fontSize: 30),
                          ),
                        ),
                        fillColor: Colors.transparent,
                        shape: CircleBorder(
                          side: BorderSide(
                            width: 1.5,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.all(5),
                      child: RawMaterialButton(
                        onPressed: () => sum(),
                        child: Center(
                          child: Text(
                            "=",
                            style: TextStyle(color: Colors.white, fontSize: 30),
                          ),
                        ),
                        fillColor: Colors.orangeAccent,
                        shape: CircleBorder(
                          side: BorderSide(
                            width: 1.5,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.all(5),
                      child: RawMaterialButton(
                        onPressed: () {
                          display.text = '${display.text}+';
                        },
                        child: Center(
                          child: Text(
                            "+",
                            style: TextStyle(color: Colors.white, fontSize: 30),
                          ),
                        ),
                        fillColor: Colors.white38,
                        shape: CircleBorder(
                          side: BorderSide(
                            width: 1.5,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
