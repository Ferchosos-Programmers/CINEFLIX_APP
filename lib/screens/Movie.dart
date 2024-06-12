import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:carousel_slider/carousel_slider.dart';

const baseUrl = "https://api.themoviedb.org/3/movie/";
const baseImagesUrl = "http://image.tmdb.org/t/p/";
const apiKey = "630bf0aa7439da949c032a838dbcefdf";
const nowPlaying = "${baseUrl}now_playing?api_key=$apiKey";
const popularMoviesUrl = "${baseUrl}popular?api_key=$apiKey";

void main() {
  runApp(MovieApp());
}

class MovieApp extends StatelessWidget {
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
  List<Results> nowPlayingMovies = [];
  List<Results> popularMovies = [];

  @override
  void initState() {
    super.initState();
    fetchNowPlayingMovies();
    fetchPopularMovies();
  }

  Future<void> fetchNowPlayingMovies() async {
    final response = await http.get(Uri.parse(nowPlaying));
    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      final List<dynamic> results = data['results'];
      setState(() {
        nowPlayingMovies =
            results.map((json) => Results.fromJson(json)).toList();
      });
    } else {
      throw Exception('Failed to load movies');
    }
  }

  Future<void> fetchPopularMovies() async {
    final response = await http.get(Uri.parse(popularMoviesUrl));
    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      final List<dynamic> results = data['results'];
      setState(() {
        popularMovies = results.map((json) => Results.fromJson(json)).toList();
      });
    } else {
      throw Exception('Failed to load popular movies');
    }
  }

  Widget _buildCarouselSlider() {
    return CarouselSlider(
      options: CarouselOptions(
        height: 400.0,
        autoPlay: true,
        enlargeCenterPage: true,
        aspectRatio: 16 / 9,
        autoPlayCurve: Curves.fastOutSlowIn,
        enableInfiniteScroll: true,
        autoPlayAnimationDuration: Duration(milliseconds: 800),
        viewportFraction: 0.8,
      ),
      items: nowPlayingMovies.map((movieItem) {
        return Builder(
          builder: (BuildContext context) {
            return Container(
              width: MediaQuery.of(context).size.width,
              margin: EdgeInsets.symmetric(horizontal: 5.0),
              decoration: BoxDecoration(
                color: Colors.black,
              ),
              child: Image.network(
                "${baseImagesUrl}w342${movieItem.posterPath}",
                fit: BoxFit.cover,
              ),
            );
          },
        );
      }).toList(),
    );
  }

  Widget _buildPopularMovies() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            'Popular Movies',
            style: TextStyle(
                color: Colors.white,
                fontSize: 20.0,
                fontWeight: FontWeight.bold),
          ),
        ),
        Container(
          height: 200.0,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: popularMovies.length,
            itemBuilder: (BuildContext context, int index) {
              return GestureDetector(
                onTap: () {
                  // Aquí puedes implementar la lógica para reproducir el video
                  // Cuando se haga clic en la imagen.
                  // Puedes utilizar un paquete como 'video_player' para reproducir el video.
                  // Para este ejemplo, simplemente mostraré un mensaje.
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text(
                            'Reproducir video de ${popularMovies[index].title}')),
                  );
                },
                child: Container(
                  width: 150.0,
                  margin: EdgeInsets.symmetric(horizontal: 5.0),
                  decoration: BoxDecoration(
                    color: Colors.black,
                  ),
                  child: Image.network(
                    "${baseImagesUrl}w185${popularMovies[index].posterPath}",
                    fit: BoxFit.cover,
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

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
      body: nowPlayingMovies.isEmpty && popularMovies.isEmpty
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                children: [
                  _buildCarouselSlider(),
                  _buildPopularMovies(),
                ],
              ),
            ),
    );
  }
}

class Movie {
  Dates? dates;
  int? page;
  List<Results>? results;
  int? totalPages;
  int? totalResults;

  Movie(
      {this.dates,
      this.page,
      this.results,
      this.totalPages,
      this.totalResults});

  Movie.fromJson(Map<String, dynamic> json) {
    dates = json['dates'] != null ? new Dates.fromJson(json['dates']) : null;
    page = json['page'];
    if (json['results'] != null) {
      results = <Results>[];
      json['results'].forEach((v) {
        results!.add(new Results.fromJson(v));
      });
    }
    totalPages = json['total_pages'];
    totalResults = json['total_results'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.dates != null) {
      data['dates'] = this.dates!.toJson();
    }
    data['page'] = this.page;
    if (this.results != null) {
      data['results'] = this.results!.map((v) => v.toJson()).toList();
    }
    data['total_pages'] = this.totalPages;
    data['total_results'] = this.totalResults;
    return data;
  }
}

class Dates {
  String? maximum;
  String? minimum;

  Dates({this.maximum, this.minimum});

  Dates.fromJson(Map<String, dynamic> json) {
    maximum = json['maximum'];
    minimum = json['minimum'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['maximum'] = this.maximum;
    data['minimum'] = this.minimum;
    return data;
  }
}

class Results {
  bool? adult;
  String? backdropPath;
  List<int>? genreIds;
  int? id;
  String? originalLanguage;
  String? originalTitle;
  String? overview;
  double? popularity;
  String? posterPath;
  String? releaseDate;
  String? title;
  bool? video;
  double? voteAverage;
  int? voteCount;

  Results(
      {this.adult,
      this.backdropPath,
      this.genreIds,
      this.id,
      this.originalLanguage,
      this.originalTitle,
      this.overview,
      this.popularity,
      this.posterPath,
      this.releaseDate,
      this.title,
      this.video,
      this.voteAverage,
      this.voteCount});

  Results.fromJson(Map<String, dynamic> json) {
    adult = json['adult'];
    backdropPath = json['backdrop_path'];
    genreIds = json['genre_ids'].cast<int>();
    id = json['id'];
    originalLanguage = json['original_language'];
    originalTitle = json['original_title'];
    overview = json['overview'];
    popularity = json['popularity'];
    posterPath = json['poster_path'];
    releaseDate = json['release_date'];
    title = json['title'];
    video = json['video'];
    voteAverage = json['vote_average'];
    voteCount = json['vote_count'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['adult'] = this.adult;
    data['backdrop_path'] = this.backdropPath;
    data['genre_ids'] = this.genreIds;
    data['id'] = this.id;
    data['original_language'] = this.originalLanguage;
    data['original_title'] = this.originalTitle;
    data['overview'] = this.overview;
    data['popularity'] = this.popularity;
    data['poster_path'] = this.posterPath;
    data['release_date'] = this.releaseDate;
    data['title'] = this.title;
    data['video'] = this.video;
    data['vote_average'] = this.voteAverage;
    data['vote_count'] = this.voteCount;
    return data;
  }
}
