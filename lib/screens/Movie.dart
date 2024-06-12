import 'package:flutter/material.dart';

void main() {
  runApp(Movie());
}

class Movie extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: MyMovie(),
    );
  }
}

class MyMovie extends StatefulWidget {
  @override
  State<MyMovie> createState() => _MyMovieState();
}

class _MyMovieState extends State<MyMovie> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0.0,
        title: const Text('CINEFLIX',
            style: TextStyle(
                color: Colors.white,
                fontSize: 14.0,
                fontWeight: FontWeight.bold)),
        centerTitle: true,
        leading: IconButton(onPressed: () {}, icon: const Icon(Icons.menu)),
        actions: <Widget>[
          IconButton(onPressed: () {}, icon: const Icon(Icons.search)),
        ],
      ),
      body: Container(),
    );
  }
}
