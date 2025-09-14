import 'dart:convert';
import 'package:alpha_news/NewsView.dart';
import 'package:alpha_news/model.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';

class Category extends StatefulWidget {
  String Query;
  Category({required this.Query});

  @override
  State<Category> createState() => _CategoryState();
}

class _CategoryState extends State<Category> {
  List<NewsQueryModel> newsModelList = <NewsQueryModel>[];
  bool isLoading = true;

  getNewsByQuery(String query) async {
    String url = "";
    if (query == "Top News" || query == "United States") {
      url =
          "https://newsapi.org/v2/top-headlines?country=us&category=business&apiKey=71c3867107c5466e809a1c0a1465be2a";
    } else {
      url =
          "https://newsapi.org/v2/everything?q=$query&sortBy=publishedAt&language=en&apiKey=71c3867107c5466e809a1c0a1465be2a";
    }

    Response response = await get(Uri.parse(url));
    Map data = jsonDecode(response.body);
    setState(() {
      data["articles"].forEach((element) {
        NewsQueryModel newsQueryModel = new NewsQueryModel();
        newsQueryModel = NewsQueryModel.fromMap(element);
        newsModelList.add(newsQueryModel);
        setState(() {
          isLoading = false;
        });
      });
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getNewsByQuery(widget.Query);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent, // important for gradient
      appBar: AppBar(title: const Text("ALPHA NEWS"), centerTitle: true),
      body: Container(
        height: double.infinity,
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFFfbc2eb), // pink
              Color(0xFFa6c1ee), // blue
            ],
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
          ),
        ),

        child: SingleChildScrollView(
          child: Container(
            child: Column(
              children: [
                Container(
                  margin: EdgeInsets.fromLTRB(15, 25, 0, 0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      SizedBox(width: 13),
                      Container(
                        margin: EdgeInsets.symmetric(vertical: 15),
                        child: Text(
                          widget.Query,
                          style: TextStyle(fontSize: 38),
                        ),
                      ),
                    ],
                  ),
                ),

                isLoading
                    ? Container(
                        height: MediaQuery.of(context).size.height - 500,
                        child: Center(child: CircularProgressIndicator()),
                      )
                    : ListView.builder(
                        physics: NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: newsModelList.length,
                        itemBuilder: (context, index) {

                          final item = newsModelList[index];
                          final img = item.newsImg;
                          final head = item.newsHead ?? "";
                          final desc = item.newsDes ?? "";
                          final url = item.newsUrl ?? "";



                          return Container(
                            margin: EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 5,
                            ),


                          child: InkWell(
                          onTap: () {
                          if (url.isNotEmpty) {
                          Navigator.push(
                          context,
                          MaterialPageRoute(
                          builder: (context) => NewsView(url),
                          ),
                          );
                          }
                          },




                            child: Card(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              elevation: 1.0,
                              child: Stack(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(15),
                                    child: Image.network(
                                      newsModelList[index].newsImg,
                                      fit: BoxFit.fitHeight,
                                      height: 230,
                                      width: double.infinity,
                                    ),
                                  ),

                                  Positioned(
                                    left: 0,
                                    right: 0,
                                    bottom: 0,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(15),
                                        gradient: LinearGradient(
                                          colors: [
                                            Colors.black12.withOpacity(0),
                                            Colors.black,
                                          ],
                                          begin: Alignment.topCenter,
                                          end: Alignment.bottomCenter,
                                        ),
                                      ),
                                      padding: EdgeInsets.fromLTRB(
                                        15,
                                        15,
                                        10,
                                        8,
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            newsModelList[index].newsHead,
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          Text(
                                            newsModelList[index]
                                                        .newsDes
                                                        .length >
                                                    50
                                                ? "${newsModelList[index].newsDes.substring(0, 55)}...."
                                                : newsModelList[index].newsDes,
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          );
                        },
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
