import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

Future<Map<String,dynamic>> fetchPronostico() async {
  final response = await http
      .get(Uri.parse('https://www.7timer.info/bin/civillight.php?lon=-97.8610&lat=22.2331&ac=0&unit=metric&output=json&tzshift=0'));

  if(response.statusCode == 200){
    return jsonDecode(response.body);
  }
  else{
    throw Exception('Fallo en cargar Album');
  }
}

class Album {
  final int userId;
  final int id;
  final String title;

  Album({
    required this.userId,
    required this.id,
    required this.title,
  });

  factory Album.fromJson(Map<String, dynamic> json) {
    return Album(
      userId: json['userId'],
      id: json['id'],
      title: json['title'],
    );
  }
}

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'API Clima',
      theme: ThemeData(
        primarySwatch: Colors.grey,
      ),
      home: MyHomePage(title: 'API Clima Test'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;
  late Future<Map<String,dynamic>> futurePronostico;

  List<Widget> createDateWidgets(List<dynamic> seriededatos) {
    List<Widget> lst = List.generate(7, (index) => Row(
      children: [
        Expanded(child: Text(seriededatos[index]["date"].toString())),
        Expanded(child: Text(seriededatos[index]["weather"])),
        Expanded(child: Text(seriededatos[index]["temp2m"]["max"].toString())),
        Expanded(child: Text(seriededatos[index]["temp2m"]["min"].toString())),
      ],
    ));
    return lst;
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    futurePronostico = fetchPronostico();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            FutureBuilder<Map<String,dynamic>>(
              future: futurePronostico,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return Column(
                    children: createDateWidgets(snapshot.data!["dataseries"]),
                  );
                } else if (snapshot.hasError) {
                  return Text('${snapshot.error}');
                }

                // By default, show a loading spinner.
                return const CircularProgressIndicator();
              },
            ),
          ],
        ),
      ),
      /*floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: Icon(Icons.add),
      ),*/ // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
