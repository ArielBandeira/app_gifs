import 'dart:convert';
import 'package:app_gifs/ui/gif_page.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:transparent_image/transparent_image.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  String _searchTerm;

  var _offset = 0;
  Future<Map> _getGifs() async {
    var response;
    
    if(_searchTerm == null) {
      response = await http.get('https://api.giphy.com/v1/gifs/trending?api_key=y2x7UbYeyCxBX0XFRgceOg6HPB3eGqIf&limit=19&rating=g');
    } else {
      response = await http.get('https://api.giphy.com/v1/gifs/search?q=$_searchTerm&api_key=y2x7UbYeyCxBX0XFRgceOg6HPB3eGqIf&limit=19&rating=g');
    }
    
    return json.decode(response.body);

  }

  int _dataLength(List data){
    if(_searchTerm == null){
      return data.length;
    } else {
      return data.length + 1;
    }
  }

  Widget _createGifTable(BuildContext context, AsyncSnapshot snapshot) {
    return GridView.builder(
      padding: EdgeInsets.all(10.0),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2, 
        crossAxisSpacing: 10.0,
        mainAxisSpacing: 10.0
      ),
      itemCount: _dataLength(snapshot.data["data"]),
      itemBuilder: (context, index) {
        if(_searchTerm == null || index < snapshot.data[''].length) {
          return GestureDetector(
            child: FadeInImage.memoryNetwork(
              placeholder: kTransparentImage,
              image: snapshot.data["data"][index]["images"]['fixed_height']["url"],
              height: 300.0,
              fit: BoxFit.cover,
            ),
            onTap: () {
              Navigator.push((context), MaterialPageRoute(
                builder: (context) => GifPage(snapshot.data["data"][index])
              ));
            },
          );
        }else{
          return GestureDetector(
            child: Center(
              child: Text(
                "Carregar mais...",
                style: TextStyle(color: Colors.white, fontSize: 22.0),
              ),
            ),
            onTap: () {
              setState(() {
                _offset += 19;
              });
            },
          );
        }
      },

    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        centerTitle: true,
        title: Image.network("https://developers.giphy.com/static/img/dev-logo-lg.7404c00322a8.gif"),
      ),
      backgroundColor: Colors.black,
      body: Column(
        children: [
          TextField(
            decoration: InputDecoration(
              labelText: "Search",
              labelStyle: TextStyle(color: Colors.white),
            ),
            style: TextStyle(color: Colors.white),
            onSubmitted: (text) {
              setState(() {
                _searchTerm = text;
                _offset = 0;
              });
            }
          ),
          Expanded(
            child: FutureBuilder(
              future: _getGifs(),
              builder: (context, snapshot) {
                switch (snapshot.connectionState) {
                  case ConnectionState.waiting:
                  case ConnectionState.none:
                    //Cria um loading
                    return Center(
                      child: Container(
                        width: 200.0,
                        height: 200.0,
                        alignment: Alignment.center,
                        child: CircularProgressIndicator(
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                          strokeWidth: 5.0,
                        ),
                      ),
                    );
                  default:
                    return _createGifTable(context, snapshot);
                }
              },
            ),
          )
        ],
      ),
    );
  }
}